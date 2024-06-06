--[[
	DEBUGGER:
	Used to debug drones
	set DRONE_ID to the drone to be debugged

	keyBinds:
	"h" shutdown drone remotely
	"r" restart drone remotely
	"t" restart all drones in list
	"i" initialize hound pack
]]--

os.loadAPI("lib/quaternions.lua")

modem = peripheral.find("modem")
rednet.open("back")


local DEBUG_TO_DRONE_CHANNEL = 9
local DRONE_TO_DEBUG_CHANNEL = 10
modem.open(DRONE_TO_DEBUG_CHANNEL)

local DEBUG_THIS_DRONE = 14

local DRONE_IDs = {
	"14",
	"15",
	"16",
	"17",
	}

local ORBIT_FORMATION = {
	vector.new(5,-5,5),
	vector.new(5,5,5),
	vector.new(-5,5,5),
	vector.new(-5,-5,5),
}

function initDrones()
	for i,id in ipairs(DRONE_IDs) do
		transmit("orbit_offset",ORBIT_FORMATION[i],id)
	end
	print("initialized Hounds")
end

local keyBinds = {
		[keys.h] = function ()
			transmit("hush",nil,DEBUG_THIS_DRONE)
			transmit("HUSH",nil,DEBUG_THIS_DRONE)
			print("hush drone: ",DEBUG_THIS_DRONE)
		end,
		[keys.r] = function ()
			transmit("restart",nil,DEBUG_THIS_DRONE)
			print("restarted drone: ",DRONE_ID)
		end,
		[keys.t] = function ()
			for i,id in ipairs(DRONE_IDs) do 
				transmit("restart",nil,id)
				print("restarted drone: ",id)
			end
			os.sleep(1)
			initDrones()
		end,
		[keys.i] = function ()
			initDrones()
		end,
		[keys.q] = function (arguments)
			os.reboot()
		end,
		default = function (key)
			print(keys.getName(key), "key not bound")
		end,
	}

function transmit(cmd,args)
	modem.transmit(DEBUG_TO_DRONE_CHANNEL, DRONE_TO_DEBUG_CHANNEL,
	{drone_id=DRONE_ID,msg={cmd=cmd,args=args}})
end

function transmit(cmd,args,drone_id)
	modem.transmit(DEBUG_TO_DRONE_CHANNEL, DRONE_TO_DEBUG_CHANNEL,
	{drone_id=drone_id,msg={cmd=cmd,args=args}})
end

function commands()
	while true do
		local event, key, isHeld = os.pullEvent("key")
		if keyBinds[key] then
			keyBinds[key]()
		else
			keyBinds["default"](key)
		end
	end
end

function listen()
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		term.clear()
		term.setCursorPos(1,1)
		print(senderChannel)
		if message then
			print(textutils.serialize(message))
		end
	end
end

parallel.waitForAny(listen,commands)
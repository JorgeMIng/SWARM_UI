--[[
	DEBUGGER:
	Used to debug drones
	set DRONE_ID to the drone to be debugged

	keyBinds:
	"h" to shutdown drone remotely
	"r" to restart drone remotely
]]--

os.loadAPI("lib/quaternions.lua")

modem = peripheral.find("modem")
rednet.open("back")


local DEBUG_TO_DRONE_CHANNEL = 9
local DRONE_TO_DEBUG_CHANNEL = 10


local DRONE_ID = 101

local keyBinds = {
		[keys.h] = function ()
			transmit("hush")
			transmit("HUSH")
			print("hush drone: ",DRONE_ID)
		end,
		[keys.t] = function ()
			transmit("restart")
			print("restarted drone: ",DRONE_ID)
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

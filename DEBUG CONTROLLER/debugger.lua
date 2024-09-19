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
modem.open(DRONE_TO_DEBUG_CHANNEL)

local HEAD_DRONE_ID = 14

local DRONE_IDs = {}

function getDroneIDsFromJSON()
	local h = fs.open("./drone_ids.json","r")
	local json_string = h.readLine()
	local droneIDs = JSON:decode(json_string)
	h.close()
	for i=1,#droneIDs do
		droneIDs[i] = tostring(droneIDs[i])
	end
	return droneIDs
end

table.insert(DRONE_IDs,getDroneIDsFromJSON())
print(textutils.serialise(DRONE_IDs))
local ORBIT_FORMATION = {
	--vector.new(5,3,5),
}

function initLeviathanDrone()
	for i=2,#DRONE_IDs,1 do
		transmit("segment_delay",5*(i-1),DRONE_IDs[i])
		transmit("gap_length",4,DRONE_IDs[i])
		transmit("designate_to_ship",HEAD_DRONE_ID,DRONE_IDs[i])
	end
	print("initialized Leviathan Drone Segments")
end

local keyBinds = {
		[keys.h] = function ()
			transmit("hush",nil,HEAD_DRONE_ID)
			transmit("HUSH",nil,HEAD_DRONE_ID)
			print("hush drone: ",HEAD_DRONE_ID)
		end,
		[keys.r] = function ()
			transmit("restart",nil,HEAD_DRONE_ID)
			print("restarted drone: ",DRONE_ID)
		end,
		[keys.t] = function ()
			for i,id in ipairs(DRONE_IDs) do 
				transmit("restart",nil,id)
				print("restarted drone: ",id)
			end
			os.sleep(1)
			initLeviathanDrone()
		end,
		[keys.i] = function ()
			initLeviathanDrone()
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
local Root = require 'lib.gui.Root'
local LinearContainer = require 'lib.gui.LinearContainer'
local Label = require 'lib.gui.Label'
local Button = require 'lib.gui.Button'
local TextField = require 'lib.gui.TextField'
local ListBox = require 'lib.gui.ListBox'
local ScrollBar = require 'lib.gui.ScrollBar'
local Constants = require 'lib.gui.Constants'
local ScrollWidget = require 'lib.gui.ScrollWidget'
local Object = require 'lib.object.Object'
local JSON = require "lib.JSON"
local list_manager = require ("lib.list_manager")
local IndexedListScroller = list_manager.IndexedListScroller
local remoteUI = require 'lib.custom_gui.remoteUI'



modem = peripheral.find("modem")
--rednet.open("back")

local remote_control_transmitter_channel = 7
local component_broadcast_channel = 100

local debug_transmitter_channel = 9
local debug_receiver_channel = 10
local remote_control_receiver_channel = 8
local REPLY_DUMP_CHANNEL = 10000

local main_controller_id =11
modem.close(debug_receiver_channel)
modem.open(remote_control_receiver_channel)

local DRONE_ID = 6

function transmitToDrone(drone,cmd,args)
	modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, 
	{drone_id=drone,msg={cmd=cmd,args=args}})
end

function debugProbe(msg,sendChannel,dumpChaneel)--transmits to debug channel
	modem.transmit(sendChannel,dumpChaneel, msg)
end

--debugProbe("hello this is remote",debug_receiver_channel,REPLY_DUMP_CHANNEL)

transmitToDrone(DRONE_ID,"RISE")

local communication_channels = {
	DEBUG_TO_DRONE_CHANNEL = 9,
	DRONE_TO_DEBUG_CHANNEL = 10,
	REMOTE_TO_DRONE_CHANNEL = 7,
	DRONE_TO_REMOTE_CHANNEL = 8,
	DRONE_TO_DRONE_CHANNEL = 11,
}

--[[
transmit(drone,"weapons_free",true)
transmit(drone,"turret_mode",true)
transmit(drone,"hunt_mode",true) --force-activates auto_aim if set to true
transmit(drone,"auto_aim",true)
transmit(drone,"dynamic_sentry",true) --follow_mode
transmit(drone,"player_mounting_ship",true)	--sitting_on_ship
transmit(drone,"orbit_offset",vector.new(x,y,z))	--formation
transmit(drone,"use_external_radar",{is_aim=,mode=})	--use_external_aim/use_external_orbit
transmit(drone,"set_target_mode",{is_aim=,mode=})	--aim_target_mode/orbit_target_mode
transmit(drone,"designate_to_player","PHO")--masterPlayerTextField
transmit(drone,"designate_to_ship",82)--masterShipTextField
transmit(drone,"add_to_whitelist",{is_player=true,designation="PHO2"})
transmit(drone,"remove_from_whitelist",{is_player=true,designation="PHO2"}) --set new designated player/ship before removing it from whitelist
]]--




local masterSettings = {	
									-- default configs
									dynamic_positioning_mode = false,
									run_mode = true,
									stop_drone=false,		
									player_mounting_ship = false,		
									orbit_target_mode = "PLAYER",		
									master_player = "Yordi111",		
									master_ship = "140",
									--turret  congis and 
									aim_target_mode = "PLAYER",
									use_external_aim = false,		
									use_external_orbit = false,
									bullet_range = 100,
									range_finding_mode = 3,
									hunt_mode = false,			
									auto_aim = false,
									center_figure=vector.new(5,5,5),
									insc_length=20,

									--tracer
									walk=false,

									-- segment
									segment_delay = 50,			
									gap_length = 5,
									group_id = "group1",
									segment_number = 1,

									--kite 
									rope_length = 20,

									-- RAY
									target_radius = 7,
									target_height = 3,
									swim_frequency = 5,
									swim_amplitude = 0.5,
									--not used
									--formation = vector.new(10,10,7),


									}

									
local drone_ids_list = {}

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

drone_ids_list=getDroneIDsFromJSON()

--[[
for i=0,30 do
	table.insert(drone_ids_list,tostring(i))
end
]]--						
local drone_settings_list = {}
drone_settings_list["ALL"] = masterSettings

local config={
	secret_id=42,
	error_debug=true
}

local ui = remoteUI(masterSettings,drone_ids_list,communication_channels,config)
debugProbe("i am alive",10,10000)
ui:mainLoop()

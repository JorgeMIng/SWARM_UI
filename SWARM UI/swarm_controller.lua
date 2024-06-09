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

os.loadAPI("lib/list_manager.lua")
local IndexedListScroller = list_manager.IndexedListScroller
local remoteUI = require 'lib.custom_gui.remoteUI'



modem = peripheral.find("modem")
--rednet.open("back")

local remote_control_transmitter_channel = 7
local component_broadcast_channel = 100
local debug_transmitter_channel = 9
local debug_receiver_channel = 10
local remote_control_receiver_channel = 8

local main_controller_id =11
modem.close(debug_receiver_channel)
modem.open(remote_control_receiver_channel)

local DRONE_ID = 421

function transmitToDrone(drone,cmd,args)
	modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, 
	{drone_id=drone,msg={cmd=cmd,args=args}})
end

transmitToDrone(DRONE_ID,"RISE")

local communication_channels = {
	DEBUG_TO_DRONE_CHANNEL = 9,
	DRONE_TO_DEBUG_CHANNEL = 10,
	REMOTE_TO_DRONE_CHANNEL = 7,
	DRONE_TO_REMOTE_CHANNEL = 8
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


function Settings(args)
	return{
		hunt_mode = args.hunt_mode,
		turret_mode = args.turret_mode,
		auto_aim = args.auto_aim,
		follow_mode = args.follow_mode,
		aim_target_mode = args.aim_target_mode,
		orbit_target_mode = args.orbit_target_mode,
		master_player = args.master_player,
		sitting_on_ship = args.sitting_on_ship,
		master_ship = args.master_ship,
		
		formation = args.formation,
		use_external_aim = args.use_external_aim,
		use_external_orbit = args.use_external_orbit,
	}
end

local masterSettings = Settings({	turret_mode = true,
									hunt_mode = false,
									auto_aim = false,
									follow_mode = true,
									sitting_on_ship = false,
									formation = vector.new(10,10,7),
									use_external_aim = false,
									use_external_orbit = false,
									aim_target_mode = "PLAYER",
									orbit_target_mode = "PLAYER",
									master_player = "PHO",
									master_ship = "39"})
									
local DRONE_IDs = {
	"16",
	"29",
	"37",
	"30",
	"31",
	"32",
	"33",
	"34",
	"35",
	"36",
}
				
local drone_settings_list = {}
drone_settings_list["ALL"] = masterSettings



local ui = remoteUI(masterSettings,DRONE_IDs,communication_channels)

ui:mainLoop()

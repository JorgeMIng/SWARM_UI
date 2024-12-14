local list_manager = require ("lib.list_manager")

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

local MultiStateButton = require "lib.custom_gui.MultiStateButton"
local BiStateButton = require "lib.custom_gui.BiStateButton"

local LinearContainer = require 'lib.gui.LinearContainer'

local expect = require "cc.expect"

local DroneSettingsProfile = Object:subclass()

--[["ALL" DEFAULT CONTROLLER SETTINGS]]--
function DroneSettingsProfile:init()
	DroneSettingsProfile.superClass.init(self)
	self.drone_id = "ALL"
	self.settings_profile = {
		["TURRET"] = {
			hunt_mode = false,		
			dynamic_positioning_mode = false,		
			auto_aim = false,		
			run_mode = false,		
			player_mounting_ship = false,
			aim_target_mode = "PLAYER",		
			orbit_target_mode = "PLAYER",		
			master_player = "Yordi111",		
			master_ship = "6",		
			use_external_aim = false,		
			use_external_orbit = false,
			bullet_range = 100,
			range_finding_mode = 3,
		},
		["KITE"] = {
			dynamic_positioning_mode = false,
			run_mode = false,		
			player_mounting_ship = false,		
			orbit_target_mode = "PLAYER",		
			master_player = "USERNAME_HERE",		
			master_ship = "82",		
			rope_length = 20,
		},
		["RAY"] = {
			dynamic_positioning_mode = false,		
			run_mode = false,		
			player_mounting_ship = false,
			orbit_target_mode = "PLAYER",		
			master_player = "USERNAME_HERE",		
			master_ship = "82",		
		},
		["SEGMENT"] = {
			dynamic_positioning_mode = false,
			run_mode = false,		
			player_mounting_ship = false,		
			orbit_target_mode = "SHIP",		
			master_player = "PHO",		
			master_ship = "16",
			
			segment_delay = 50,			
			gap_length = 5,
			group_id = "group1",
			segment_number = 1,
		},
		["TRACER"] = {
			dynamic_positioning_mode = false,
			run_mode = false,		
			player_mounting_ship = false,		
			orbit_target_mode = "PLAYER",		
			master_player = "PHO",		
			master_ship = "3",
			
			walk = false,
		},
		["DEFAULT"] = {
			default_label = "DEFAULT LABEL",
			is_default = true
		},
	}
end

function DroneSettingsProfile:setProfile(drone_type,settings)
	if (self.settings_profile[drone_type]) then
		for var_name,value in pairs(settings) do
			if (self.settings_profile[drone_type][var_name] ~= nil) then
				self.settings_profile[drone_type][var_name] = value
			end
		end
	end
end

function DroneSettingsProfile:getDroneTypeProfile(drone_type)
	if (self.settings_profile[drone_type]) then
		return self.settings_profile[drone_type]
	end
	return self.settings_profile["DEFAULT"]
end

function DroneSettingsProfile:addDroneSpecificSettings(drone_type,settings)
	for key,value in pairs(settings) do
		self.settings_profile[drone_type][key] = value
	end
end

return DroneSettingsProfile
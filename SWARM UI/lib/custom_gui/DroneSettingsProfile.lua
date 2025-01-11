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



function DroneSettingsProfile:getAllDroneMetadata()
	local dir_drone_profiles = dir_utilities.listFolders("lib/custom_gui/command_books/")
	local result={}
	local ordered_types={}
	local count_skip=0

	for idx,drone_type in ipairs(dir_drone_profiles) do

		local lib_path = "lib.custom_gui.command_books."..drone_type..".metadata"
		local path = lib_path:gsub("%.", "/")
		local error=false
		path=path..".lua"

		if fs.exists(path) then		
			local metadata = require("lib.custom_gui.command_books."..drone_type..".metadata")
			if type(metadata) == "table" and metadata.id_name and metadata.get_settings and metadata.get_protocol_book_class_dir 
			and not result[metadata.id_name] and metadata.visible then
				result[metadata.id_name]=metadata
				ordered_types[idx-count_skip]=metadata.id_name
			else
				error=true
			end


		else
			error=true
		end
		if error then
			count_skip = count_skip+1
		end
		
	end	
	return {metadata=result,order_types=ordered_types}
end


function DroneSettingsProfile:getMetadata()
	if not self.drone_metadata  then
		self.drone_metadata = DroneSettingsProfile:getAllDroneMetadata()
	end
	return self.drone_metadata.metadata
end

function DroneSettingsProfile:getOrderedTypes()
	if not self.drone_metadata  then
		self.drone_metadata = DroneSettingsProfile:getAllDroneMetadata()
	end
	return self.drone_metadata.order_types
end

function DroneSettingsProfile:getDefaultSettings()
	return require("lib.custom_gui.command_books.common_settings")
end


function DroneSettingsProfile:setUpDroneSettings(set_values)
	if not self.drone_metadata then
		self.drone_metadata = DroneSettingsProfile:getAllDroneMetadata()
	end
	for drone_id,metadata in pairs(self.drone_metadata.metadata) do
		
		local drone_settings =metadata.get_settings()
		local default_settings =self:getDefaultSettings()
		
		self:addDroneSpecificSettings(drone_id,default_settings)
		self:addDroneSpecificSettings(drone_id,drone_settings)
		self:setProfile(drone_id,set_values)
		
	end
end




	



function DroneSettingsProfile:init(set_values)
	DroneSettingsProfile.superClass.init(self)
	self.drone_id = "ALL"
	self.drone_metadata = DroneSettingsProfile:getAllDroneMetadata()

	

	self.settings_profile = {

		["ERROR"] = {
			default_label = "DEFAULT LABEL",
			is_default = true
		},
	}
	self:getAllDroneMetadata()
	self:setUpDroneSettings(set_values)


end

function DroneSettingsProfile:setProfile(drone_type,settings)
	if (self.settings_profile[drone_type]) then
		for var_name,value in pairs(settings) do

			
			if (value ~= nil) then
				self.settings_profile[drone_type][var_name] = value
			end
			
		end
	end
end

function DroneSettingsProfile:getDroneTypeProfile(drone_type)
	if (self.settings_profile[drone_type]) then
		return self.settings_profile[drone_type]
	end
	return self.settings_profile["ERROR"]
end

function DroneSettingsProfile:addDroneSpecificSettings(drone_type,settings)
	for key,value in pairs(settings) do
		if not self.settings_profile[drone_type]then
			self.settings_profile[drone_type] ={}
		end
		self.settings_profile[drone_type][key] = value
	end
end

return DroneSettingsProfile
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
local CommandManager = require "lib.custom_gui.CommandManager"





local expect = require "cc.expect"




local SwarmManager = LinearContainer:subclass()

function getMaxDroneIDLength(drone_ids)
	local max_length = 0
	for _,ids in ipairs(drone_ids) do
		local string_length = #tostring(ids)
		if(string_length>max_length) then
			max_length = string_length
		end
	end
	return max_length
end

function SwarmManager:init(root,init_arguments)
	expect(1, root, "table")
	SwarmManager.superClass.init(self,root,Constants.LinearAxis.HORIZONTAL,0,0)
	
	self.com_channels = init_arguments.com_channels or {}
	self.selected_drone_id = init_arguments.selected_drone_id or "ALL"
	self.current_drone_type = init_arguments.current_drone_type or "DEFAULT"
	self.drone_id_list = {"ALL"}
	self.drone_id_whitelist = {}
	self:updateDroneList(init_arguments.drone_id_list)
	
	
	self.droneList = ListBox(root,getMaxDroneIDLength(self.drone_id_list),20,self.drone_id_list)
	self.droneList:setSelected(1)
	self.droneListscrollBar = ScrollBar(root,self.droneList)
	
	self.droneSelect = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.droneSelect:addChild(self.droneList,false,false,Constants.LinearAlign.START)
	self.droneSelect:addChild(self.droneListscrollBar,false,true,Constants.LinearAlign.START)
	
	self:addChild(self.droneSelect,false,true,Constants.LinearAlign.START)
	
	init_arguments.drone_id_list = self.drone_id_list
	init_arguments.drone_id_whitelist = self.drone_id_whitelist
	self.commandManager = CommandManager(root,init_arguments)
	
	self:addChild(self.commandManager,true,true,Constants.LinearAlign.START)
	
	self.droneList.bgColor = colors.orange
	self.droneList.selBgColor = colors.blue
	self.droneList.selTextColor = colors.orange
	self.droneList.selected = 1
	
	self.droneListscrollBar.bgColor = colors.black
	self.droneListscrollBar.bgPressedColor = colors.lightBlue
	self.droneListscrollBar.pressedColor = colors.lightBlue
	self.droneListscrollBar.textColor = colors.black
	self.droneListscrollBar.barColor = colors.blue
	
	
	function self.droneList.onSelectionChanged()
		self.selected_drone_id = tostring(self.drone_id_list[self.droneList.selected])
		
		if (self.selected_drone_id == "ALL") then
			self.commandManager:switchToSwarmProfile(true)
			self.commandManager:enableDroneTypeButton(true)
			self.commandManager:enableSetSwarmButton(true)
			self.commandManager:enableWiFiButton(true)
			
			self.commandManager:refreshProtocolBookBox()
			self.commandManager:refreshDroneTypeButton()
		else
			
			self.commandManager:updateCurrentDroneId(self.selected_drone_id)
			self.commandManager:switchToSwarmProfile(false)
			self.commandManager:enableDroneTypeButton(false)
			self.commandManager:enableWiFiButton(false)
			self.commandManager:enableSetSwarmButton(false)
			
			
			-- TODO have cooldown of not receiving info of drone and then changed to not found (stop flickering)
			--self.commandManager:setDroneType("DEFAULT")
			--if self.commandManager:getDroneType() then
				--self.commandManager:setDroneType(self.commandManager:getDroneType())
			--else end
			self.commandManager:setDroneType("OFFLINE")
			
			
			
			self.commandManager:clearProtocolBookBox()
			self.commandManager:askCurrentDroneForInfo(self.selected_drone_id)
			
			--[[SIMULATE RECEIVED DRONE REPLY--TEMP
			local partial_profile = {
										drone_type = "RAY",
										settings = {
		
											}
									}
			self:updateCurrentDroneSettingsProfile(partial_profile)
			--SIMULATE RECEIVED DRONE REPLY]]--TEMP
			
		end
		
		self:onLayout()
	end
	
	
	
	root:onLayout()
end



function SwarmManager:updateDroneList(list)
	for i,drone in ipairs(list) do
		self:addToDroneList(drone)
	end
end

function SwarmManager:reply_ping(args)
	self.commandManager:reply_ping(args)
end

function SwarmManager:addToDroneList(drone)
	if (not self.drone_id_whitelist[drone]) then
		self.drone_id_whitelist[drone] = true
		table.insert(self.drone_id_list,tostring(drone))
	end
end

function SwarmManager:updateCurrentDroneSettingsProfile(partial_profile)
	self.commandManager:updateCurrentDroneProfile(partial_profile)
	self.commandManager:switchToSwarmProfile(false)
	self.commandManager:setDroneType(partial_profile.drone_type)
	self.root:onLayout()
end

function SwarmManager:getSelectedDroneType()
	return self.commandManager:getDroneType()
end

return SwarmManager
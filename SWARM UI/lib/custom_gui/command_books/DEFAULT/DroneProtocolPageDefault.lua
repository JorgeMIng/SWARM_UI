local list_manager = require ("lib.list_manager")

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local expect = require "cc.expect"


local common_variables = require "lib.custom_gui.command_books.common_variables"

local DroneProtocolPage = require("lib.custom_gui.command_books."..common_variables.default_page_name..".DroneProtocolPage")

local expect = require "cc.expect"


local DroneProtocolPageDefault = DroneProtocolPage:subclass()


function DroneProtocolPageDefault:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageDefault.superClass.init(self,root,init_config)

	self.droneIDLabel = Label(root,self:getDroneId())
	self.defaultLabel = Label(root,self:getSettings(self.drone_type).default_label)
	self.isDefaultButton = BiStateButton(root,{"IS DEFAULT",
											"NOT DEFAULT"},
											
											{colors.white,
											colors.black},
											
											{colors.red,
											colors.orange},
											self:getSettings(self.drone_type).is_default)

	self:addChild(self.droneIDLabel,false,false,Constants.LinearAlign.CENTER)
	self:addChild(self.defaultLabel,false,false,Constants.LinearAlign.CENTER)
	self:addChild(self.isDefaultButton,false,true,Constants.LinearAlign.CENTER)
	
	function self.isDefaultButton.onPressed()
		self.isDefaultButton:changeState()
		self:setSettings(self.drone_type,"is_default",self.isDefaultButton:getStateBoolean())
		
		root:onLayout()
	end
	
	root:onLayout()
end

function DroneProtocolPageDefault:refresh()
	self.droneIDLabel.text = self:getDroneId()
	self.defaultLabel.text = self:getSettings(self.drone_type).default_label
	self.isDefaultButton:setStateByBoolean(self:getSettings(self.drone_type).is_default)
	self.root:onLayout()
end


return DroneProtocolPageDefault
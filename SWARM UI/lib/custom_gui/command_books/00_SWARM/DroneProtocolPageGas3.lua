local list_manager = require ("lib.list_manager")

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local TextField = require "lib.gui.TextField"
local Button = require "lib.gui.Button"
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local TextFieldActOnKey = require "lib.custom_gui.TextFieldActOnKey"

local utilities = require "lib.utilities"

local MultiStateButton = require "lib.custom_gui.MultiStateButton"


local common_variables = require "lib.custom_gui.command_books.common_variables"
local DroneProtocolPage = require("lib.custom_gui.command_books."..common_variables.default_page_name..".DroneProtocolPage")
local expect = require "cc.expect"
local loader_shapes = require("lib.shapes.load_shapes")



local DroneProtocolPageGas1 = DroneProtocolPage:subclass()


function DroneProtocolPageGas1:load_shapes()
	local colors = self:getColorsShapes(loader_shapes)
	return {list_shapes=loader_shapes,colors=colors}
end

function DroneProtocolPageGas1:getColorsShapes(list_items)
	local color_text={}
	local color_back={}
	for idx,shape in ipairs(list_items)do
		color_text[idx]=colors.black
		color_back[idx]=colors.orange
	end
	return {color_back=color_back,color_text=color_text}
end



function DroneProtocolPageGas1:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageGas1.superClass.init(self,root,init_config)

	self.masterPlayerLabel = Label(root,"MASTER PLAYER:")
	self.masterPlayerTextField = TextFieldActOnKey(root,16,self:getSettings(self.drone_type).master_player)
	
	self.playerMaster = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.playerMaster:addChild(self.masterPlayerLabel,true,false,Constants.LinearAlign.START)
	self.playerMaster:addChild(self.masterPlayerTextField,true,false,Constants.LinearAlign.START)

	self.masterShipLabel = Label(root,"MASTER SHIP ID:")
	self.masterShipTextField = TextFieldActOnKey(root,16,tostring(self:getSettings(self.drone_type).master_ship))
	
	self.shipMaster = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.shipMaster:addChild(self.masterShipLabel,true,false,Constants.LinearAlign.START)
	self.shipMaster:addChild(self.masterShipTextField,true,false,Constants.LinearAlign.START)

	self.droneMasters = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.droneMasters:addChild(self.playerMaster,true,true,Constants.LinearAlign.CENTER)
	self.droneMasters:addChild(self.shipMaster,true,true,Constants.LinearAlign.CENTER)
	

	self:addChild(self.droneMasters,false,true,Constants.LinearAlign.CENTER)
	

	function self:getInfo()
		local drone_id =self:getDroneId()
		if drone_id~="ALL"then
			self.manager:askCurrentDroneForInfo(drone_id)
		end
	end

	
	

	

	function self.masterPlayerTextField.onKey()
		local current_key = self.masterPlayerTextField.key
		if (current_key == keys.enter) then
			self:setSettings(self.drone_type,"master_player",self.masterPlayerTextField:getText())
			self:transmitToCurrentDrone("designate_to_player",self:getSettings(self.drone_type).master_player)
			self:overrideButtons(self:getSettings(self.drone_type))
			self:onLayout()
		end
	end
	
	function self.masterShipTextField.onKey()
		local current_key = self.masterShipTextField.key
		if (current_key == keys.enter) then
			self:setSettings(self.drone_type,"master_ship",self.masterShipTextField:getText())
			self:transmitToCurrentDrone("designate_to_ship",self:getSettings(self.drone_type).master_ship)
			self:overrideButtons(self:getSettings(self.drone_type))
			self:onLayout()
		end
	end

	
	self:initElements({
		self.masterPlayerLabel,
		self.masterShipLabel,
		self.masterPlayerTextField,
		self.masterShipTextField,

	})
	
	root:onLayout()
	
end


function DroneProtocolPageGas1:refresh()
	local page_settings = self:getSettings(self.drone_type)
	self.masterShipTextField:setText(page_settings.master_ship)
	self.masterPlayerTextField:setText(page_settings.master_player)
	self.root:onLayout()
	
end

function DroneProtocolPageGas1:overrideButtons(settings)
	
	
end

return DroneProtocolPageGas1
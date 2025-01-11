local list_manager = require ("lib.list_manager")
local list_manager = require ("lib.utilities")

local IntegerScroller = utilities.IntegerScroller

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local TextFieldActOnKey = require "lib.custom_gui.TextFieldActOnKey"

local common_variables = require "lib.custom_gui.command_books.common_variables"
local DroneProtocolPage = require("lib.custom_gui.command_books."..common_variables.default_page_name..".DroneProtocolPage")
local expect = require "cc.expect"


local DroneProtocolPageTracer1 = DroneProtocolPage:subclass()

function DroneProtocolPageTracer1:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageTracer1.superClass.init(self,root,init_config)

	
	

	self.followButton = BiStateButton(root,{"FOLLOW",
											"STAY"},
											
											{colors.black,
											colors.white},
											
											{colors.orange,
											colors.blue},
											self:getSettings(self.drone_type).dynamic_positioning_mode)
	
	self.pauseButton = BiStateButton(root,{"RUN",
											"PAUSE"},
											
											{colors.black,
											colors.white},
											
											{colors.orange,
											colors.blue},
											self:getSettings(self.drone_type).run_mode)
	
	self.row1 = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.row1:addChild(self.followButton,true,false,Constants.LinearAlign.START)
	self.row1:addChild(self.pauseButton,true,false,Constants.LinearAlign.START)
	
	self.orbitTargetModeButton = BiStateButton(root,{	"ORBIT: PLAYER",
														"ORBIT: SHIP"},
														
														{colors.black,
														colors.white},
														
														{colors.orange,
														colors.blue},
														self:getSettings(self.drone_type).orbit_target_mode == "PLAYER")
														
	self.row2 = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.row2:addChild(self.orbitTargetModeButton,true,false,Constants.LinearAlign.START)
	
	self.masterPlayerLabel = Label(root,"MASTER PLAYER:")
	self.masterPlayerTextField = TextFieldActOnKey(root,16,self:getSettings(self.drone_type).master_player)
	
	self.playerMaster = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.playerMaster:addChild(self.masterPlayerLabel,true,false,Constants.LinearAlign.START)
	self.playerMaster:addChild(self.masterPlayerTextField,true,false,Constants.LinearAlign.START)
	
	self.isSittingButton = BiStateButton(root,{	"Is Sitting On",
												" Is Not Sitting On"},
												
												{colors.black,
												colors.white},
												
												{colors.orange,
												colors.blue},
												self:getSettings(self.drone_type).player_mounting_ship)
	
	self.sittingBtnContainer = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.sittingBtnContainer:addChild(self.isSittingButton,false,false,Constants.LinearAlign.START)
	
	self.masterShipLabel = Label(root,"MASTER SHIP ID:")
	self.masterShipTextField = TextFieldActOnKey(root,16,tostring(self:getSettings(self.drone_type).master_ship))
	
	self.shipMaster = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.shipMaster:addChild(self.masterShipLabel,true,false,Constants.LinearAlign.START)
	self.shipMaster:addChild(self.masterShipTextField,true,false,Constants.LinearAlign.START)
	
	self.droneMasters = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.droneMasters:addChild(self.playerMaster,true,true,Constants.LinearAlign.CENTER)
	self.droneMasters:addChild(self.isSittingButton,false,true,Constants.LinearAlign.CENTER)
	self.droneMasters:addChild(self.shipMaster,true,true,Constants.LinearAlign.CENTER)


	
	
	
	self:addChild(self.row1,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.row2,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.droneMasters,false,true,Constants.LinearAlign.CENTER)

	self.walkPath = BiStateButton(root,{	"WALK",
												"STOP"},
												
												{colors.black,
												colors.white},
												
												{colors.orange,
												colors.blue},
												self:getSettings(self.drone_type).walk)
	
	self:addChild(self.walkPath,false,true,Constants.LinearAlign.CENTER)
	
	function self.walkPath.onPressed()
		self.walkPath:changeState()
		self:setSettings(self.drone_type,"walk",self.walkPath:getStateBoolean())
		self:transmitToCurrentDrone("walk",self:getSettings(self.drone_type).walk)
		self:onLayout()
	end
	
	function self.followButton.onPressed()
		self.followButton:changeState()
		self:setSettings(self.drone_type,"dynamic_positioning_mode",self.followButton:getStateBoolean())
		self:transmitToCurrentDrone("dynamic_positioning_mode",self:getSettings(self.drone_type).dynamic_positioning_mode)
		self:onLayout()
	end

	function self.pauseButton.onPressed()
		self.pauseButton:changeState()
		self:setSettings(self.drone_type,"run_mode",self.pauseButton:getStateBoolean())
		self:transmitToCurrentDrone("run_mode",self:getSettings(self.drone_type).run_mode)
		self:onLayout()
	end

	function self.orbitTargetModeButton.onPressed()
		self.orbitTargetModeButton:changeState()
		self:setSettings(self.drone_type,"orbit_target_mode",self.orbitTargetModeButton:getStateBoolean() and "PLAYER" or "SHIP")
		self:transmitToCurrentDrone("set_target_mode",{is_aim=false,mode=self:getSettings(self.drone_type).orbit_target_mode})
		self:onLayout()
		
	end

	function self.isSittingButton.onPressed()
		self.isSittingButton:changeState()
		self:setSettings(self.drone_type,"player_mounting_ship",self.isSittingButton:getStateBoolean())
		self:transmitToCurrentDrone("player_mounting_ship",self:getSettings(self.drone_type).player_mounting_ship)
		self:onLayout()
	end
	
	function self.masterPlayerTextField.onKey()
		local current_key = self.masterPlayerTextField.key
		if (current_key == keys.enter) then
			self:setSettings(self.drone_type,"master_player",self.masterPlayerTextField:getText())
			self:transmitToCurrentDrone("designate_to_player",self:getSettings(self.drone_type).master_player)
			self:onLayout()
		end
	end
	
	function self.masterShipTextField.onKey()
		local current_key = self.masterShipTextField.key
		if (current_key == keys.enter) then
			self:setSettings(self.drone_type,"master_ship",self.masterShipTextField:getText())
			self:transmitToCurrentDrone("designate_to_ship",self:getSettings(self.drone_type).master_ship)
			self:onLayout()
		end
	end
	
	self:initElements({
		self.walkPath,
		self.followButton,
		self.pauseButton,
		self.orbitTargetModeButton,
		self.isSittingButton,
		self.masterPlayerLabel,
		self.masterShipLabel,
		self.masterPlayerTextField,
		self.masterShipTextField,
	})
	
	root:onLayout()
end

function DroneProtocolPageTracer1:refresh()
	
	local page_settings = self:getSettings(self.drone_type)
	
	self.walkPath:setStateByBoolean(page_settings.walk)
	self.followButton:setStateByBoolean(page_settings.dynamic_positioning_mode)
	self.pauseButton:setStateByBoolean(page_settings.run_mode)
	self.orbitTargetModeButton:setStateByBoolean(page_settings.orbit_target_mode=="PLAYER")
	self.isSittingButton:setStateByBoolean(page_settings.player_mounting_ship)
	self.masterPlayerTextField:setText(page_settings.master_player)
	self.masterShipTextField:setText(page_settings.master_ship)
	
	self.root:onLayout()
end


return DroneProtocolPageTracer1
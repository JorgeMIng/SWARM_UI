local list_manager = require ("lib.list_manager")

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local TextField = require "lib.gui.TextField"
local Button = require "lib.gui.Button"
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local TextFieldActOnKey = require "lib.custom_gui.TextFieldActOnKey"
local DroneProtocolPage = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolPage"

local expect = require "cc.expect"


local DroneProtocolPageTurret1 = DroneProtocolPage:subclass()


function DroneProtocolPageTurret1:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageTurret1.superClass.init(self,root,init_config)

	self.huntButton = BiStateButton(root,{	"CHASE",
											" SENTRY"},
											
											{colors.white,
											colors.black},
											
											{colors.red,
											colors.orange},
											self:getSettings(self.drone_type).hunt_mode)
	
	self.turretButton = BiStateButton(root,{"RUN",
											"PAUSE"},
											
											{colors.black,
											colors.white},
											
											{colors.orange,
											colors.blue},
											self:getSettings(self.drone_type).run_mode)
	
	self.row1 = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.row1:addChild(self.huntButton,true,false,Constants.LinearAlign.START)
	self.row1:addChild(self.turretButton,true,false,Constants.LinearAlign.START)
	
	self.manualButton = BiStateButton(root,{"AUTO",
											"MANUAL"},
											
											{colors.white,
											colors.black},
											
											{colors.red,
											colors.orange},
											self:getSettings(self.drone_type).auto_aim)
	self.followButton = BiStateButton(root,{"FOLLOW",
											"STAY"},
											
											{colors.black,
											colors.white},
											
											{colors.orange,
											colors.blue},
											self:getSettings(self.drone_type).dynamic_positioning_mode)
	
	self.row2 = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.row2:addChild(self.manualButton,true,false,Constants.LinearAlign.START)
	self.row2:addChild(self.followButton,true,false,Constants.LinearAlign.START)
	
	
	self.droneButtons = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.droneButtons:addChild(self.row1,true,true,Constants.LinearAlign.START)
	self.droneButtons:addChild(self.row2,true,true,Constants.LinearAlign.START)
	
	self.aimTargetModeButton = BiStateButton(root,{	"AIM: PLAYER",
													"AIM: SHIP"},
													
													{colors.black,
													colors.white},
													
													{colors.orange,
													colors.blue},
													self:getSettings(self.drone_type).aim_target_mode == "PLAYER")
	self.orbitTargetModeButton = BiStateButton(root,{	"ORBIT: PLAYER",
														"ORBIT: SHIP"},
														
														{colors.black,
														colors.white},
														
														{colors.orange,
														colors.blue},
														self:getSettings(self.drone_type).orbit_target_mode == "PLAYER")
	
	self.targetModes = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.targetModes:addChild(self.aimTargetModeButton,false,true,Constants.LinearAlign.START)
	self.targetModes:addChild(self.orbitTargetModeButton,false,true,Constants.LinearAlign.START)
	
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
	
	self:addChild(self.droneButtons,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.targetModes,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.droneMasters,false,true,Constants.LinearAlign.CENTER)
	
	function self.huntButton.onPressed()
		self.huntButton:changeState()
		self:setSettings(self.drone_type,"hunt_mode",self.huntButton:getStateBoolean())
		self:transmitToCurrentDrone("hunt_mode",self:getSettings(self.drone_type).hunt_mode)

		self:overrideButtons(self:getSettings(self.drone_type).hunt_mode)
		self:onLayout()
	end
	
	function self.turretButton.onPressed()
		self.turretButton:changeState()
		self:setSettings(self.drone_type,"run_mode",self.turretButton:getStateBoolean())
		self:transmitToCurrentDrone("run_mode",self:getSettings(self.drone_type).run_mode)
		self:onLayout()
	end
	
	function self.followButton.onPressed()
		self.followButton:changeState()
		self:setSettings(self.drone_type,"dynamic_positioning_mode",self.followButton:getStateBoolean())
		self:transmitToCurrentDrone("dynamic_positioning_mode",self:getSettings(self.drone_type).dynamic_positioning_mode)
		self:onLayout()
	end
	
	function self.manualButton.onPressed()
		self.manualButton:changeState()
		self:setSettings(self.drone_type,"auto_aim",self.manualButton:getStateBoolean())
		self:transmitToCurrentDrone("auto_aim",self:getSettings(self.drone_type).auto_aim)
		self:onLayout()
	end

	function self.aimTargetModeButton.onPressed()
		self.aimTargetModeButton:changeState()
		self:setSettings(self.drone_type,"aim_target_mode",self.aimTargetModeButton:getStateBoolean() and "PLAYER" or "SHIP")
		self:transmitToCurrentDrone("set_target_mode",{is_aim=true,mode=self:getSettings(self.drone_type).aim_target_mode})
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
		self.huntButton,
		self.turretButton,
		self.manualButton,
		self.aimTargetModeButton,
		self.orbitTargetModeButton,
		self.isSittingButton,
		self.masterPlayerLabel,
		self.masterShipLabel,
		self.masterPlayerTextField,
		self.masterShipTextField,
	})
	
	root:onLayout()
	
end

function DroneProtocolPageTurret1:refresh()
	local page_settings = self:getSettings(self.drone_type)
	
	self.huntButton:setStateByBoolean(page_settings.hunt_mode)
	self.turretButton:setStateByBoolean(page_settings.run_mode)
	self.followButton:setStateByBoolean(page_settings.dynamic_positioning_mode)
	self.manualButton:setStateByBoolean(page_settings.auto_aim)
	self.aimTargetModeButton:setStateByBoolean(page_settings.aim_target_mode=="PLAYER")
	self.orbitTargetModeButton:setStateByBoolean(page_settings.orbit_target_mode=="PLAYER")
	self.isSittingButton:setStateByBoolean(page_settings.player_mounting_ship)
	self.masterShipTextField:setText(page_settings.master_ship)
	self.masterPlayerTextField:setText(page_settings.master_player)
	
	self:overrideButtons(page_settings.hunt_mode)
	self.root:onLayout()
end

function DroneProtocolPageTurret1:overrideButtons(override)
	if (override) then
		self:setSettings(self.drone_type,"run_mode",true)
		self:transmitToCurrentDrone("run_mode",self:getSettings(self.drone_type).run_mode)
		self.turretButton:setStateByBoolean(true)
		self.turretButton.enabled = false
		
		self:setSettings(self.drone_type,"dynamic_positioning_mode",true)
		self:transmitToCurrentDrone("dynamic_positioning_mode",self:getSettings(self.drone_type).dynamic_positioning_mode)
		self.followButton:setStateByBoolean(true)
		self.followButton.enabled = false
		
		self:setSettings(self.drone_type,"auto_aim",true)
		self:transmitToCurrentDrone("auto_aim",self:getSettings(self.drone_type).auto_aim)
		self.manualButton:setStateByBoolean(true)
		self.manualButton.enabled = false
		
	else
		self.turretButton.enabled = true
		self.followButton.enabled = true
		self.manualButton.enabled = true
	end
end

return DroneProtocolPageTurret1
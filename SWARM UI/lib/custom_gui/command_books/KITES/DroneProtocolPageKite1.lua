local list_manager = require ("lib.list_manager")
local list_manager = require ("lib.utilities")

local IntegerScroller = utilities.IntegerScroller

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local TextField = require 'lib.gui.TextField'
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local TextFieldActOnKey = require "lib.custom_gui.TextFieldActOnKey"
local DroneProtocolPage = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolPage"
local expect = require "cc.expect"


local DroneProtocolPageKite1 = DroneProtocolPage:subclass()

function DroneProtocolPageKite1:pageSpecificAction(arguments)
	case =
	{
		["override_rope_length"] = function (args)
			self:ropeLengthOverrideScroll(args.delta)
			return
		end,
		["get_override_rope_length"] = function ()
			return self:getRopeLengthOverrideDistance()
		end,
		["force_refresh_page"] = function ()
			self:refresh()
		end,
		default = function ( )
			print("pageSpecificAction: default case executed")   
		end,
	}
	if case[arguments.protocol] then
		return case[arguments.protocol](arguments.args)
	else
		case["default"]()
	end
end

function DroneProtocolPageKite1:ropeLengthOverrideScroll(delta)
	self.ropeLengthOverride:set(delta)
	self:setSettings(self.drone_type,"rope_length",self:getRopeLengthOverrideDistance())
	self.ropeLength.text = tostring(self:getSettings(self.drone_type).rope_length)
	self:onLayout()
end

function DroneProtocolPageKite1:getRopeLengthOverrideDistance()
	return self.ropeLengthOverride:get()
end

function DroneProtocolPageKite1:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageKite1.superClass.init(self,root,init_config)
	
	self.ropeLengthOverride = IntegerScroller(self:getSettings(self.drone_type).rope_length,20,300)
	self:setSettings(self.drone_type,"rope_length",self.ropeLengthOverride:get())

	

	self.pauseButton = BiStateButton(root,{"RUN",
											"PAUSE"},
											
											{colors.black,
											colors.white},
											
											{colors.orange,
											colors.blue},
											self:getSettings(self.drone_type).run_mode)
	
	self.orbitTargetModeButton = BiStateButton(root,{	"ORBIT: P",
														"ORBIT: S"},
														
														{colors.black,
														colors.white},
														
														{colors.orange,
														colors.blue},
														self:getSettings(self.drone_type).orbit_target_mode == "PLAYER")
														
	self.row1 = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.row1:addChild(self.pauseButton,true,false,Constants.LinearAlign.START)
	self.row1:addChild(self.orbitTargetModeButton,true,false,Constants.LinearAlign.START)
	
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

	self.ropeLengthLabel = Label(self,"ROPE LENGTH:")
	
	self.ropeLength = Label(self,tostring(self:getSettings(self.drone_type).rope_length))
	self.ropeLengthBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.ropeLengthBox:addChild(self.ropeLengthLabel,false,false,Constants.LinearAlign.START)
	self.ropeLengthBox:addChild(self.ropeLength,true,false,Constants.LinearAlign.START)
	
	self.formationLabel = Label(self,"FORMATION:<x,y,z>")

	self.formationTextFieldX = TextField(root,5,"")
	self.formationTextFieldY = TextField(root,5,"")
	self.formationTextFieldZ = TextField(root,5,"")
	
	self.coordBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.formationBox = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.aimRadar = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.orbitRadar = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.divider1 = Label(self,":")
	self.divider2 = Label(self,":")
	self.parenth1 = Label(self,"<")
	self.parenth2 = Label(self,">")

	self.formationBox:addChild(self.formationLabel,true,false,Constants.LinearAlign.CENTER)
	self.formationBox:addChild(self.coordBox,true,false,Constants.LinearAlign.CENTER)
	
	self.coordBox:addChild(self.parenth1,false,false,Constants.LinearAlign.END)
	self.coordBox:addChild(self.formationTextFieldX,true,false,Constants.LinearAlign.CENTER)
	self.coordBox:addChild(self.divider1,false,false,Constants.LinearAlign.END)
	self.coordBox:addChild(self.formationTextFieldY,true,false,Constants.LinearAlign.CENTER)
	self.coordBox:addChild(self.divider2,false,false,Constants.LinearAlign.END)
	self.coordBox:addChild(self.formationTextFieldZ,true,false,Constants.LinearAlign.CENTER)
	self.coordBox:addChild(self.parenth2,false,false,Constants.LinearAlign.END)
	
	self:addChild(self.row1,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.droneMasters,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.ropeLengthBox,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.formationBox,false,true,Constants.LinearAlign.CENTER)
	
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
	
	function self.formationTextFieldX.onChanged()
		local n = self.formationTextFieldX:getText()
		n = n and tonumber(n) or 0
		
		local new_formation = self:getSettings(self.drone_type).orbit_offset
		new_formation.x = n
		self:setSettings(self.drone_type,"orbit_offset",new_formation)
		self:transmitToCurrentDrone("orbit_offset",self:getSettings(self.drone_type).orbit_offset)
		self:onLayout()
	end
	function self.formationTextFieldY.onChanged()
		local n = self.formationTextFieldY:getText()
		n = n and tonumber(n) or 0
		local new_formation = self:getSettings(self.drone_type).orbit_offset
		new_formation.y = n
		self:setSettings(self.drone_type,"orbit_offset",new_formation)
		self:transmitToCurrentDrone("orbit_offset",self:getSettings(self.drone_type).orbit_offset)
		self:onLayout()
	end
	function self.formationTextFieldZ.onChanged()
		local n = self.formationTextFieldZ:getText()
		n = n and tonumber(n) or 0
		local new_formation = self:getSettings(self.drone_type).orbit_offset
		new_formation.z = n
		self:setSettings(self.drone_type,"orbit_offset",new_formation)
		self:transmitToCurrentDrone("orbit_offset",self:getSettings(self.drone_type).orbit_offset)
		self:onLayout()
	end
	
	self:initElements({
		self.pauseButton,
		self.orbitTargetModeButton,
		self.isSittingButton,
		self.masterPlayerLabel,
		self.masterShipLabel,
		self.masterPlayerTextField,
		self.masterShipTextField,
		self.ropeLengthLabel,
		self.ropeLength,
		self.formationLabel,
		self.divider1,
		self.divider2,
		self.parenth1,
		self.parenth2,
	})
	
	root:onLayout()
end

function DroneProtocolPageKite1:setFormationBox(enable,page_settings)
	if (enable) then
		self.formationTextFieldX:setText(tostring(page_settings.orbit_offset.x))
		self.formationTextFieldY:setText(tostring(page_settings.orbit_offset.y))
		self.formationTextFieldZ:setText(tostring(page_settings.orbit_offset.z))
		
		self.children = {}
		self:addChild(self.row1,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.droneMasters,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.ropeLengthBox,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.formationBox,false,true,Constants.LinearAlign.CENTER)
	else
		self.children = {}
		self:addChild(self.row1,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.droneMasters,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.ropeLengthBox,false,true,Constants.LinearAlign.CENTER)
	end
end

function DroneProtocolPageKite1:refresh()
	
	local page_settings = self:getSettings(self.drone_type)
	self.ropeLength.text = tostring(page_settings.rope_length)
	self.ropeLengthOverride:override(page_settings.rope_length)
	
	self.pauseButton:setStateByBoolean(page_settings.run_mode)
	self.orbitTargetModeButton:setStateByBoolean(page_settings.orbit_target_mode=="PLAYER")
	self.isSittingButton:setStateByBoolean(page_settings.player_mounting_ship)
	self.masterPlayerTextField:setText(page_settings.master_player)
	self.masterShipTextField:setText(page_settings.master_ship)
	
	self:setFormationBox(self:getDroneId()~="ALL",page_settings)
	
	
	self.root:onLayout()
end


return DroneProtocolPageKite1
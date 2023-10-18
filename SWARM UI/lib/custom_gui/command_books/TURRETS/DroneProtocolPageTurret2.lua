os.loadAPI("lib/list_manager.lua")
os.loadAPI("lib/utilities.lua")

local IntegerScroller = utilities.IntegerScroller

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local TextField = require "lib.gui.TextField"

local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local DroneProtocolPage = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolPage"

local expect = require "cc.expect"


local DroneProtocolPageTurret2 = DroneProtocolPage:subclass()

function DroneProtocolPageTurret2:pageSpecificAction(arguments)
	case =
	{
		["override_bullet_range"] = function (args)
			self:bulletRangeOverrideScroll(args.delta)
			return
		end,
		["get_override_bullet_range"] = function ()
			return self:getBulletRangeOverrideDistance()
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


function DroneProtocolPageTurret2:bulletRangeOverrideScroll(delta)
	self.bulletRangeOverride:set(delta)
	self:setSettings(self.drone_type,"bullet_range",self:getBulletRangeOverrideDistance())
	self.gunRange.text = tostring(self:getSettings(self.drone_type).bullet_range)
	self:onLayout()
end

function DroneProtocolPageTurret2:getBulletRangeOverrideDistance()
	
	return self.bulletRangeOverride:get()
end

function DroneProtocolPageTurret2:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageTurret2.superClass.init(self,root,init_config)
	
	self.bulletRangeOverride = IntegerScroller(self:getSettings(self.drone_type).bullet_range,15,300)
	self:setSettings(self.drone_type,"bullet_range",self:getBulletRangeOverrideDistance())
	
	
	self.aimRadarLabel = Label(self,"EXTERNAL RADAR:AIM ")
	self.orbitRadarLabel = Label(self,"EXTERNAL RADAR:ORBIT ")
	self.aimRadarButton = BiStateButton(root,{"ON",
											"OFF"},
											
											{colors.white,
											colors.black},
											
											{colors.green,
											colors.orange},
											self:getSettings(self.drone_type).use_external_aim)
	self.orbitRadarButton = BiStateButton(root,{"ON",
											"OFF"},
											
											{colors.white,
											colors.black},
											
											{colors.green,
											colors.orange},
											self:getSettings(self.drone_type).use_external_orbit)
	
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
	
	self.aimRadar:addChild(self.aimRadarLabel,true,false,Constants.LinearAlign.START)
	self.aimRadar:addChild(self.aimRadarButton,true,false,Constants.LinearAlign.END)
											
	self.orbitRadar:addChild(self.orbitRadarLabel,true,false,Constants.LinearAlign.START)
	self.orbitRadar:addChild(self.orbitRadarButton,true,false,Constants.LinearAlign.END)
	
	self.gunRangeLabel = Label(self,"RANGE:")
	self.gunRange = Label(self,tostring(self:getSettings(self.drone_type).bullet_range))
	self.gunRangeBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.gunRangeBox:addChild(self.gunRangeLabel,true,false,Constants.LinearAlign.START)
	self.gunRangeBox:addChild(self.gunRange,true,false,Constants.LinearAlign.START)
	
	self:addChild(self.aimRadar,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.orbitRadar,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.formationBox,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.gunRangeBox,false,true,Constants.LinearAlign.CENTER)
	
	function self.aimRadarButton.onPressed()
		self.aimRadarButton:changeState()
		self:setSettings(self.drone_type,"use_external_aim",self.aimRadarButton:getStateBoolean())
		self:transmitToCurrentDrone("use_external_radar",{is_aim=true,mode=self:getSettings(self.drone_type).use_external_aim})
		self:onLayout()
	end
	
	function self.orbitRadarButton.onPressed()
		self.orbitRadarButton:changeState()
		self:setSettings(self.drone_type,"use_external_orbit",self.orbitRadarButton:getStateBoolean())
		self:transmitToCurrentDrone("use_external_radar",{is_aim=false,mode=self:getSettings(self.drone_type).use_external_orbit})
		self:onLayout()
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
		self.aimRadarButton,
		self.orbitRadarButton,
		self.formationTextFieldX,
		self.formationTextFieldY,
		self.formationTextFieldZ,
		self.aimRadarLabel,
		self.orbitRadarLabel,
		self.formationLabel,
		self.divider1,
		self.divider2,
		self.parenth1,
		self.parenth2,
		self.gunRangeLabel,
		self.gunRange,
	})
	
	root:onLayout()
end



function DroneProtocolPageTurret2:setFormationBox(enable,page_settings)
	if (enable) then
		self.formationTextFieldX:setText(tostring(page_settings.orbit_offset.x))
		self.formationTextFieldY:setText(tostring(page_settings.orbit_offset.y))
		self.formationTextFieldZ:setText(tostring(page_settings.orbit_offset.z))
		
		self.children = {}
		self:addChild(self.aimRadar,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.orbitRadar,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.formationBox,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.gunRangeBox,false,true,Constants.LinearAlign.CENTER)
	else
		self.children = {}
		self:addChild(self.aimRadar,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.orbitRadar,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.gunRangeBox,false,true,Constants.LinearAlign.CENTER)
	end
end

function DroneProtocolPageTurret2:refresh()
	local page_settings = self:getSettings(self.drone_type)
	self.gunRange.text = tostring(page_settings.bullet_range)
	self.bulletRangeOverride:override(page_settings.bullet_range)
	
	self.aimRadarButton:setStateByBoolean(page_settings.use_external_aim)
	self.orbitRadarButton:setStateByBoolean(page_settings.use_external_orbit)
	self:setFormationBox(self:getDroneId()~="ALL",page_settings)
	
	self.root:onLayout()
end


return DroneProtocolPageTurret2

os.loadAPI("lib/list_manager.lua")

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local TextField = require "lib.gui.TextField"

local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local DroneProtocolPage = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolPage"

local expect = require "cc.expect"


local DroneProtocolPageRay2 = DroneProtocolPage:subclass()


function DroneProtocolPageRay2:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageRay2.superClass.init(self,root,init_config)

	self.formationLabel = Label(root,"FORMATION:<x,y,z>")

	self.formationTextFieldX = TextField(root,5,"")
	self.formationTextFieldY = TextField(root,5,"")
	self.formationTextFieldZ = TextField(root,5,"")
	
	self.coordBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.formationBox = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.aimRadar = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.orbitRadar = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.divider1 = Label(root,":")
	self.divider2 = Label(root,":")
	self.parenth1 = Label(root,"<")
	self.parenth2 = Label(root,">")
	
	self.formationBox:addChild(self.formationLabel,true,false,Constants.LinearAlign.CENTER)
	self.formationBox:addChild(self.coordBox,true,false,Constants.LinearAlign.CENTER)
	
	self.coordBox:addChild(self.parenth1,false,false,Constants.LinearAlign.END)
	self.coordBox:addChild(self.formationTextFieldX,true,false,Constants.LinearAlign.CENTER)
	self.coordBox:addChild(self.divider1,false,false,Constants.LinearAlign.END)
	self.coordBox:addChild(self.formationTextFieldY,true,false,Constants.LinearAlign.CENTER)
	self.coordBox:addChild(self.divider2,false,false,Constants.LinearAlign.END)
	self.coordBox:addChild(self.formationTextFieldZ,true,false,Constants.LinearAlign.CENTER)
	self.coordBox:addChild(self.parenth2,false,false,Constants.LinearAlign.END)
	
	
	self.radiusLabel = Label(root,":RADIUS")
	self.radiusTextField = TextField(root,5,"")
	self.orbitRadiusBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.orbitRadiusBox:addChild(self.radiusTextField,false,false,Constants.LinearAlign.END)
	self.orbitRadiusBox:addChild(self.radiusLabel,false,false,Constants.LinearAlign.END)
	
	
	self.heightLabel = Label(root,":HEIGHT")
	self.heightTextField = TextField(root,5,"")
	self.orbitHeightBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.orbitHeightBox:addChild(self.heightTextField,false,false,Constants.LinearAlign.END)
	self.orbitHeightBox:addChild(self.heightLabel,false,false,Constants.LinearAlign.END)
	
	
	self.freqLabel = Label(root,":SWIM FREQUENCY")
	self.freqTextField = TextField(root,5,"")
	self.swimFreqBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.swimFreqBox:addChild(self.freqTextField,false,false,Constants.LinearAlign.END)
	self.swimFreqBox:addChild(self.freqLabel,false,false,Constants.LinearAlign.END)
	
	
	self.ampLabel = Label(root,":SWIM AMPLITUDE")
	self.ampTextField = TextField(root,5,"")
	self.swimAmpBox = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.swimAmpBox:addChild(self.ampTextField,false,false,Constants.LinearAlign.END)
	self.swimAmpBox:addChild(self.ampLabel,false,false,Constants.LinearAlign.END)
	
	
	self:addChild(self.formationBox,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.orbitRadiusBox,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.orbitHeightBox,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.swimFreqBox,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.swimAmpBox,false,true,Constants.LinearAlign.CENTER)
	
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
	
	function self.radiusTextField.onChanged()
		local n = self.radiusTextField:getText()
		n = n and tonumber(n) or 0
		self:setSettings(self.drone_type,"target_radius",n)
		self:transmitToCurrentDrone("target_radius",self:getSettings(self.drone_type).target_radius)
		self:onLayout()
	end
	
	function self.heightTextField.onChanged()
		local n = self.heightTextField:getText()
		n = n and tonumber(n) or 0
		self:setSettings(self.drone_type,"target_height",n)
		self:transmitToCurrentDrone("target_height",self:getSettings(self.drone_type).target_height)
		self:onLayout()
	end
	
	function self.freqTextField.onChanged()
		local n = self.freqTextField:getText()
		n = n and tonumber(n) or 0
		self:setSettings(self.drone_type,"swim_frequency",n)
		self:transmitToCurrentDrone("swim_frequency",self:getSettings(self.drone_type).swim_frequency)
		self:onLayout()
	end
	
	function self.ampTextField.onChanged()
		local n = self.ampTextField:getText()
		n = n and tonumber(n) or 0
		self:setSettings(self.drone_type,"swim_amplitude",n)
		self:transmitToCurrentDrone("swim_amplitude",self:getSettings(self.drone_type).swim_amplitude)
		self:onLayout()
	end
	
	self:initElements({
		self.formationTextFieldX,
		self.formationTextFieldY,
		self.formationTextFieldZ,
		self.formationLabel,
		self.divider1,
		self.divider2,
		self.parenth1,
		self.parenth2,
		self.radiusLabel,
		self.radiusTextField,
		self.heightLabel,
		self.heightTextField,
		self.freqLabel,
		self.freqTextField,
		self.ampLabel,
		self.ampTextField,
	})
	
	root:onLayout()
end

function DroneProtocolPageRay2:setFieldsBox(enable,page_settings)
	if (enable) then
		self.formationTextFieldX:setText(tostring(page_settings.orbit_offset.x))
		self.formationTextFieldY:setText(tostring(page_settings.orbit_offset.y))
		self.formationTextFieldZ:setText(tostring(page_settings.orbit_offset.z))
		
		self.radiusTextField:setText(tostring(page_settings.target_radius))
		self.heightTextField:setText(tostring(page_settings.target_height))
		self.freqTextField:setText(tostring(page_settings.swim_frequency))
		self.ampTextField:setText(tostring(page_settings.swim_amplitude))
		
		self.children = {}
		self:addChild(self.formationBox,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.orbitRadiusBox,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.orbitHeightBox,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.swimFreqBox,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.swimAmpBox,false,true,Constants.LinearAlign.CENTER)
	else
		self.children = {}

	end
end

function DroneProtocolPageRay2:refresh()
	local page_settings = self:getSettings(self.drone_type)
	self:setFieldsBox(self:getDroneId()~="ALL",page_settings)
	self.root:onLayout()
end


return DroneProtocolPageRay2
os.loadAPI("lib/list_manager.lua")
os.loadAPI("lib/utilities.lua")

local IntegerScroller = utilities.IntegerScroller

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local TextFieldActOnKey = require "lib.custom_gui.TextFieldActOnKey"
local DroneProtocolPage = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolPage"
local expect = require "cc.expect"


local DroneProtocolPageSegment2 = DroneProtocolPage:subclass()

function DroneProtocolPageSegment2:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageSegment2.superClass.init(self,root,init_config)

	self.groupLabel = Label(root,"GROUP:"..self:getSettings(self.drone_type).group_id)
	self.segmentNumberLabel = Label(root,"SEGMENT:"..self:getSettings(self.drone_type).segment_number)

	self.seglabel1 = Label(root,"SEGMENT DELAY:")
	self.segmentDelay = TextFieldActOnKey(root,16,"")
	self.segmentDelayBox = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.segmentDelayBox:addChild(self.seglabel1,false,false,Constants.LinearAlign.START)
	self.segmentDelayBox:addChild(self.segmentDelay,false,false,Constants.LinearAlign.START)
	
	self.seglabel2 = Label(root,"GAP LENGTH:")
	self.gapLength = TextFieldActOnKey(root,16,"")
	self.gapLengthBox = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.gapLengthBox:addChild(self.seglabel2,false,false,Constants.LinearAlign.START)
	self.gapLengthBox:addChild(self.gapLength,false,false,Constants.LinearAlign.START)
	
	self:addChild(self.groupLabel,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.segmentNumberLabel,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.segmentDelayBox,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.gapLengthBox,false,true,Constants.LinearAlign.CENTER)
	
	function self.segmentDelay.onKey()
		local current_key = self.segmentDelay.key
		if (current_key == keys.enter) then
			self:setSettings(self.drone_type,"segment_delay",self.segmentDelay:getText())
			
			self:transmitToCurrentDrone("segment_delay",self:getSettings(self.drone_type).segment_delay)
			self:onLayout()
		end
	end
	
	function self.gapLength.onKey()
		local current_key = self.gapLength.key
		if (current_key == keys.enter) then
			self:setSettings(self.drone_type,"gap_length",self.gapLength:getText())
			self:transmitToCurrentDrone("gap_length",self:getSettings(self.drone_type).gap_length)
			self:onLayout()
		end
	end
	
	self:initElements({
		self.seglabel1,
		self.seglabel2,
		self.groupLabel,
		self.segmentNumberLabel,
		self.segmentDelay,
		self.gapLength,
	})
	
	root:onLayout()
end

function DroneProtocolPageSegment2:setInstanceSpecificSettingsBox(enable,page_settings)
	if (enable) then
		self.segmentDelay:setText(tostring(page_settings.segment_delay))
		self.gapLength:setText(tostring(page_settings.gap_length))

		self.children = {}
		self:addChild(self.groupLabel,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.segmentNumberLabel,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.segmentDelayBox,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.gapLengthBox,false,true,Constants.LinearAlign.CENTER)
	else
		self.children = {}
		self:addChild(self.groupLabel,false,true,Constants.LinearAlign.CENTER)
		self:addChild(self.segmentNumberLabel,false,true,Constants.LinearAlign.CENTER)
	end
end

function DroneProtocolPageSegment2:refresh()
	
	local page_settings = self:getSettings(self.drone_type)
	
	self.groupLabel.text = "GROUP:"..tostring(page_settings.group_id)
	self.segmentNumberLabel.text = "SEGMENT:"..tostring(page_settings.segment_number)

	self:setInstanceSpecificSettingsBox(self:getDroneId()~="ALL",page_settings)

	self.root:onLayout()
end


return DroneProtocolPageSegment2
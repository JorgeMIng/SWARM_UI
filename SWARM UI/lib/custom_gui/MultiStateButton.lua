os.loadAPI("lib/list_manager.lua")

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

local expect = require "cc.expect"



local MultiStateButton = Button:subclass()

function MultiStateButton:init(root,statesText,statesTextColor,statesColor)
	expect(1, root, "table")
    expect(2, statesText, "table")
	expect(3, statesTextColor, "table")
	expect(4, statesColor, "table")
	MultiStateButton.superClass.init(self,root,statesText[1])
	
	self.statesText = statesText
	self.statesColor = statesColor
	self.statesTextColor = statesTextColor
	
	self.stateScroller = list_manager.IndexedListScroller()
	self.stateScroller:updateListSize(#self.statesText)
	
	self.text = statesText[1]
	self.color = self.statesColor[1]
	self.textColor = self.statesTextColor[1]
	self:onLayout()
end

function MultiStateButton:getState()
	return self.statesText[self.stateScroller:getCurrentIndex()]
end
function MultiStateButton:getStateIndex()
	return self.stateScroller:getCurrentIndex()
end

function MultiStateButton:changeState()
	self.stateScroller:scrollUp()
	local indx = self.stateScroller:getCurrentIndex()
	self.text = self.statesText[indx]
	self.color = self.statesColor[indx]
	self.textColor = self.statesTextColor[indx]
	self:onLayout()
end

function MultiStateButton:setState(indx)
	if (indx) then
		self.stateScroller.target_index = indx
		self.text = self.statesText[indx]
		self.color = self.statesColor[indx]
		self.textColor = self.statesTextColor[indx]
		self:onLayout()
	end
end



return MultiStateButton
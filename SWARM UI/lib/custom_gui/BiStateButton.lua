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

local expect = require "cc.expect"



local BiStateButton = MultiStateButton:subclass()

function BiStateButton:init(root,statesText,statesTextColor,statesColor,stateBoolean)
	expect(1, root, "table")
    expect(2, statesText, "table")
	expect(3, statesTextColor, "table")
	expect(4, statesColor, "table")
	expect(5, stateBoolean, "boolean")
	BiStateButton.superClass.init(self,root,statesText,statesTextColor,statesColor)
	
	self.stateBool = stateBoolean --true=1: false=2
	self:setStateByBoolean(stateBoolean)
	self:onLayout()
end

function BiStateButton:changeState()
	self.stateScroller:scrollUp()
	local indx = self.stateScroller:getCurrentIndex()
	self.text = self.statesText[indx]
	self.color = self.statesColor[indx]
	self.textColor = self.statesTextColor[indx]
	self.stateBool = indx<2
	self:onLayout()
end

function BiStateButton:getStateBoolean()
	return self.stateBool
end

function BiStateButton:setStateByBoolean(bool)
	self.stateBool = bool
	local indx = bool and 1 or #self.statesText
	self:setState(indx)
end



return BiStateButton
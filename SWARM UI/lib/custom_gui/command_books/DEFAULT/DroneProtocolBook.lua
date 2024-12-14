local list_manager = require ("lib.list_manager")

local Root = require 'lib.gui.Root'
local LinearContainer = require 'lib.gui.LinearContainer'
local Label = require 'lib.gui.Label'
local Button = require 'lib.gui.Button'
local Constants = require 'lib.gui.Constants'

local MultiStateButton = require "lib.custom_gui.MultiStateButton"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local DroneProtocolPage = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolPage"
local DroneProtocolPageDefault = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolPageDefault"

local LinearContainer = require 'lib.gui.LinearContainer'

local expect = require "cc.expect"

local TRIANGLE_LEFT = string.char(Constants.SpecialChars.TRI_LEFT)
local TRIANGLE_RIGHT = string.char(Constants.SpecialChars.TRI_RIGHT)

local IndexedListScroller = list_manager.IndexedListScroller

local DroneProtocolBook = LinearContainer:subclass()

function DroneProtocolBook:init(root,init_config)
	expect(1, root, "table")
	DroneProtocolBook.superClass.init(self,root,Constants.LinearAxis.VERTICAL,0,0)
	
	init_config = init_config or {}
	self.drone_id = init_config.drone_id or "ALL"
	self.drone_type = init_config.drone_type or "DEFAULT"
	init_config.drone_type = self.drone_type
	self.protocol_pages = init_config.protocol_pages or {
														DroneProtocolPageDefault(root,init_config),
														Label(root,"DEFAULT COMMANDS 2"),
														Label(root,"DEFAULT COMMANDS 3"),
														}
	
	self.pageScroller = IndexedListScroller()
	self.pageScroller:updateListSize(#self.protocol_pages)
	
	self.prevBtn = Button(root,TRIANGLE_LEFT)
	self.nextBtn = Button(root,TRIANGLE_RIGHT)
	self.pageTurner = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.pageTurner:addChild(self.prevBtn,true,false,Constants.LinearAlign.START)
	self.pageTurner:addChild(self.nextBtn,true,false,Constants.LinearAlign.START)
	self:addChild(self.pageTurner,false,true,Constants.LinearAlign.START)
	
	self.pageBox = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self:addChild(self.pageBox,true,true,Constants.LinearAlign.START)
	
	self.pageBox:addChild(self.protocol_pages[1],true,true,Constants.LinearAlign.CENTER)
	
	function self.prevBtn.onPressed()
		self:scrollPage(true)
	end
	function self.nextBtn.onPressed()
		self:scrollPage(false)
	end
	
	self:initElements({
		self.prevBtn,
		self.nextBtn
	})
	
	root:onLayout()
end

--OVERRIDABLE--
function DroneProtocolBook:overridePageScroller(scroller)
	
end
--OVERRIDABLE--

function DroneProtocolBook:scrollPage(scroll_up)
	if (scroll_up) then
		self.pageScroller:scrollDown()
	else
		self.pageScroller:scrollUp()
	end
	self:overridePageScroller(self.pageScroller)
	self:turnToPage(self.pageScroller:getCurrentIndex())
end

function DroneProtocolBook:styleElement(element)
	if (element:instanceof(Button)) then
		element.pushedColor = colors.lightBlue
	end
end

function DroneProtocolBook:initElements(elements)
	for _,element in ipairs(elements) do
		self:styleElement(element)
	end
end

function DroneProtocolBook:clearPage()
	self.pageBox.children = {}
	self.root:onLayout()
end
	
function DroneProtocolBook:refreshPage()
	self.pageBox.children = {}
	local current_page = self.protocol_pages[self.pageScroller:getCurrentIndex()]
	current_page:refresh()
	self.pageBox:addChild(current_page,true,true,Constants.LinearAlign.CENTER)
	self.root:onLayout()
end

function DroneProtocolBook:turnToPage(page)
	if (self.protocol_pages[page]) then
		self.pageBox.children = {}
		self.pageBox:addChild(self.protocol_pages[page],true,true,Constants.LinearAlign.CENTER)
		self.root:onLayout()
	end
end

function DroneProtocolBook:updatePages(drone_profile)
	self.drone_id = drone_profile.drone_id
	for i,page in ipairs(self.protocol_pages) do
		if (page:instanceof(DroneProtocolPage)) then
			page:update(drone_profile)
		end
	end
end



return DroneProtocolBook
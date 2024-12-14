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
local BiStateButton = require "lib.custom_gui.BiStateButton"


local DroneProtocolBook = require 'lib.custom_gui.command_books.DEFAULT.DroneProtocolBook'
local DroneProtocolPageRay1 = require "lib.custom_gui.command_books.CARPET_RAYS.DroneProtocolPageRay1"
local DroneProtocolPageRay2 = require "lib.custom_gui.command_books.CARPET_RAYS.DroneProtocolPageRay2"

local expect = require "cc.expect"


local DroneProtocolBookCarpetRay = DroneProtocolBook:subclass()


function DroneProtocolBookCarpetRay:init(root,page_init_config)
	expect(1, root, "table")
	
	local book_init_config = {
		drone_id = page_init_config.drone_id,
		drone_type = "RAY",
		protocol_pages = {
			DroneProtocolPageRay1(root,page_init_config),
			DroneProtocolPageRay2(root,page_init_config),
		}
	}
	
	DroneProtocolBookCarpetRay.superClass.init(self,root,book_init_config)

	root:onLayout()
end

function DroneProtocolBookCarpetRay:overridePageScroller(scroller)
	if (self.drone_id == "ALL") then
		scroller:setCurrentIndex(1)
	end
end

return DroneProtocolBookCarpetRay
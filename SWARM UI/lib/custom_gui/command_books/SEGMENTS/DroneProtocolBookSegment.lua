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
local DroneProtocolPageSegment1 = require "lib.custom_gui.command_books.SEGMENTS.DroneProtocolPageSegment1"
local DroneProtocolPageSegment2 = require "lib.custom_gui.command_books.SEGMENTS.DroneProtocolPageSegment2"

local expect = require "cc.expect"


local DroneProtocolBookSegment = DroneProtocolBook:subclass()


function DroneProtocolBookSegment:init(root,init_config)
	expect(1, root, "table")
	
	local init_config = {
		drone_type = "SEGMENT",
		protocol_pages = {
			DroneProtocolPageSegment1(root,init_config),
			DroneProtocolPageSegment2(root,init_config),
		}
	}
	
	DroneProtocolBookSegment.superClass.init(self,root,init_config)

	root:onLayout()
end

return DroneProtocolBookSegment
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


local common_variables = require "lib.custom_gui.command_books.common_variables"
local DroneProtocolBook = require("lib.custom_gui.command_books."..common_variables.default_page_name..".DroneProtocolBook")


local dir_file = debug.getinfo(1).source:match("@?(.*/)")  -- Obtener la ruta completa
-- Eliminar la barra inicial, si existe (por el prefijo @)
if dir_file:sub(1, 1) == "/" then
    dir_file = dir_file:sub(2)
end
dir_file=dir_file:gsub("/", ".")

local DroneProtocolPageSegment1 = require(dir_file.."DroneProtocolPageSegment1")
local DroneProtocolPageSegment2 = require(dir_file.."DroneProtocolPageSegment2")


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
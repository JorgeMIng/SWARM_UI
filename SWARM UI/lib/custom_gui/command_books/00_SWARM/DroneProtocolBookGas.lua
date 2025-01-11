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

local DroneProtocolBook = require 'lib.custom_gui.command_books.DEFAULT.DroneProtocolBook'

local dir_file = debug.getinfo(1).source:match("@?(.*/)")  -- Obtener la ruta completa
-- Eliminar la barra inicial, si existe (por el prefijo @)
if dir_file:sub(1, 1) == "/" then
    dir_file = dir_file:sub(2)
end
dir_file=dir_file:gsub("/", ".")

local DroneProtocolPageGas1 = require(dir_file.."DroneProtocolPageGas1")
local DroneProtocolPageGas2 = require(dir_file.."DroneProtocolPageGas2")
local DroneProtocolPageGas3 = require(dir_file.."DroneProtocolPageGas3")
local DroneProtocolPageGas4 = require(dir_file.."DroneProtocolPageGas4")

local expect = require "cc.expect"


local DroneProtocolBookGas = DroneProtocolBook:subclass()


function DroneProtocolBookGas:init(root,page_init_config)
	expect(1, root, "table")

	local book_init_config = {
		drone_type = "GAS",
		protocol_pages = {
			DroneProtocolPageGas1(root,page_init_config),
			DroneProtocolPageGas2(root,page_init_config),
			DroneProtocolPageGas3(root,page_init_config),
			--DroneProtocolPageGas4(root,page_init_config),
		},
		com_channels = {}
	}
	
	DroneProtocolBookGas.superClass.init(self,root,book_init_config)

	root:onLayout()
end

return DroneProtocolBookGas
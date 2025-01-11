local list_manager = require ("lib.list_manager")

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local TextField = require "lib.gui.TextField"
local Button = require "lib.gui.Button"
local Object = require "lib.object.Object"
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"

local expect = require "cc.expect"


local DroneProtocolPage = LinearContainer:subclass()


function DroneProtocolPage:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPage.superClass.init(self,root,Constants.LinearAxis.VERTICAL,1,1)
	
	self.com_channels = init_config.com_channels
	self.drone_type = init_config.drone_type
	self.drone_profile = DroneSettingsProfile(init_config.settings)
	self.manager=init_config.manager
	
end


--OVERRIDABLE--
function DroneProtocolPage:refresh()

end

function DroneProtocolPage:styleElement(element)
	if (element:instanceof(Button)) then
		element.pushedColor = colors.lightBlue
	elseif (element:instanceof(Label)) then
		element.backgroundColor = colors.black
		element.textColor = colors.orange
	end
end

function DroneProtocolPage:pageSpecificAction(arguments)
	case =
	{
		["protocol1_here"] = function (args)
			--page specific task here
			return
		end,
		["protocol2_here"] = function ()
			return --page specific task here
		end,
		default = function ( )
			print("pageSpecificAction: default case executed")   
		end,
	}
	if case[arguments.protocol] then
		case[arguments.protocol](arguments)
	else
		case["default"]()
	end
end
--OVERRIDABLE--

function DroneProtocolPage:initElements(elements)
	for _,element in ipairs(elements) do
		self:styleElement(element)
	end
end

--function DroneProtocolPage:transmitToCurrentDrone(cmd,args)
--	modem.transmit(self.com_channels.REMOTE_TO_DRONE_CHANNEL, self.com_channels.DRONE_TO_REMOTE_CHANNEL, 
--	{drone_id=self:getDroneId(),msg={cmd=cmd,drone_type=self.drone_type,args=args}})
	
--end


function DroneProtocolPage:transmitToCurrentDrone(cmd,args)
	self.manager:transmitToDroneType(self:getDroneId(),cmd,args)	
end


function DroneProtocolPage:transmitToCorrectDrone(cmd,args)
	if self:getDroneId()=="ALL"then
		self.manager:commandSwarm(cmd,args)
	else
		self.manager:transmitToDroneType(self:getDroneId(),cmd,args)
	end
end



function DroneProtocolPage:getSettings(drone_type)
	return self.drone_profile.settings_profile[drone_type]
end

function DroneProtocolPage:setSettings(drone_type,variable_key,new_value)
	self.drone_profile.settings_profile[drone_type][variable_key] = new_value
	--print("orbit mode: ",self.drone_profile.settings_profile[drone_type][variable_key])
		--error()
end

function DroneProtocolPage:getDroneId()
	return self.drone_profile.drone_id
end

function DroneProtocolPage:updateDroneProfile(drone_profile)
	self.drone_profile = drone_profile
end

function DroneProtocolPage:update(drone_profile)
	
	self:updateDroneProfile(drone_profile)
	self:refresh()
end

local default_color_label = colors.black
local default_color_label_text = colors.orange

local default_color_list = colors.orange
local default_color_list_selected = colors.blue
local default_color_list_selected_text = colors.orange



return DroneProtocolPage
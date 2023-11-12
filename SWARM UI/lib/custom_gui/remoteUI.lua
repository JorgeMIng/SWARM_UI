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
local MultiStateButton = require "lib.custom_gui.MultiStateButton"
local BiStateButton = require "lib.custom_gui.BiStateButton"



local SwarmManager = require "lib.custom_gui.SwarmManager"

local remoteUI = Root:subclass()

local default_color_button = colors.orange
local default_color_button_text = colors.black
local default_color_button_pushed = colors.lightBlue
local default_color_button_pushed_text = colors.white

local default_color_label = colors.black
local default_color_label_text = colors.orange

local default_color_list = colors.orange
local default_color_list_selected = colors.blue
local default_color_list_selected_text = colors.orange

function remoteUI:initButton(btn)
	--btn.color = default_color_button
	--btn.textColor = default_color_button_text
	btn.pushedColor = default_color_button_pushed
end

function remoteUI:initLabel(lbl)
	lbl.backgroundColor = default_color_label
	lbl.textColor = default_color_label_text
end

function remoteUI:initList(lst)
	lst.bgColor = default_color_list
	lst.selBgColor = default_color_list_selected
	lst.selTextColor = default_color_list_selected_text
	lst.selected = 1
end

function remoteUI:init(settings,drone_list,com_channels)
	remoteUI.superClass.init(self)
	self.drone_id_list = {"ALL"}
	self.drone_id_whitelist = {}
	self:updateDroneList(drone_list)
	
	self.com_channels = com_channels
	
	
	local arguments = {
		com_channels = com_channels,
		drone_id_list = drone_list,
		selected_drone_id = "ALL",--"421"
		settings = settings,
	}
	self.swarmManager = SwarmManager(self,arguments)
	
	self:addChild(self.swarmManager)
	
	self.backgroundColor = colors.black
	self:onLayout()
end

function remoteUI:getSelectedDroneID()
	return self.swarmManager.selected_drone_id
end

function remoteUI:getSelectedDroneType()
	return self.swarmManager:getSelectedDroneType()
end

function remoteUI:updateDroneList(list)
	for i,drone in ipairs(list) do
		self:addToDroneList(drone)
	end
end

function remoteUI:addToDroneList(drone)
	if (not self.drone_id_whitelist[drone]) then
		self.drone_id_whitelist[drone] = true
		table.insert(self.drone_id_list,tostring(drone))
	end
end

function remoteUI:transmitToDrone(drone,cmd,args)
	self.swarmManager.commandManager:transmitToDrone(drone,cmd,args)
end

function remoteUI:transmitToDroneType(drone,cmd,args)
	self.swarmManager.commandManager:transmitToDroneType(drone,cmd,args)
end

function remoteUI:commandSwarm(cmd,args,delay_interval)
	self.swarmManager.commandManager:commandSwarm(cmd,args,delay_interval)
end

function remoteUI:executePageSpecificAction(book_n,page_n,protocol,args)
	local bundled_args = {protocol=protocol,args=args}
	local ret_val = self.swarmManager.commandManager.drone_protocol_books[book_n].protocol_pages[page_n]:pageSpecificAction(bundled_args)
	if (ret_val) then
		return ret_val
	end
end

function remoteUI:droneToModemActions(msg)
	case =
	{
		["drone_settings_update"] = function (args)
			--self:updatePages(args.settings,false)
			self.swarmManager:updateCurrentDroneSettingsProfile(args.partial_profile)
			
		end,
		["drone_position_update"] = function (args)

		end,
		["register_drone"] = function (args)
			--self:addToDroneList(args.drone_ID)
		end,
		default = function ( )
			--print("default case executed")   
		end,
	}
	if case[msg.protocol] then
		case[msg.protocol](msg)
	else
		case["default"]()
	end
end

local keyBinds = {
	CHANGE_AUTO_AIM_TARGET_LEFT = {keys.left,keys.a},
	CHANGE_AUTO_AIM_TARGET_RIGHT = {keys.right,keys.d},
	INCREMENT_AIM_DISTANCE = {keys.up,keys.w},
	DECREMENT_AIM_DISTANCE = {keys.down,keys.s},
	WEAPONS_ON = {keys.space},
	WEAPONS_OFF = {keys.leftShift}
}

function remoteUI:scrollActionVertical(delta)
	local selected_drone_type = self:getSelectedDroneType()
	
	if ( selected_drone_type == "TURRET") then
		local range_mode = self:executePageSpecificAction(1,2,"get_range_finding_mode")
		if (range_mode==1) then
			self:executePageSpecificAction(1,2,"override_bullet_range",{delta=delta})
			local override_range = self:executePageSpecificAction(1,2,"get_override_bullet_range")
			if (self:getSelectedDroneID() ~= "ALL") then
				self:transmitToDroneType(self:getSelectedDroneID(),"override_bullet_range",override_range)
			else
				self:commandSwarm("override_bullet_range",override_range)	
			end
		end
	elseif (selected_drone_type == "KITE") then
		self:executePageSpecificAction(2,1,"override_rope_length",{delta=delta})
		local override_range = self:executePageSpecificAction(2,1,"get_override_rope_length")
		if (self:getSelectedDroneID() ~= "ALL") then
			self:transmitToDroneType(self:getSelectedDroneID(),"override_rope_length",override_range)
		else
			self:commandSwarm("override_rope_length",override_range)	
		end
	end
end



function remoteUI:keyActions(key)
	case =
	{
		[keyBinds.CHANGE_AUTO_AIM_TARGET_LEFT[1]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			
			self.focus = nil
			if (self:getSelectedDroneID() ~= "ALL") then
				self:transmitToDroneType(self:getSelectedDroneID(),"scroll_aim_target",1)
			else
				self:commandSwarm("scroll_aim_target",1)
			end
		end,
		[keyBinds.CHANGE_AUTO_AIM_TARGET_RIGHT[1]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			if (self:getSelectedDroneID() ~= "ALL") then
				self:transmitToDroneType(self:getSelectedDroneID(),"scroll_aim_target",-1)
			else
				self:commandSwarm("scroll_aim_target",-1)
			end
		end,
		[keyBinds.INCREMENT_AIM_DISTANCE[1]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			self:scrollActionVertical(5)
		end,
		[keyBinds.DECREMENT_AIM_DISTANCE[1]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			self:scrollActionVertical(-5)
		end,
		[keyBinds.CHANGE_AUTO_AIM_TARGET_LEFT[2]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			if (self:getSelectedDroneID() ~= "ALL") then
				self:transmitToDroneType(self:getSelectedDroneID(),"scroll_aim_target",1)
			else
				self:commandSwarm("scroll_aim_target",1)
			end
		end,
		[keyBinds.CHANGE_AUTO_AIM_TARGET_RIGHT[2]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			if (self:getSelectedDroneID() ~= "ALL") then
				self:transmitToDroneType(self:getSelectedDroneID(),"scroll_aim_target",-1)
			else
				self:commandSwarm("scroll_aim_target",-1)
			end
		end,
		[keyBinds.INCREMENT_AIM_DISTANCE[2]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			self:scrollActionVertical(5)
		end,
		[keyBinds.DECREMENT_AIM_DISTANCE[2]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			self:scrollActionVertical(-5)
		end,
		[keyBinds.WEAPONS_ON[1]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			if (self:getSelectedDroneID() ~= "ALL") then
				self:transmitToDroneType(self:getSelectedDroneID(),"weapons_free",true)
			else
				local diff_t = 0
				local sync_groups = 2
				for i,drone in ipairs(self.drone_id_list) do
					self:transmitToDrone(drone,"burst_fire",{mode=true,delay=diff_t})
					diff_t = math.modf(diff_t+1,sync_groups)
				end
			end
			
		end,
		[keyBinds.WEAPONS_OFF[1]] = function ()
			if (self.focus) then
				if (self.focus:instanceof(TextField)) then
					return
				end
			end
			self.focus = nil
			if (self:getSelectedDroneID() ~= "ALL") then
				self:transmitToDroneType(self:getSelectedDroneID(),"weapons_free",false)
			else
				self:commandSwarm("weapons_free",false)
			end
		end,
		default = function ( )
			--print("default case executed")   
		end,
	}
	if case[key] then
		case[key]()
	else
		case["default"]()
	end
end


function remoteUI:mainLoop()
    self:show()
    while true do
        evt = {os.pullEventRaw()}
        self:onEvent(evt)
        if evt[1] == "terminate" then
            break
		elseif evt[1] =="modem_message" then
			if (evt[5].drone_ID) then
				if (self.drone_id_whitelist[tostring(evt[5].drone_ID)]) then
					self:droneToModemActions(evt[5])
				end
			end
			
		elseif evt[1] =="key" then
			self:keyActions(evt[2])
        end
    end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1,1)
    term.clear()
end

return remoteUI
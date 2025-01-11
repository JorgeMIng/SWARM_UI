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



local LinearContainer = require 'lib.gui.LinearContainer'

local WifiBook = require 'lib.custom_gui.WifiBook'


local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"

local expect = require "cc.expect"

local dir_utilities = require "lib.dir_utilities"



local CommandManager = LinearContainer:subclass()

local IndexedListScroller = list_manager.IndexedListScroller


local WIFI_CHAR = string.char(8)



function CommandManager:init(root,init_arguments)
	expect(1, root, "table")

	CommandManager.superClass.init(self,root,Constants.LinearAxis.VERTICAL,0,0)
	self.drone_id_list = init_arguments.drone_id_list
	self.drone_id_whitelist = init_arguments.drone_id_whitelist
	self.com_channels = init_arguments.com_channels
	--init_arguments.settings

	self.swarm_profile = DroneSettingsProfile(init_arguments.settings)
	self.current_drone_profile = DroneSettingsProfile(init_arguments.settings)

	self.secret_id=init_arguments.config.secret_id
	local config = init_arguments.config
	
	local drone_metadata = self.swarm_profile:getMetadata()
	local drone_types = self.swarm_profile:getOrderedTypes()
	local filter_drone_types={}

	self.drone_types_index = {}
	self.drone_protocol_books={}

	local drone_type_text_state_colors = {}
											
	local drone_type_button_state_colors = {}
	local skip=0

	for idx,drone_type in ipairs(drone_types) do 


		local protocol_class = require(drone_metadata[drone_type].get_protocol_book_class_dir)
		local succes=false
		local result=nil
		
		if not config.error_debug then
			local succes,result = pcall(protocol_class,root,{
				com_channels=self.com_channels,
				drone_type = drone_type,
				settings=init_arguments.settings,
				manager=self
			})
		else
			result=protocol_class(root,{
				com_channels=self.com_channels,
				drone_type = drone_type,
				settings=init_arguments.settings,
				manager=self
			})
			succes=true

		end
		


		if succes then
			self.drone_protocol_books[drone_type]=result

			self.drone_types_index[drone_type]=idx

			drone_type_text_state_colors[idx-skip]=drone_metadata[drone_type].textColor or colors.black 
			drone_type_button_state_colors[idx-skip]=drone_metadata[drone_type].backColor or colors.orange

			filter_drone_types[idx-skip]=drone_type
		else
			skip=skip+1
		end
		succes=false
		result=nil

	end

	self.wifi_book = WifiBook(root,{
		com_channels=self.com_channels,
		drone_type = nil,
		manager=self
	})

	
	--self.drone_protocol_books["WIFI"]=wifi_book


	

	
	self.bookScroller = IndexedListScroller()
	self.bookScroller:updateListSize(#self.drone_protocol_books)
	
	
	--configure when adding new control protocols--
	
	
	print(filter_drone_types[1])
	self.droneTypeButton = MultiStateButton(root,
											filter_drone_types,
											drone_type_text_state_colors,
											drone_type_button_state_colors)
	

	--print(self.droneTypeButton.text)
							
	self.setSwarmButton = Button(root,"Set Swarm")
	self.wifiPanel = Button(root,WIFI_CHAR)
	self.wifiPanel.color=colors.green

	self.headerBox = LinearContainer(self,Constants.LinearAxis.HORIZONTAL,0,0)
	self.headerBox:addChild(self.droneTypeButton,true,false,Constants.LinearAlign.START)
	self.headerBox:addChild(self.setSwarmButton,true,false,Constants.LinearAlign.START)
	self.headerBox:addChild(self.wifiPanel,false,false,Constants.LinearAlign.END)

	self:addChild(self.headerBox,false,true,Constants.LinearAlign.START)
	
	self.protocolBookBox = LinearContainer(self,Constants.LinearAxis.HORIZONTAL,0,0)
	
	
	self.protocolBookBox:addChild(self.drone_protocol_books[filter_drone_types[1]],true,true,Constants.LinearAlign.START)
	

	self:addChild(self.protocolBookBox,true,true,Constants.LinearAlign.START)
	
	self:updateBookProfile(self.swarm_profile)
	
	function self.droneTypeButton.onPressed()
		self.droneTypeButton:changeState()
		self:refreshProtocolBookBox()
		
	end

	function self.wifiPanel.onPressed()
		self:openWifiPanel(self.dron)
		self.root:onLayout()
		
	end

	function CommandManager.openWifiPanel(drone_type)


		self.protocolBookBox.children = {}
		if (self.wifi_book) then
			self.wifi_book:setDroneType(self.droneTypeButton.text)	
			self.wifi_book:createLists(self.drone_id_list)
			self.protocolBookBox:addChild(self.wifi_book,true,true,Constants.LinearAlign.START)
		end
	end

	function CommandManager:reply_ping(args)
		self.wifi_book:reply_ping(args)
	end

	
	
	function self.setSwarmButton.onPressed()
		self:commandSwarm("set_settings",self.swarm_profile:getDroneTypeProfile(self.droneTypeButton:getState()))
	end

	function self.setSwarmButton.onPressed()
		self:commandSwarm("set_settings",self.swarm_profile:getDroneTypeProfile(self.droneTypeButton:getState()))
	end
	
	
	self.setSwarmButton.pushedColor = colors.lightBlue
	self.droneTypeButton:setState(1)
	--self:setDroneType("TURRET")
	
	root:onLayout()
end

function debugProbe(msg,sendChannel,dumpChaneel)--transmits to debug channel
	modem.transmit(sendChannel,dumpChaneel, msg)
end


function CommandManager:transmitToDroneType(drone,cmd,args)
	modem.transmit(self.com_channels.REMOTE_TO_DRONE_CHANNEL, self.com_channels.DRONE_TO_REMOTE_CHANNEL, 
	{drone_id=drone,msg={cmd=cmd,drone_type=self.droneTypeButton:getState(),args=args}})
end

function CommandManager:transmitToDrone(drone,cmd,args)
	modem.transmit(self.com_channels.REMOTE_TO_DRONE_CHANNEL, self.com_channels.DRONE_TO_REMOTE_CHANNEL, 
	{drone_id=drone,msg={cmd=cmd,args=args}})
end

function CommandManager:broadcast(cmd,args)
	modem.transmit(self.com_channels.REMOTE_TO_DRONE_CHANNEL, self.com_channels.DRONE_TO_REMOTE_CHANNEL, 
	{broadcast=1,id=self.secret_id,msg={cmd=cmd,args=args}})
end

function CommandManager:commandSwarm(cmd,args,delay_interval)
	
	if (delay_interval ~= nil) then
		for i,drone in ipairs(self.drone_id_list) do
			self:transmitToDroneType(drone,cmd,args)
			os.sleep(delay_interval)
		end
		return
	end
	for i,drone in ipairs(self.drone_id_list) do
		self:transmitToDroneType(drone,cmd,args)
	end
end

function CommandManager:askCurrentDroneForInfo(drone)
	self:transmitToDrone(drone,"get_settings_info")
end


function CommandManager:enableDroneTypeButton(mode)
	self.droneTypeButton.enabled = mode
end

function CommandManager:enableWiFiButton(mode)
	self.wifiPanel.enabled = mode
end

function CommandManager:enableSetSwarmButton(mode)
	self.setSwarmButton.enabled = mode
end





function CommandManager:switchToSwarmProfile(mode)
	if (mode) then
		
		self:updateBookProfile(self.swarm_profile)
		
	else

		
		self:updateBookProfile(self.current_drone_profile)
	end
end

function CommandManager:updateCurrentDroneId(drone_id)
	self.current_drone_profile.drone_id = drone_id
end

function CommandManager:updateBookProfile(drone_profile)
	
	
	

	for key,book in pairs(self.drone_protocol_books) do
		if (drone_profile) then
			book:updatePages(drone_profile)
		end
	end

end

function CommandManager:clearProtocolBookBox()
	self.protocolBookBox.children = {}
	self.root:onLayout()
end

function CommandManager:refreshProtocolBookBox()

	self:setBook(self.droneTypeButton:getState())
	
	self.root:onLayout()
end

function CommandManager:updateCurrentDroneProfile(profile)
	self.current_drone_profile:setProfile(profile.drone_type,profile.settings)
end

function CommandManager:refreshDroneTypeButton()
	self.droneTypeButton:setState(self.droneTypeButton:getStateIndex())
	self.root:onLayout()
end

function CommandManager:setDroneType(drone_type)
	
	self.droneTypeButton.text = drone_type

	
	self.droneTypeButton:setState(self.drone_types_index[drone_type])
	
	self:setBook(drone_type)
end

function CommandManager:getDroneType()
	return self.droneTypeButton:getState()
end

function CommandManager:setBook(drone_type)
	self.protocolBookBox.children = {}
	if (self.drone_protocol_books[drone_type]) then	
		self.protocolBookBox:addChild(self.drone_protocol_books[drone_type],true,true,Constants.LinearAlign.START)
	end
	
	self.root:onLayout()
end



return CommandManager
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

local DroneProtocolBookTurret = require "lib.custom_gui.command_books.TURRETS.DroneProtocolBookTurret"
local DroneProtocolBookKite = require "lib.custom_gui.command_books.KITES.DroneProtocolBookKite"
local DroneProtocolBookCarpetRay = require "lib.custom_gui.command_books.CARPET_RAYS.DroneProtocolBookCarpetRay"
local DroneProtocolBookSegment = require "lib.custom_gui.command_books.SEGMENTS.DroneProtocolBookSegment"
local DroneProtocolBookTracer = require "lib.custom_gui.command_books.TRACERS.DroneProtocolBookTracer"
local DroneProtocolBook = require "lib.custom_gui.command_books.DEFAULT.DroneProtocolBook"

local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"

local expect = require "cc.expect"



local CommandManager = LinearContainer:subclass()

local IndexedListScroller = list_manager.IndexedListScroller



function CommandManager:init(root,init_arguments)
	expect(1, root, "table")

	CommandManager.superClass.init(self,root,Constants.LinearAxis.VERTICAL,0,0)
	self.drone_id_list = init_arguments.drone_id_list
	self.com_channels = init_arguments.com_channels
	--init_arguments.settings
	self.swarm_profile = DroneSettingsProfile()
	self.current_drone_profile = DroneSettingsProfile()
	
	--configure when adding new control protocols--
	self.current_drone_profile:addDroneSpecificSettings("TURRET",{
																	orbit_offset = vector.new(0,0,0),
																	})
	self.current_drone_profile:addDroneSpecificSettings("RAY",{
																	orbit_offset = vector.new(0,0,0),
																	target_radius = 7,
																	target_height = 3,
																	swim_frequency = 5,
																	swim_amplitude = 0.5,
																	})
	self.current_drone_profile:addDroneSpecificSettings("KITE",{
																	orbit_offset = vector.new(0,0,0),
																	})
	
	self.drone_type_index_map = {}
	local drone_type_list = {	"TURRET",
								"KITE",
								"RAY",
								"SEGMENT",
								"TRACER",
								"DEFAULT"}

	for index,drone_type in ipairs(drone_type_list) do
		self.drone_type_index_map[drone_type] = index
	end
	
	self.drone_protocol_books = {
		DroneProtocolBookTurret(root,{
										com_channels=self.com_channels,
										drone_type = drone_type_list[1]
									}),
		DroneProtocolBookKite(root,{
										com_channels=self.com_channels,
										drone_type = drone_type_list[2]
									}),
		DroneProtocolBookCarpetRay(root,{
										com_channels=self.com_channels,
										drone_type = drone_type_list[3]
									}),
		DroneProtocolBookSegment(root,{
										com_channels=self.com_channels,
										drone_type = drone_type_list[4]
									}),
		DroneProtocolBookTracer(root,{
										com_channels=self.com_channels,
										drone_type = drone_type_list[5]
									}),
		DroneProtocolBook(root,{
								com_channels = self.com_channels
								}),
	}
	
	self.bookScroller = IndexedListScroller()
	self.bookScroller:updateListSize(#self.drone_protocol_books)
	
	local drone_type_text_state_colors = {	colors.black,
											colors.black,
											colors.black,
											colors.black,
											colors.black,
											colors.black}
											
	local drone_type_button_state_colors = {colors.orange,
											colors.orange,
											colors.orange,
											colors.orange,
											colors.orange,
											colors.orange}
	--configure when adding new control protocols--
	
	
	
	self.droneTypeButton = MultiStateButton(root,
											drone_type_list,
											drone_type_text_state_colors,
											drone_type_button_state_colors)
							
	self.setSwarmButton = Button(root,"Set Swarm")
	self.headerBox = LinearContainer(self,Constants.LinearAxis.HORIZONTAL,0,0)
	self.headerBox:addChild(self.droneTypeButton,true,false,Constants.LinearAlign.START)
	self.headerBox:addChild(self.setSwarmButton,true,false,Constants.LinearAlign.START)

	self:addChild(self.headerBox,false,true,Constants.LinearAlign.START)
	
	self.protocolBookBox = LinearContainer(self,Constants.LinearAxis.HORIZONTAL,0,0)
	
	self.protocolBookBox:addChild(self.drone_protocol_books[1],true,true,Constants.LinearAlign.START)
	
	self:addChild(self.protocolBookBox,true,true,Constants.LinearAlign.START)
	
	self:updateBookProfile(self.swarm_profile)
	
	function self.droneTypeButton.onPressed()
		self.droneTypeButton:changeState()
		self:refreshProtocolBookBox()
		
	end
	
	function self.setSwarmButton.onPressed()
		self:commandSwarm("set_settings",self.swarm_profile:getDroneTypeProfile(self.droneTypeButton:getState()))
	end
	
	self.setSwarmButton.pushedColor = colors.lightBlue
	
	root:onLayout()
end

function CommandManager:transmitToDroneType(drone,cmd,args)
	local bundled_args = {drone_type=self.droneTypeButton:getState(),args=args}
	modem.transmit(self.com_channels.REMOTE_TO_DRONE_CHANNEL, self.com_channels.DRONE_TO_REMOTE_CHANNEL, 
	{drone_id=drone,msg={cmd=cmd,args=bundled_args}})
end

function CommandManager:transmitToDrone(drone,cmd,args)
	modem.transmit(self.com_channels.REMOTE_TO_DRONE_CHANNEL, self.com_channels.DRONE_TO_REMOTE_CHANNEL, 
	{drone_id=drone,msg={cmd=cmd,args=args}})
end

function CommandManager:commandSwarm(cmd,args,delay_interval)
	local bundled_args = {drone_type=self.droneTypeButton:getState(),args=args}
	if (delay_interval ~= nil) then
		for i,drone in ipairs(self.drone_id_list) do
			self:transmitToDrone(drone,cmd,bundled_args)
			os.sleep(delay_interval)
		end
		return
	end
	for i,drone in ipairs(self.drone_id_list) do
		self:transmitToDrone(drone,cmd,bundled_args)
	end
end

function CommandManager:askCurrentDroneForInfo(drone)
	self:transmitToDrone(drone,"get_settings_info")
end


function CommandManager:enableDroneTypeButton(mode)
	self.droneTypeButton.enabled = mode
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
	for indx,book in ipairs(self.drone_protocol_books) do
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
	self:setBook(self.droneTypeButton:getStateIndex())
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
	local drone_type_index = self.drone_type_index_map[drone_type]
	
	self.droneTypeButton:setState(drone_type_index)
	self:setBook(drone_type_index)
end

function CommandManager:getDroneType()
	return self.droneTypeButton:getState()
end

function CommandManager:setBook(indx)
	self.protocolBookBox.children = {}
	if (self.drone_protocol_books[indx]) then
		self.protocolBookBox:addChild(self.drone_protocol_books[indx],true,true,Constants.LinearAlign.START)
	end
	self.root:onLayout()
end



return CommandManager
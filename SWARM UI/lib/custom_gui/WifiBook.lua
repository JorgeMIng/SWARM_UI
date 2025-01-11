local list_manager = require ("lib.list_manager")

local Root = require 'lib.gui.Root'
local LinearContainer = require 'lib.gui.LinearContainer'
local Label = require 'lib.gui.Label'
local Button = require 'lib.gui.Button'
local Constants = require 'lib.gui.Constants'



local TextField = require 'lib.gui.TextField'
local ListBox = require 'lib.gui.ListBox'
local ScrollBar = require 'lib.gui.ScrollBar'

local ScrollWidget = require 'lib.gui.ScrollWidget'

local MultiStateButton = require "lib.custom_gui.MultiStateButton"
local BiStateButton = require "lib.custom_gui.BiStateButton"


--local SwarmManager = require "lib.custom_gui.SwarmManager"

local LinearContainer = require 'lib.gui.LinearContainer'

local expect = require "cc.expect"
local utilities = require "lib.utilities"

local TRIANGLE_LEFT = string.char(Constants.SpecialChars.TRI_LEFT)
local TRIANGLE_RIGHT = string.char(Constants.SpecialChars.TRI_RIGHT)

local IndexedListScroller = list_manager.IndexedListScroller

local WifiBook = LinearContainer:subclass()

local addChar = string.char(3)
local notAddChar ="O"
local offlineText = " Offline"
local onlineText = " Online"
local defualtType = "DEFAULT"


function WifiBook:init(root,init_config)
	expect(1, root, "table")
	WifiBook.superClass.init(self,root,Constants.LinearAxis.VERTICAL,0,0)
	self.manager=init_config.manager
	self.drone_type = init_config.drone_type or defualtType
	self.com_channels=init_config.com_channels
	self.starting=true
	
	self:createLists(self.manager.drone_id_list)
	self.starting=false
	
	--full_drone_list
	

	
	


	self.addDroneButton = Button(root,"Add Drone")
	self.removeDroneButton = Button(root,"Remove Drone")
	self.removeDroneButton.color=colors.orange
	self.removeDroneButton.textColor=colors.black
	


	self.headerBox = LinearContainer(self,Constants.LinearAxis.HORIZONTAL,0,0)
	self.headerBox:addChild(self.addDroneButton,true,false,Constants.LinearAlign.START)
	self.headerBox:addChild(self.removeDroneButton,true,false,Constants.LinearAlign.START)

	
	
	
	self.droneIdColumn = ListBox(root,getMaxDroneIDLength(self.full_drone_list),18,self.full_drone_list)
	self.droneOffline = ListBox(root,#tostring(" Offline "),18,self.full_drone_list_offline)
	self.droneAdded = ListBox(root,#tostring(" O "),18,self.full_drone_list_added)
	--self.droneList:setSelected(1)
	self.droneListscrollBar = ScrollBar(root,{self.droneIdColumn,self.droneOffline,self.droneAdded},true)
	self.droneIdColumn:addOtherScroll(self.droneOffline)
	self.droneIdColumn:addOtherScroll(self.droneAdded)

	self.droneOffline:addOtherScroll(self.droneIdColumn)
	self.droneOffline:addOtherScroll(self.droneAdded)

	self.droneAdded:addOtherScroll(self.droneIdColumn)
	self.droneAdded:addOtherScroll(self.droneOffline)
	--self.droneListscrollBar = ScrollBar(root,self.droneIdColumn)
	
	self.droneSelect = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.droneSelect:addChild(self.droneIdColumn,false,false,Constants.LinearAlign.START)
	self.droneSelect:addChild(self.droneOffline,false,false,Constants.LinearAlign.START)
	self.droneSelect:addChild(self.droneAdded,false,false,Constants.LinearAlign.START)
	self.droneSelect:addChild(self.droneListscrollBar,false,true,Constants.LinearAlign.START)
	
	self:addChild(self.headerBox,false,true,Constants.LinearAlign.START)
	self:addChild(self.droneSelect,false,true,Constants.LinearAlign.START)
	
	local lists={self.droneIdColumn,self.droneOffline,self.droneAdded}
	for _,list in pairs(lists) do
		list.bgColor = colors.orange
		list.selBgColor = colors.blue
		list.selTextColor = colors.orange
		--self.drone_list.selected = 1
		
		
	end

	self.droneListscrollBar.bgColor = colors.black
	self.droneListscrollBar.bgPressedColor = colors.lightBlue
	self.droneListscrollBar.pressedColor = colors.lightBlue
	self.droneListscrollBar.textColor = colors.black
	self.droneListscrollBar.barColor = colors.blue

	
	function self.addDroneButton.onPressed()
		self:addDrone()
		self.root:onLayout()
		
	end

	function self.removeDroneButton.onPressed()
		self:removeDrone()
		self.root:onLayout()
		
	end
	
	
	root:onLayout()
end





function WifiBook:createLists(list)
	self.original_save_list=list
	self.drone_list = utilities.copy_table(list)

	self.full_drone_list={}
	self.full_drone_list_offline={}
	self.full_drone_list_added={}

	if self.drone_list[1]=="ALL"then
		table.remove(self.drone_list,1)
	end

	--for i=1,100 do table.insert(self.drone_list,i) end

	for _,drone_id in pairs(self.drone_list) do 
		table.insert(self.full_drone_list,drone_id) 
		table.insert(self.full_drone_list_offline,offlineText)
		table.insert(self.full_drone_list_added,addChar)
	end
	if not self.starting then
		self.droneIdColumn.items=self.full_drone_list
		self.droneOffline.items=self.full_drone_list_offline
		self.droneAdded.items=self.full_drone_list_added
		self:pingDrones()
		self:onLayout()
	end

end

function WifiBook:reply_ping(args)
	
	
	--self.wifi_book:reply_ping(args)


	if self.drone_type == defualtType or args.drone_type == self.drone_type then
		--print("white",self.manager.drone_id_whitelist)
		--print(args.drone_type)
		
		
		self:addPingDrone(args.id)
		
		self.root:onLayout()
		self:onLayout()
		self.droneIdColumn:render()
		
	end
	

end

function WifiBook:removeScrollElem(pos)
	table.remove(self.full_drone_list,pos)
	table.remove(self.full_drone_list_offline,pos)
	table.remove(self.full_drone_list_added,pos)
end

function WifiBook:addScrollElem(pos,data)
	table.insert(self.full_drone_list,pos,data.id)
	table.insert(self.full_drone_list_offline,pos,data.off)
	table.insert(self.full_drone_list_added,pos,data.added)

end

function WifiBook:addPingDrone(drone)

	local pos = self:posDrone(drone)
	if pos==-1 then
		table.insert(self.full_drone_list,tostring(drone)) 
		table.insert(self.full_drone_list_offline,onlineText) 
		table.insert(self.full_drone_list_added,notAddChar)

		self.droneIdColumn.items=self.full_drone_list
		self.droneOffline.items=self.full_drone_list_offline
		self.droneAdded.items=self.full_drone_list_added
		self.droneIdColumn:render()
		self.droneOffline:render()
		self.droneAdded:render()
	else
		self.full_drone_list_offline[pos]=onlineText
		self.droneOffline.items=self.full_drone_list_offline
		self.droneOffline:render()
	end
	
end

function WifiBook:posDrone(drone)
	local result=-1
	for idx,id in ipairs(self.full_drone_list) do
		if id ==tostring(drone) then
			return idx
		end
			
	end
	
	return -1
end



function WifiBook:addDrone()
	local selected = self.droneIdColumn.selected
	if selected >0 and selected > #self.drone_list then
		
		local data = {id=self.full_drone_list[selected],off=self.full_drone_list_offline[selected],added=addChar}
		self:removeScrollElem(selected)
		self:addScrollElem(#self.drone_list+1,data)
		table.insert(self.drone_list,#self.drone_list+1,data.id)
		table.insert(self.original_save_list,#self.original_save_list+1,data.id)
		self.manager.drone_id_whitelist[data.id]=true
		self.droneIdColumn.items=self.full_drone_list
		self.droneOffline.items=self.full_drone_list_offline
		self.droneAdded.items=self.full_drone_list_added
	end
	
end

function WifiBook:removeDrone()
	local selected = self.droneIdColumn.selected
	if selected >0 and selected <= #self.drone_list then
		local data = {id=self.full_drone_list[selected],off=self.full_drone_list_offline[selected],added=notAddChar}
		self:removeScrollElem(selected)
		if data.off==onlineText then
			self:addScrollElem(#self.full_drone_list+1,data)
		end
		table.remove(self.drone_list,selected)
		table.remove(self.original_save_list,selected+1)
		self.manager.drone_id_whitelist[data.id]=false
		self.droneIdColumn.items=self.full_drone_list
		self.droneOffline.items=self.full_drone_list_offline
		self.droneAdded.items=self.full_drone_list_added
	elseif selected >0 and selected > #self.drone_list then
		self:removeScrollElem(selected)
		self.droneIdColumn.items=self.full_drone_list
		self.droneOffline.items=self.full_drone_list_offline
		self.droneAdded.items=self.full_drone_list_added

		if self:posDrone(selected)~=-1 then
			
		end

	end
	
	
end



function WifiBook:pingDrones(drone)
	-- send broadcast
	self.manager:broadcast("ping",{})
end


function WifiBook:setDroneType(drone_type)
	self.drone_type=drone_type
end

function WifiBook:updatePages(drone_profile)

	--self:createLists(self.manager.drone_id_list)

	
end



return WifiBook
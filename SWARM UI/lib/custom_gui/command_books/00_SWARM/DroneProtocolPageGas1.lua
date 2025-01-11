local list_manager = require ("lib.list_manager")

local Label = require 'lib.gui.Label'
local Constants = require 'lib.gui.Constants'
local LinearContainer = require 'lib.gui.LinearContainer'
local TextField = require "lib.gui.TextField"
local Button = require "lib.gui.Button"
local DroneSettingsProfile = require "lib.custom_gui.DroneSettingsProfile"
local BiStateButton = require "lib.custom_gui.BiStateButton"
local TextFieldActOnKey = require "lib.custom_gui.TextFieldActOnKey"

local utilities = require "lib.utilities"

local FigureLoader = require("lib.figures.FigureLoader")




local MultiStateButton = require "lib.custom_gui.MultiStateButton"


local common_variables = require "lib.custom_gui.command_books.common_variables"
local DroneProtocolPage = require("lib.custom_gui.command_books."..common_variables.default_page_name..".DroneProtocolPage")
local expect = require "cc.expect"
local loader_shapes = require("lib.shapes.load_shapes")



local DroneProtocolPageGas1 = DroneProtocolPage:subclass()


function DroneProtocolPageGas1:load_shapes()
	local colors = self:getColorsShapes(loader_shapes)
	return {list_shapes=loader_shapes,colors=colors}
end

function DroneProtocolPageGas1:getColorsShapes(list_items)
	local color_text={}
	local color_back={}
	for idx,shape in ipairs(list_items)do
		color_text[idx]=colors.black
		color_back[idx]=colors.orange
	end
	return {color_back=color_back,color_text=color_text}
end

function DroneProtocolPageGas1:updateParamShape(shape)

	if shape==nil or shape=="NONE" or shape.figure_name=="NONE" or type(shape)~="table"then
		self:setSettings(self.drone_type,"shape","NONE")
		return{}
	end

	

	local figure_instance = FigureLoader.load_figure(shape.figure_type,shape.figure_name,shape.params)
	for _,param in pairs(figure_instance.params_metadata) do
		if param.gui_type=="vector" then
			self:setSettings(self.drone_type,param.name,utilities.table_to_vector(shape.params[param.name]))
		else
			self:setSettings(self.drone_type,param.name,shape.params[param.name])
		end
		--print(_,param.name,shape.params[param.name])
	end
	--dofile(fuck)
end

function DroneProtocolPageGas1:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageGas1.superClass.init(self,root,init_config)

	--print(self:getSettings(self.drone_type).experiment_online)

	self.pauseButton = BiStateButton(root,{"PAUSE",
											"RUN"},
											
											{colors.white,
											colors.black},
											
											{colors.blue,
											colors.orange},
											self:getSettings(self.drone_type).stop_drone)
	self.restart = Button(root,"restart")
	self.restart.pushedColor = colors.lightBlue
	


	
	

	self.experimentButton = BiStateButton(root,{"ON",
											"OFF"},
											
											{colors.white,
											colors.black},
											
											{colors.green,
											colors.orange},
											self:getSettings(self.drone_type).experiment_online)
	

	self.shuffleButton = Button(root,"SHUFFLE")
	self.shuffleButton.pushedColor = colors.lightBlue

	


	self.shapes_data = self:load_shapes()
	self.indx_shapes_states=utilities.getIndexTable(self.shapes_data.list_shapes)
	
	self.shapeButton = MultiStateButton(root,self.shapes_data.list_shapes,
											self.shapes_data.colors.color_text,
											self.shapes_data.colors.color_back)

	
	
	self.shapeButton.setState(self.indx_shapes_states[self:getSettings(self.drone_type).shape])	
	self.shapeButton.color=colors.white
											


	self.startExperiment = Button(root,"START")
	self.startExperiment.pushedColor = colors.lightBlue

	


	--self.row1 = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	--self.row1:addChild(self.huntButton,true,false,Constants.LinearAlign.START)
	--self.row1:addChild(self.turretButton,true,false,Constants.LinearAlign.START)
	
	self.move_states_text={"STAY   ","RANDOM ","FOLLOW ","  HOME  "}
	self.move_states={}
	for idx,state in pairs(self.move_states_text) do
		self.move_states[idx]=state:gsub("%s*", "")
	end
	
		--print(page_settings.drone_state)
	--self.stateButton.text = page_settings.drone_state
	self.indx_moves_states=utilities.getIndexTable(self.move_states)
	
	self.movementModeButton = MultiStateButton(root,self.move_states_text,
											
											{colors.black,
											colors.black,colors.black,colors.black},
											
											{colors.orange,
											colors.orange,colors.orange,colors.orange})

	self.movementModeButton.setState(self.indx_moves_states[self:getSettings(self.drone_type).movement_mode])	

	--self:getSettings(self.drone_type).movement_mode


	--TWO COLUMNS
	self.row1 = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.row1:addChild(self.pauseButton,true,false,Constants.LinearAlign.START)
	self.row1:addChild(self.restart,true,false,Constants.LinearAlign.START)
	

	--experiment columns
	self.experimentColumn = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.experimentColumn:addChild(self.experimentButton,true,false,Constants.LinearAlign.START)
	self.experimentColumn:addChild(self.shuffleButton,true,true,Constants.LinearAlign.START)
	self.experimentColumn:addChild(self.shapeButton,true,true,Constants.LinearAlign.START)
	self.experimentColumn:addChild(self.startExperiment,true,true,Constants.LinearAlign.START)



	--movement column
	self.movementColumn = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.movementColumn:addChild(self.movementModeButton,true,false,Constants.LinearAlign.START)


	self.twoColumns = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,1,0)
	self.twoColumns:addChild(self.experimentColumn,true,false,Constants.LinearAlign.START)
	self.twoColumns:addChild(self.movementColumn,true,false,Constants.LinearAlign.START)
	


	--DATA COLUMN

	self.dataColumnLabel = Label(root,"INFO DRONE")
	
	
	self.realPosLabel = Label(self,"PosReal: "..utilities.null_vector(self:getSettings(self.drone_type).real_pos):tostring())
	self.targetLabel = Label(self,"Target: "..utilities.null_vector(self:getSettings(self.drone_type).objective_pos):tostring())
	self.coordCenterLabel = Label(self,"Center: "..utilities.null_vector(self:getSettings(self.drone_type).coordinate_center):tostring())

	
	local angle__text = self:getSettings(self.drone_type).angle_offset or "nil"
	self.angleOffsetLabel = Label(self,"Angle: "..angle__text)

	self.stateTitleLabel = Label(self,"State: ")
	
	

	self.stateButton = Button(root,self:getSettings(self.drone_type).drone_state or "NONE")
	self.stateButton.enabled = false
	self.stateButton.disabledColor = colors.blue

	self.stateData = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	self.stateData:addChild(self.stateTitleLabel,true,false,Constants.LinearAlign.START)
	self.stateData:addChild(self.stateButton,true,false,Constants.LinearAlign.START)

	

	self.dataColumn = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.dataColumn:addChild(self.dataColumnLabel,true,true,Constants.LinearAlign.START)
	--self.dataColumn:addChild(self.targetTitle,true,true,Constants.LinearAlign.START)
	self.dataColumn:addChild(self.realPosLabel,true,true,Constants.LinearAlign.START)
	self.dataColumn:addChild(self.targetLabel,true,true,Constants.LinearAlign.START)
	self.dataColumn:addChild(self.coordCenterLabel,true,true,Constants.LinearAlign.START)
	self.dataColumn:addChild(self.angleOffsetLabel,true,true,Constants.LinearAlign.START)
	self.dataColumn:addChild(self.stateData,true,true,Constants.LinearAlign.START)

	if self:getDroneId()~="ALL"then
		self.dataColumn.visible=false
	end

	

	

	




	--[[
	self.masterPlayerLabel = Label(root,"MASTER PLAYER:")
	self.masterPlayerTextField = TextFieldActOnKey(root,16,self:getSettings(self.drone_type).master_player)
	
	self.playerMaster = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.playerMaster:addChild(self.masterPlayerLabel,true,false,Constants.LinearAlign.START)
	self.playerMaster:addChild(self.masterPlayerTextField,true,false,Constants.LinearAlign.START)
	
	
	
	self.sittingBtnContainer = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.sittingBtnContainer:addChild(self.isSittingButton,false,false,Constants.LinearAlign.START)
	
	self.masterShipLabel = Label(root,"MASTER SHIP ID:")
	self.masterShipTextField = TextFieldActOnKey(root,16,tostring(self:getSettings(self.drone_type).master_ship))
	
	self.shipMaster = LinearContainer(root,Constants.LinearAxis.VERTICAL,0,0)
	self.shipMaster:addChild(self.masterShipLabel,true,false,Constants.LinearAlign.START)
	self.shipMaster:addChild(self.masterShipTextField,true,false,Constants.LinearAlign.START)
	
	self.droneMasters = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self.droneMasters:addChild(self.playerMaster,true,true,Constants.LinearAlign.CENTER)
	self.droneMasters:addChild(self.isSittingButton,false,true,Constants.LinearAlign.CENTER)
	self.droneMasters:addChild(self.shipMaster,true,true,Constants.LinearAlign.CENTER)
	]]
	self:addChild(self.row1,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.twoColumns,false,true,Constants.LinearAlign.CENTER)
	self:addChild(self.dataColumn,false,true,Constants.LinearAlign.START)
	
	--self:addChild(self.droneMasters,false,true,Constants.LinearAlign.CENTER)
	function self:getInfo()
		local drone_id =self:getDroneId()
		if drone_id~="ALL"then
			self.manager:askCurrentDroneForInfo(drone_id)
		end
	end

	
	function self.pauseButton.onPressed()
		self.pauseButton:changeState()
		self:setSettings(self.drone_type,"stop_drone",self.pauseButton:getStateBoolean())
		self:transmitToCurrentDrone("stop_drone",self:getSettings(self.drone_type).stop_drone)

		self:overrideButtons(self:getSettings(self.drone_type))
		self:getInfo()
		self:onLayout()
		
		
	end

	function self.restart.onPressed()
		self:transmitToCorrectDrone("restart")
		self:getInfo()
		self:onLayout()
		
		
	end

	function self.experimentButton.onPressed()
		self.experimentButton:changeState()
		self:setSettings(self.drone_type,"experiment_online",self.experimentButton:getStateBoolean())
		self:transmitToCurrentDrone("experiment_online",self:getSettings(self.drone_type).experiment_online)

		self:overrideButtons(self:getSettings(self.drone_type))
		self:getInfo()
		self:onLayout()
		
	end

	


	function self.shapeButton.onPressed()
		self.shapeButton:changeState()
		

		local page_settings = self:getSettings(self.drone_type)

		local figure_name=self.shapeButton:getState()
		local params = {insc_length=page_settings.insc_length,center_figure=page_settings.center_figure}
		local figure_data = {figure_type="geometric",figure_name=figure_name,params=params}
		
		self:setSettings(self.drone_type,"shape",figure_data)

		if self:getDroneId()=="ALL"then
			self.manager:updateBookProfile(self.manager.swarm_profile)
		else
			self.manager:updateBookProfile(self.manager.current_drone_profile)
		end

		

		self:transmitToCurrentDrone("shape",figure_data)
		self:overrideButtons(self:getSettings(self.drone_type))
		--self:getInfo()
		self:onLayout()
	end

	function self.movementModeButton.onPressed()
		self.movementModeButton:changeState()
		self:setSettings(self.drone_type,"movement_mode",self.move_states[self.movementModeButton:getStateIndex()])
		self:transmitToCurrentDrone("movement_mode",self:getSettings(self.drone_type).movement_mode:gsub("%s*", ""))
		self:overrideButtons(self:getSettings(self.drone_type))
		self:getInfo()
		self:onLayout()
	end

	function self.shuffleButton.onPressed()
	
		self:transmitToCorrectDrone("shuffle")
		self:getInfo()
		self:onLayout()
	end

	function self.startExperiment.onPressed()
	
		self:transmitToCorrectDrone("start_experiment")
		self:getInfo()
		self:onLayout()
	end



	
	self:initElements({
		self.pauseButton,
		self.experimentButton,
		self.shapeButton,
		self.movementModeButton,
		self.shuffleButton,
		self.startExperiment,
		self.stateButton

	})
	
	root:onLayout()
	
end


function DroneProtocolPageGas1:refresh()
	
	local page_settings = self:getSettings(self.drone_type)
	
	self.pauseButton:setStateByBoolean(page_settings.stop_drone)
	self.experimentButton:setStateByBoolean(page_settings.experiment_online)
	local shape_name="NONE"
	
	if page_settings.shape~=nil and page_settings.shape~="NONE" or page_settings.shape.figure_name~="NONE" and type(page_settings.shape)=="table" then
		shape_name=page_settings.shape.figure_name
		
		
		
	end
	
	self:updateParamShape(page_settings.shape)

	self.shapeButton:setState(self.indx_shapes_states[shape_name])

	self.movementModeButton:setState(self.indx_moves_states[page_settings.movement_mode])


	self.targetLabel.text = "Target:"..utilities.table_to_vector(utilities.null_vector(page_settings.objective_pos)):tostring()
	
	self.coordCenterLabel.text = "Center:".. utilities.table_to_vector(utilities.null_vector(page_settings.coordinate_center)):tostring()

	self.realPosLabel.text ="PosReal: "..utilities.table_to_vector(utilities.null_vector(page_settings.real_pos)):tostring()
	local angle_text = page_settings.angle_offset or "nil"
	self.angleOffsetLabel.text = "Angle:".. angle_text
	local state =page_settings.drone_state or "NONE"
	self.stateButton.text = state:gsub("%s*", "")
	
	if self:getDroneId()=="ALL"then
		self.dataColumn.visible=false
	else
		self.dataColumn.visible=true
	end
	self:overrideButtons(page_settings)
	self.root:onLayout()
	
end

function DroneProtocolPageGas1:overrideButtons(settings)
	if (settings.experiment_online) then
		
		self.shapeButton.enabled = true
		self.shuffleButton.enabled = true
		self.startExperiment.enabled = true
		self.movementModeButton.enabled = false
		
	else

		self.shapeButton.enabled = false
		self.shuffleButton.enabled = false
		self.startExperiment.enabled = false

		self.movementModeButton.enabled = true

	end
	
end

return DroneProtocolPageGas1
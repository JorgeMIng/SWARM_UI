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

local MultiStateButton = require "lib.custom_gui.MultiStateButton"


local common_variables = require "lib.custom_gui.command_books.common_variables"
local DroneProtocolPage = require("lib.custom_gui.command_books."..common_variables.default_page_name..".DroneProtocolPage")
local expect = require "cc.expect"
local loader_shapes = require("lib.shapes.load_shapes")

local FigureLoader = require("lib.figures.FigureLoader")

local DroneProtocolPageGas2 = DroneProtocolPage:subclass()


function DroneProtocolPageGas2:load_shapes()
	local colors = self:getColorsShapes(loader_shapes)
	return {list_shapes=loader_shapes,colors=colors}
end

function DroneProtocolPageGas2:getColorsShapes(list_items)
	local color_text={}
	local color_back={}
	for idx,shape in ipairs(list_items)do
		color_text[idx]=colors.black
		color_back[idx]=colors.orange
	end
	return {color_back=color_back,color_text=color_text}
end






local function add_vector_input(root,colors_butt,var_name,default_value,table_vars,setting_drone,func)

	

	root[var_name.."formationTextFieldX"] = TextField(root.root,5,"")
	root[var_name.."formationTextFieldY"] = TextField(root.root,5,"")
	root[var_name.."formationTextFieldZ"] = TextField(root.root,5,"")


	if default_value then
		root[var_name.."formationTextFieldX"]:setText(tostring(default_value.x))
		root[var_name.."formationTextFieldY"]:setText(tostring(default_value.y))
		root[var_name.."formationTextFieldZ"]:setText(tostring(default_value.z))
	end

	
	table.insert(table_vars,var_name.."formationTextFieldX")
	table.insert(table_vars,var_name.."formationTextFieldY")
	table.insert(table_vars,var_name.."formationTextFieldZ")






	if not root.divider1 then
		root.divider1 = Label(root,":")
		table.insert(table_vars,"divider1")
	end

	if not root.divider2 then
		root.divider2 = Label(root,":")
		

		table.insert(table_vars,"divider2")
	end
	if not root.parenth1 then
		root.parenth1 = Label(root,"<")
		table.insert(table_vars,"parenth1")
	end
	if not root.parenth2 then
		root.parenth2 = Label(root,">")
		table.insert(table_vars,"parenth2")
	end

	if colors_butt and type(colors_butt)=="table" and colors_butt.backgroundColor and colors_butt.textColor then
		root.divider1.backgroundColor = colors_butt.backgroundColor
		root.divider1.textColor = colors_butt.textColor

		root.divider2.backgroundColor = colors_butt.backgroundColor
		root.divider2.textColor = colors_butt.textColor

		root.parenth1.backgroundColor = colors_butt.backgroundColor
		root.parenth1.textColor = colors_butt.textColor

		root.parenth2.backgroundColor = colors_butt.backgroundColor
		root.parenth2.textColor = colors_butt.textColor
	end
	
	
	
	root[var_name.."coordBox"] = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	
	
	root[var_name.."coordBox"]:addChild(root.parenth1,false,false,Constants.LinearAlign.END)
	root[var_name.."coordBox"]:addChild(root[var_name.."formationTextFieldX"],true,false,Constants.LinearAlign.CENTER)
	root[var_name.."coordBox"]:addChild(root.divider1,false,false,Constants.LinearAlign.END)
	root[var_name.."coordBox"]:addChild(root[var_name.."formationTextFieldY"],true,false,Constants.LinearAlign.CENTER)
	root[var_name.."coordBox"]:addChild(root.divider2,false,false,Constants.LinearAlign.END)
	root[var_name.."coordBox"]:addChild(root[var_name.."formationTextFieldZ"],true,false,Constants.LinearAlign.CENTER)
	root[var_name.."coordBox"]:addChild(root.parenth2,false,false,Constants.LinearAlign.END)
	
	
	root[var_name.."formationTextFieldX"].onChanged = function()
		local n = root[var_name.."formationTextFieldX"]:getText()
		if tonumber(n) then
			n = tonumber(n)
		
			local new_formation = root:getSettings(root.drone_type)[setting_drone]
			new_formation.x = n
			
			root:setSettings(root.drone_type,setting_drone,new_formation)
			
			
			if func then
				func(root)
			end
			
		else
			--local old_value = root:getSettings(root.drone_type)[setting_drone]
			
			--root[var_name.."formationTextFieldX"]:setText(tostring(old_value.x))
		end
		
		root:onLayout()
	end
	


	
	root[var_name.."formationTextFieldY"].onChanged = function()
		local n = root[var_name.."formationTextFieldY"]:getText()
		if tonumber(n) then
			n = tonumber(n)
		
			local new_formation = root:getSettings(root.drone_type)[setting_drone]
			new_formation.y = n
			root:setSettings(root.drone_type,setting_drone,new_formation)
			if func then
				func(root)
			end
			
		else
			local old_value = root:getSettings(root.drone_type)[setting_drone]
			root[var_name.."formationTextFieldY"]:setText(tostring(old_value.y))
		end
		
		root:onLayout()
	end

	root[var_name.."formationTextFieldZ"].onChanged = function()
		local n = root[var_name.."formationTextFieldZ"]:getText()
		if tonumber(n) then
			n = tonumber(n)
		
			local new_formation = root:getSettings(root.drone_type)[setting_drone]
			new_formation.z = n
			root:setSettings(root.drone_type,setting_drone,new_formation)
			if func then
				func(root)
			end
			
		else
			local old_value = root:getSettings(root.drone_type)[setting_drone]
			root[var_name.."formationTextFieldZ"]:setText(tostring(old_value.z))
		end
		
		
		root:onLayout()
	end
	return root[var_name.."coordBox"]
end


local function add_numeric_input(root,colors_butt,var_name,default_value,table_vars,setting_drone,func)

	

	root[var_name.."numberTextField"] = TextField(root.root,5,"")
	

	if default_value then
		root[var_name.."numberTextField"]:setText(tostring(default_value))
		
	end

	
	table.insert(table_vars,var_name.."numberTextField")

	if not root.parenth1 then
		root.parenth1 = Label(root,"<")
		table.insert(table_vars,"parenth1")
	end
	if not root.parenth2 then
		root.parenth2 = Label(root,">")
		table.insert(table_vars,"parenth2")
	end

	if colors_butt and type(colors_butt)=="table" and colors_butt.backgroundColor and colors_butt.textColor then

		root.parenth1.backgroundColor = colors_butt.backgroundColor
		root.parenth1.textColor = colors_butt.textColor

		root.parenth2.backgroundColor = colors_butt.backgroundColor
		root.parenth2.textColor = colors_butt.textColor
	end
	
	
	
	root[var_name.."numberBox"] = LinearContainer(root,Constants.LinearAxis.HORIZONTAL,0,0)
	
	
	root[var_name.."numberBox"]:addChild(root.parenth1,false,false,Constants.LinearAlign.END)
	root[var_name.."numberBox"]:addChild(root[var_name.."numberTextField"],true,false,Constants.LinearAlign.CENTER)
	root[var_name.."numberBox"]:addChild(root.parenth2,false,false,Constants.LinearAlign.END)
	
	
	root[var_name.."numberTextField"].onChanged = function()
		local n = root[var_name.."numberTextField"]:getText()
		if tonumber(n) then
			n= tonumber(n)
			root:setSettings(root.drone_type,setting_drone,n)
			if func then
				func(root)
			end

		else
			local value = root:getSettings(root.drone_type)[setting_drone]
			root[var_name.."numberTextField"]:setText(tostring(value))
		end
		root:onLayout()
		
	end
	
	return root[var_name.."numberBox"]
end




function DroneProtocolPageGas2:create_param_inputs(param,default_value)
	if param.gui_type=="vector" then
		return add_vector_input(self,{backgroundColor=colors.black,textColor=colors.orange},param.name,default_value,self.figureParamInputs,param.name,self["updateShapeParams"])
	end

	if param.gui_type=="number" then
		return add_numeric_input(self,{backgroundColor=colors.black,textColor=colors.orange},param.name,default_value,self.figureParamInputs,param.name,self["updateShapeParams"])
	end
	
end


function DroneProtocolPageGas2:updateShapeParams()
	local page_settings=self:getSettings(self.drone_type)
	if page_settings and page_settings.shape~=nil and page_settings.shape.figure_name and page_settings.shape.figure_name~="NONE" then
		local new_params ={}
		
		for key,_ in pairs(page_settings.shape.params) do
			new_params[key]=page_settings[key]
			
			
		end
		--setup params of shape in actual profile
		local shape = page_settings.shape
		shape.params=new_params
		self:setSettings(self.drone_type,"shape",shape)
		 

		-- transmit to drone new param of figure
		
		self:transmitToCorrectDrone("set_shape_params",new_params)
		
	end



	
end




function DroneProtocolPageGas2:setupParamFig()
	self.controlsFigure.children={}
	self.figureParamInputs={}
	local page_settings=self:getSettings(self.drone_type)
	

	
	
	if page_settings and page_settings.shape~=nil and page_settings.shape.figure_name and page_settings.shape.figure_name~="NONE" and
		
	
	type(page_settings.shape)=="table" then
		local figure_instance = FigureLoader.load_figure(page_settings.shape.figure_type,page_settings.shape.figure_name,page_settings.shape.params)
		
		
		local params_metadata = figure_instance.params_metadata
		for i,param in pairs(params_metadata) do
			local nameVarCont=param.name.."CONNT"
			local nameVarLabel=param.name.."LABEL"
			self[nameVarCont]=LinearContainer(self.root,Constants.LinearAxis.VERTICAL,0,0)
			self[nameVarLabel]=Label(self.root,param.name..":")
			table.insert(self.figureParamInputs,nameVarLabel)
			print(param.name,self.manager.swarm_profile.settings_profile[self.drone_type][param.name])
			local param_box = self:create_param_inputs(param,page_settings[param.name])
			--print(nameVarLabel)
			self[nameVarCont]:addChild(self[nameVarLabel],false,false,Constants.LinearAlign.START)
			if param_box then
				self[nameVarCont]:addChild(param_box,false,false,Constants.LinearAlign.CENTER)
			end
			
			
			self.controlsFigure:addChild(self[nameVarCont],false,true,Constants.LinearAlign.CENTER)
			
			
		end
		--dofile(oke)
		

	else
		self.controlsFigure:addChild(self.no_params_label,true,false,Constants.LinearAlign.START)
	end

	
end

function DroneProtocolPageGas2:init(root,init_config)
	expect(1, root, "table")
	
	DroneProtocolPageGas2.superClass.init(self,root,init_config)
	self.root=root
	self.title_label = Label(root,"FIGURE_CONTROLS:")
	self.no_params_label = Label(root,"No figure selected")
	self:addChild(self.title_label,false,true,Constants.LinearAlign.CENTER)
	local page_settings = self:getSettings(self.drone_type)
	
	self.controlsFigure = LinearContainer(root,Constants.LinearAxis.VERTICAL,1,0)
	self:setupParamFig(root)
	

	self:addChild(self.controlsFigure,false,true,Constants.LinearAlign.CENTER)
	


	

	function self:getInfo()
		local drone_id =self:getDroneId()
		if drone_id~="ALL"then
			self.manager:askCurrentDroneForInfo(drone_id)
		end
	end

	self.divider1 = Label(self,":")
	self.divider2 = Label(self,":")
	self.parenth1 = Label(self,"<")
	self.parenth2 = Label(self,">")
	

	

	local init_elements_static={
		self.title_label,
		self.no_params_label,
	}

	for _,elem in pairs(self.figureParamInputs) do
		table.insert(init_elements_static,self[elem])
	end

	
	self:initElements(init_elements_static)
	
	root:onLayout()
	
end


function DroneProtocolPageGas2:refresh()
	local page_settings = self:getSettings(self.drone_type)
	

	
	
	self:setupParamFig()
	
	
	local new_elems = {}
	for _,elem in pairs(self.figureParamInputs) do
		table.insert(new_elems,self[elem])
	end
	self:initElements(new_elems)
	self.root:onLayout()
	
end

function DroneProtocolPageGas2:overrideButtons(settings)
	
	
end

return DroneProtocolPageGas2
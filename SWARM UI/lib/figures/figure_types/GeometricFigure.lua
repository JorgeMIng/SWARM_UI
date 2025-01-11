



local DefaultFigure = require "lib.figures.DefaultFigure"

local expect = require "cc.expect"


local GeometricFigure = DefaultFigure:subclass()



--OVERRIDABLE--
function GeometricFigure:in_figure(pos)
    local funcs=GeometricFigure.name_to_function()
    local result=false
    local geo_func = funcs[self.figure_name_id]
    if geo_func then
        result = geo_func(pos,self.center_figure,self.insc_length)
    else
        error(("Invalid Figure ID Name %s "):format(self.figure_name_id), 2)
    end
    return result
end



function GeometricFigure.name_to_function()
    local functions = GeometricFigure.name_id_types()
    local result={}
    for _,func_name in functions do
        local full_name=func_name.."_funct"
        result[func_name]=GeometricFigure[full_name]
    end

end
function GeometricFigure.name_id_types()
    return {"CUBE","PYRAMID","SPHERE"}
end

-- 0,0,0 will be the coordinate center 
-- center_figure the center of the figure
-- insc_length the maximum length of the inscribed cube -- aplies for sphere and pyramid
function GeometricFigure.CUBE_funct(pos,center_figure,insc_length)
    
    local mitad_arista = insc_length / 2
    
    -- Comprobamos si el punto está dentro de los límites del cubo en cada eje
    return pos.x >= center_figure.x - mitad_arista and pos.x <= center_figure.x + mitad_arista and
    pos.y >= center_figure.y - mitad_arista and pos.y <= center_figure.y + mitad_arista and
    pos.z >= center_figure.z - mitad_arista and pos.z <= center_figure.z + mitad_arista
end

function GeometricFigure.PYRAMID(pos,center_figure,insc_length)
    return false

end

function GeometricFigure.SPHERE(pos,center_figure,insc_length)
    local radius = insc_length/2
    local distancia_cuadrada = (pos.x - center_figure.x)^2 + (pos.y - center_figure.y)^2 + (pos.z - center_figure.z)^2
    
    -- Comparamos si la distancia al cuadrado es menor o igual al radio al cuadrado
    return distancia_cuadrada <= radius^2

end














--static--
function GeometricFigure.params_to_check()
    return {
        {name="center_figure",gui_type="vector",type="table"},
        {name="insc_length",gui_type="number",type="number"}}

end

--static--
function GeometricFigure.figure_type()
    return "geometric"
end





return GeometricFigure
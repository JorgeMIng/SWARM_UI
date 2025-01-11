local dir_file = debug.getinfo(1).source:match("@?(.*/)")  -- Obtener la ruta completa
-- Eliminar la barra inicial, si existe (por el prefijo @)
if dir_file:sub(1, 1) == "/" then
    dir_file = dir_file:sub(2)
end
local protocol_book = dir_file:gsub("/", ".").."DroneProtocolBookGas"


local metadata = {
    id_name="GAS",
	visible=true,
    get_settings=function() 
        return {
			objective_pos=nil,
			coordinate_center=nil,
			drone_state=nil,
			cooldown_trilateration=5,
			cooldown_trilateration_indirect=5,
			range_trilateration=30,
			wifi_range=1000,
			bounding_box_diameters=vector.new(300,50,300),
			bounding_box_center=vector.new(0,0,0),
			evade_collisions=false,
			distance_random_move=0,
			timer_random_move=0,
			run_mode=true,
			stop_drone=false,
			experiment_online=false,
			shape="NONE",
			movement_mode=nil,
			angle_offset=nil,
			real_pos=nil,
			center_figure=nil,
			insc_length=20

		}
	end,
    get_protocol_book_class_dir=protocol_book
}
return metadata
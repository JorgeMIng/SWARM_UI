local dir_file = debug.getinfo(1).source:match("@?(.*/)")  -- Obtener la ruta completa
-- Eliminar la barra inicial, si existe (por el prefijo @)
if dir_file:sub(1, 1) == "/" then
    dir_file = dir_file:sub(2)
end
local protocol_book = dir_file:gsub("/", ".").."DroneProtocolBookTurret"


local metadata = {
    id_name="TURRET",
	visible=true,
    get_settings=function() 
        return {
			aim_target_mode = "PLAYER",
			use_external_aim = false,		
			use_external_orbit = false,
			bullet_range = 100,
			range_finding_mode = 3,
			orbit_offset = vector.new(0,0,0),
			hunt_mode = false,			
			auto_aim = false,

		}
	end,
    get_protocol_book_class_dir=protocol_book
}
return metadata
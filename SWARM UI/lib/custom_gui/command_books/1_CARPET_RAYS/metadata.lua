local dir_file = debug.getinfo(1).source:match("@?(.*/)")  -- Obtener la ruta completa
-- Eliminar la barra inicial, si existe (por el prefijo @)
if dir_file:sub(1, 1) == "/" then
    dir_file = dir_file:sub(2)
end
local protocol_book = dir_file:gsub("/", ".").."DroneProtocolBookCarpetRay"


local metadata = {
    id_name="RAY",
    visible=true,
    get_settings=function() 
        return {
            orbit_offset = vector.new(0,0,0),
			target_radius = 7,
			target_height = 3,
			swim_frequency = 5,
			swim_amplitude = 0.5,
        }
    end,
    get_protocol_book_class_dir=protocol_book
}
return metadata




local dir_file = debug.getinfo(1).source:match("@?(.*/)")  -- Obtener la ruta completa
-- Eliminar la barra inicial, si existe (por el prefijo @)
if dir_file:sub(1, 1) == "/" then
    dir_file = dir_file:sub(2)
end

local protocol_book = dir_file:gsub("/", ".").."DroneProtocolBookKite"

local metadata = {
    id_name="KITE",
    visible=true,
    get_settings=function() 
        return {		
			rope_length = 20,
            orbit_offset = vector.new(0,0,0)
		}
    end,
    get_protocol_book_class_dir=protocol_book
}
return metadata
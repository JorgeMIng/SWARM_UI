
local dir_file = debug.getinfo(1).source:match("@?(.*/)")  -- Obtener la ruta completa
-- Eliminar la barra inicial, si existe (por el prefijo @)
if dir_file:sub(1, 1) == "/" then
    dir_file = dir_file:sub(2)
end

local protocol_book = dir_file:gsub("/", ".").."DroneProtocolBookTracer"

local metadata = {
    id_name="TRACER",
    visible=true,
    get_settings=function() 
        return {
			walk = false,
		}
    end,
    get_protocol_book_class_dir=protocol_book
}
return metadata

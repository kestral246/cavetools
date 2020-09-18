-- Cave Tools [cavetools]

dofile(minetest.get_modpath("cavetools").."/depth_finder.lua")
dofile(minetest.get_modpath("cavetools").."/flash_lamps.lua")

if minetest.get_modpath("default") ~= nil then
	dofile(minetest.get_modpath("cavetools").."/ladder_overrides.lua")
end


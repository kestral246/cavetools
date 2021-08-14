-- Cave Tools [cavetools]

if minetest.settings:get_bool("cavetool_flashlamps", true) then
	dofile(minetest.get_modpath("cavetools").."/flash_lamps.lua")
end
if minetest.settings:get_bool("cavetool_depthfinders", true) then
	dofile(minetest.get_modpath("cavetools").."/depth_finder.lua")
end
if minetest.get_modpath("default") ~= nil and
		minetest.settings:get_bool("cavetool_ladders", true) then
	dofile(minetest.get_modpath("cavetools").."/ladder_overrides.lua")
end


-- Flash Lamps (formerly Wand of Illumination) [flash_lamps]
-- by David G (kestral246@gmail.com)
-- 2024-03-13

-- Lights up what's in front, but only for a moment.
-- Provides a flash_lamp, flash_wand, and super_flash_lamp.

-- How bright to make lights.
-- For reference, the default:torch has a brightness of 12.
local brightness_value = 11

-- Maximum number of nodes to check (use debug to determine).
local maxcount = 15000

-- The wear, mana, radius, and light cone can now be set independently for each lamp tool.
-- For extended range, wear and mana cost are doubled, light_cone halved, and radius increased by 50%.

-- Setting to allow optional use of ABM for light decay.
-- Make sure all lights have faded before disabling this option.
local use_abm = minetest.settings:get_bool("cavetools_use_abm", false)
if use_abm then
	minetest.log("warning", "Flash Lamps using ABM for light decay.")
end

-- Set to true to print debug statistics.
local debug = false

-- Check for mana mod
local using_mana_mod = false
if minetest.get_modpath("mana") ~= nil then
	using_mana_mod = true
end

local scanned = {}  -- Set containing scanned nodes, so they don't get scanned multiple times.
local tocheck = {}  -- Table of nodes to check.
local tolight = {}  -- Table of nodes that need to be converted to fill lights.

minetest.register_on_joinplayer(function(player)
	local pname = player:get_player_name()
	scanned[pname] = {}
	tocheck[pname] = {}
	tolight[pname] = {}
end)

minetest.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	scanned[pname] = nil
	tocheck[pname] = nil
	tolight[pname] = nil
end)

local mana_check = function(player, cost)
	local allowed
	if cost > 0 then
		if using_mana_mod then
			if mana.subtract(player:get_player_name(), cost) then
				allowed = true
			else
				allowed = false
			end
		else
			allowed = true
		end
		return allowed
	else  -- always allowed when not using mana
		return true
	end
end

minetest.register_node("cavetools:light", {
	description = "Flash Lamp Light",
	drawtype = "airlike",
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = brightness_value,
	pointable = false,
	buildable_to = true,
	drops = "",
	groups = {cracky = 3, oddly_breakable_by_hand = 3, fill_hidden = 1, not_in_creative_inventory = 1},
	on_timer = function(pos)  -- use node timer
		minetest.remove_node(pos)
	end,
})

if use_abm then  -- optional ABM
	minetest.register_abm({
		nodenames = {"cavetools:light"},
		interval = 2.0,  -- need to tune
		chance = 10,  -- need to tune
		action = function(pos, node, active_object_count, active_object_count_wider)
			minetest.set_node(pos, {name = "air"})
		end
	})
end

-- Determine number of elements in table, for summary output.
local tlength = function(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

-- Scan neighboring nodes, flag for checking if air.
local scan_node = function(pname, pos, origin, vdir, maxdist, light_cone)
	-- Update to send out a cone of light in direction pointed.
	-- Need small sphere to get cone of light out.
	local radius = vector.distance(origin, pos)
	if radius <= 2 or (radius <= maxdist and vector.angle(vdir, vector.direction(origin, pos)) < light_cone) then
		local enc_pos = minetest.hash_node_position(pos)
		if scanned[pname][enc_pos] ~= true then  -- hasn't been scanned
			local name = minetest.get_node(pos).name
			if name == "air" then  -- checkable
				table.insert(tocheck[pname], enc_pos)  -- add to check list
			end
			scanned[pname][enc_pos] = true  -- don't scan again
		end
	end
end

-- To check, scan all neighbors and determine if this node needs to be converted to light.
local check_node = function(pname, pos, origin, vdir, maxdist, light_cone)
	local enc_pos = minetest.hash_node_position(pos)
	local name = minetest.get_node(pos).name
	scan_node(pname, vector.add(pos, {x=0,y=0,z=1}), origin, vdir, maxdist, light_cone)  -- north
	scan_node(pname, vector.add(pos, {x=1,y=0,z=0}), origin, vdir, maxdist, light_cone)  -- east
	scan_node(pname, vector.add(pos, {x=0,y=0,z=-1}), origin, vdir, maxdist, light_cone)  -- south
	scan_node(pname, vector.add(pos, {x=-1,y=0,z=0}), origin, vdir, maxdist, light_cone)  -- west
	scan_node(pname, vector.add(pos, {x=0,y=-1,z=0}), origin, vdir, maxdist, light_cone)  -- down
	scan_node(pname, vector.add(pos, {x=0,y=1,z=0}), origin, vdir, maxdist, light_cone)  -- up
	if name == "air" and ((pos.x%4 == 0 and pos.y%8 == 0 and pos.z%4 == 0) or
			(pos.x%4 == 2 and pos.y%8 == 4 and pos.z%4 == 2))
			and minetest.get_node_light(pos) < brightness_value then
		table.insert(tolight[pname], enc_pos)
	end
end

local use_lamp = function(player, itemstack, radius, wear, mana, light_cone)
	local pname = player:get_player_name()
	local pos = vector.add(vector.round(player:get_pos()), {x=0,y=1,z=0})  -- position of wand
	local theta = math.fmod(player:get_look_horizontal() + math.pi/2, 2*math.pi)
	local phi = player:get_look_vertical() + math.pi/2
	local vdir = vector.normalize({x=math.sin(phi)*math.cos(theta), y=math.cos(phi), z=math.sin(phi)*math.sin(theta)})
	-- For debug only.
	--minetest.chat_send_player(pname, "theta = "..tostring(theta)..", phi = "..tostring(phi)..", vdir = "..tostring(minetest.serialize(vdir)))
	local key_stats = player:get_player_control()
	local wear_cost = wear
	local mana_cost = mana
	if key_stats.sneak or key_stats.aux1 then  -- extended
		radius = 1.5 * radius
		light_cone = light_cone / 2
		wear_cost = 2 * wear_cost
		mana_cost = 2 * mana_cost
	end
	if mana_check(player, mana_cost) then
		-- Initialize temporary tables for safety.
		scanned[pname] = {}
		tocheck[pname] = {}
		tolight[pname] = {}
		-- Search starts at wand position.
		table.insert(tocheck[pname], minetest.hash_node_position(pos))
		local count = 1
		while count <= table.getn(tocheck[pname]) and count <= maxcount do
			check_node(pname, minetest.get_position_from_hash(tocheck[pname][count]), pos, vdir, radius, light_cone)
			count = count + 1
		end
		count = count - 1 
		if debug then  -- print statistics
			minetest.debug("flash_lamps: y = "..tostring(pos.y)..", scan = "..
				tostring(tlength(scanned[pname]))..", check = "..tostring(count)..", lights = "..
				tostring(tlength(tolight[pname])))
		end
		-- Add lights to all locations flagged for lighting.
		for _,v in ipairs(tolight[pname]) do
			local fpos = minetest.get_position_from_hash(v)
			minetest.set_node(fpos, {name="cavetools:light"})
			if not use_abm then
				local timer = minetest.get_node_timer(fpos)  -- use node timer
				if debug then
					timer:set(2, 0)  -- short 2s flash
				else
					timer:set(5 + math.random(15), 0)  -- 5s flash with 15s decay
				end
			end
		end
		-- Clear temporary tables, which could be large.
		scanned[pname] = {}
		tocheck[pname] = {}
		tolight[pname] = {}
		-- Add wear to wand
		itemstack:add_wear(wear_cost)
		return itemstack
	end
end

minetest.register_tool("cavetools:flash_lamp", {
	description = "Flash Lamp",
	inventory_image = "cavetools_flash_lamp.png",
	stack_max = 1,
	on_use = function(itemstack, player, pointed_thing)
		local radius = 12  -- or 18
		local light_cone = math.pi/6  -- 2*30°
		local wear = math.floor(65535/60)  -- increase to 60
		local mana = 0
		local worn_item = use_lamp(player, itemstack, radius, wear, mana, light_cone)
		return worn_item
	end,
})

minetest.register_tool("cavetools:flash_wand", {
	description = "Flash Wand",
	inventory_image = "cavetools_flash_wand.png",
	stack_max = 1,
	on_use = function(itemstack, player, pointed_thing)
		local radius = 18  -- or 27
		local light_cone = math.pi/4  -- 2*45°
		local wear = math.floor(65535/100)  -- increase to 100
		local mana = 100
		local worn_item = use_lamp(player, itemstack, radius, wear, mana, light_cone)
		return worn_item
	end,
})

minetest.register_tool("cavetools:super_flash_lamp", {
	description = "Super Flash Lamp",
	inventory_image = "cavetools_super_flash_lamp.png",
	stack_max = 1,
	on_use = function(itemstack, player, pointed_thing)
		local radius = 24  -- or 36
		local light_cone = math.pi/3  -- 2*60°
		local wear = math.floor(65535/160)  -- increase to 160
		local mana = 0
		local worn_item = use_lamp(player, itemstack, radius, wear, mana, light_cone)
		return worn_item
	end,
})

-- Need default for crafting recipe.
-- Example craft recipe for wand.
if minetest.get_modpath("default") ~= nil then
	minetest.register_craft({
		output = "cavetools:flash_wand",
		recipe = {
			{"default:mese_crystal"},
			{"group:stick"}
		}
	})
end

-- Need default and tnt mods for crafting recipe.
-- Add copper or tin to make harder to craft.
if minetest.get_modpath("default") ~= nil and minetest.get_modpath("tnt") ~= nil then
	minetest.register_craft({
		output = "cavetools:flash_lamp",
		recipe = {
			{"tnt:gunpowder", "tnt:gunpowder", "tnt:gunpowder"},
			{"", "default:tin_ingot", ""},
			{"", "group:stick", ""}
		}
	})
	minetest.register_craft({
		output = "cavetools:flash_lamp",
		recipe = {
			{"tnt:gunpowder", "tnt:gunpowder", "tnt:gunpowder"},
			{"", "default:copper_ingot", ""},
			{"", "group:stick", ""}
		}
	})
end

-- Need default for crafting recipe.
if minetest.get_modpath("default") ~= nil then
	minetest.register_craft({
		output = "cavetools:super_flash_lamp",
		recipe = {
			{"default:meselamp", "default:obsidian", "default:meselamp"},
			{"default:obsidian", "default:meselamp", "default:obsidian"},
			{"default:meselamp", "default:obsidian", "default:meselamp"}
		}
	})
end

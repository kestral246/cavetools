-- Cave Ladders [cave_ladders]
-- by David G (kestral246@gmail.com)
-- 2020-06-22

minetest.override_item("default:ladder_wood", {
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker:get_wielded_item():get_name() == "default:ladder_wood" then
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			if minetest.get_node(below).name == "air" then
				minetest.set_node(below, {name = "default:ladder_wood", param2 = node.param2})
				itemstack:take_item(1)
			end
			return itemstack 
		end
	end
})

minetest.override_item("default:ladder_steel", {
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker:get_wielded_item():get_name() == "default:ladder_steel" then
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			if minetest.get_node(below).name == "air" then
				minetest.set_node(below, {name = "default:ladder_steel", param2 = node.param2})
				itemstack:take_item(1)
			end
			return itemstack 
		end
	end
})

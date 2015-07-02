minetest.register_craftitem("boat_test:infostick", {
	description = "Dry Infostick",
	inventory_image = "default_stick.png",
	--liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.chat_send_all(minetest.get_node(pointed_thing.above).param2)
	end,
})

minetest.register_craftitem("boat_test:quick_flowstick", {
	description = "Quick Flow Stick",
	inventory_image = "farming_tool_mesehoe.png",
	on_place = function(itemstack, placer, pointed_thing)
		minetest.chat_send_all(quick_water_flow(pointed_thing.above,minetest.get_node(pointed_thing.above)).x .. " , " .. quick_water_flow(pointed_thing.above,minetest.get_node(pointed_thing.above)).z)
	end,
	on_use = function(itemstack, user, pointed_thing)
		itemstack:replace("boat_test:flowstick")
		return itemstack
	end,
})

minetest.register_craftitem("boat_test:flowstick", {
	description = "Flow Stick",
	inventory_image = "farming_tool_diamondhoe.png",
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.get_item_group(minetest.get_node(pointed_thing.above).name, "liquid") ~= 0 then
			minetest.chat_send_all(water_flow(pointed_thing.above).x .. "," .. water_flow(pointed_thing.above).z)
		end
	end,
	on_use = function(itemstack, user, pointed_thing)
		itemstack:replace("boat_test:quick_flowstick")
		return itemstack
	end,
})

minetest.register_craft({
	output = "boat_test:flowstick",
	recipe = {
		{"default:diamond","default:diamond","default:diamond"},
		{"default:diamond","default:stick",  "default:diamond"},
		{"default:diamond","default:stick",  "default:diamond"},
	},
})

minetest.register_craftitem("boat_test:infostick", {
	description = "Dry Infostick",
	inventory_image = "default_stick.png",
	--liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.chat_send_all(minetest.get_node(pointed_thing.above).param2)
	end,
})

minetest.register_craftitem("boat_test:quick_flowstick", {
	description = "Flow Stick",
	inventory_image = "farming_tool_diamondhoe.png",
	on_place = function(itemstack, placer, pointed_thing)
		minetest.chat_send_all(quick_flow(pointed_thing.above,minetest.get_node(pointed_thing.above)).x .. " , " .. quick_flow(pointed_thing.above,minetest.get_node(pointed_thing.above)).z)
	end,
})

minetest.register_craft({
	output = "boat_test:quick_flowstick",
	recipe = {
		{"default:diamond","default:diamond","default:diamond"},
		{"default:diamond","default:stick",  "default:diamond"},
		{"default:diamond","default:stick",  "default:diamond"},
	},
})

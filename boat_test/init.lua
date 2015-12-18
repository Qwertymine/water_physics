dofile(minetest.get_modpath("boat_test").."/infotools.lua")

--values for complex physics
local BOATRAD = 0.4
local PARTICLES = true
local MOVECENTRE = false
--Physics Constants are at line 100-ish

--helper functions
local function get_velocity_vector(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local function boat_particles(object,velocity,realpos)
	if object:get_luaentity().in_water == false then
		--do sounds and particles for water bounces
		if velocity.y < 0 and velocity.y > -3 then
			minetest.sound_play("soft_splash", {
				pos = {object:getpos()},
				max_hear_distance = 20,
				gain = 0.01,
			})
			minetest.add_particlespawner({
				amount = 10,
				time = 1,
				minpos = {x=realpos.x-1, y=realpos.y, z=realpos.z-1},
				maxpos = {x=realpos.x+1, y=realpos.y, z=realpos.z+1},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=0, z=0},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=1, z=0},
				minexptime = 1,
				maxexptime = 1,
				minsize = 1,
				maxsize = 1,
				collisiondetection = false,
				vertical = false,
				texture = "bubble.png",
			})


		elseif velocity.y <= -3 and velocity.y > -10 then
			minetest.sound_play("medium_splash", {
				pos = {object:getpos()},
				max_hear_distance = 20,
				gain = 0.05,
			})
			minetest.add_particlespawner({
				amount = 15,
				time = 1,
				minpos = {x=realpos.x-1, y=realpos.y, z=realpos.z-1},
				maxpos = {x=realpos.x+1, y=realpos.y, z=realpos.z+1},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=0, z=0},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=2, z=0},
				minexptime = 1,
				maxexptime = 1,
				minsize = 1,
				maxsize = 1,
				collisiondetection = false,
				vertical = false,
				texture = "bubble.png",
			})

		elseif velocity.y <= -10 then
			minetest.sound_play("big_splash", {
				pos = {object:getpos()},
				max_hear_distance = 20,
				gain = 0.07,
			})
			minetest.add_particlespawner({
				amount = 20,
				time = 0.5,
				minpos = {x=realpos.x-1, y=realpos.y, z=realpos.z-1},
				maxpos = {x=realpos.x+1, y=realpos.y, z=realpos.z+1},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=0, z=0},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=3, z=0},
				minexptime = 1,
				maxexptime = 1,
				minsize = 1,
				maxsize = 1,
				collisiondetection = false,
				vertical = false,
				texture = "bubble.png",
			})
		end
	end
end

--if not in water but touching, move centre to touching block
--x has higher precedence than z
--if pos changes with x, it affects z
local function move_centre(pos,realpos,node,BOATRAD)
	if flowlib.is_touching(realpos.x,pos.x,BOATRAD) then
		if flowlib.is_liquid({x=pos.x-1,y=pos.y,z=pos.z}) then
			node = minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z})
			pos = {x=pos.x-1,y=pos.y,z=pos.z}
		elseif flowlib.is_liquid({x=pos.x+1,y=pos.y,z=pos.z}) then
			node = minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z})
			pos = {x=pos.x+1,y=pos.y,z=pos.z}
		end
	end
	if flowlib.is_touching_water(realpos.z,pos.z,BOATRAD) then
		if flowlib.is_liquid({x=pos.x,y=pos.y,z=pos.z-1}) then
			node = minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1})
			pos = {x=pos.x,y=pos.y,z=pos.z-1}
		elseif flowlib.is_liquid({x=pos.x,y=pos.y,z=pos.z+1}) then
			node = minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1})
			pos = {x=pos.x,y=pos.y,z=pos.z+1}
		end
	end
	return pos,node
end

local boat_test = {
	physical = true,
	collisionbox = {-0.4, -0.4, -0.4, 0.4, 0.3, 0.4},
	visual = "mesh",
	mesh = "boat.obj",
	textures = {"default_wood.png"},
	automatic_face_movement_dir = -90.0,
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
	in_water = false,
	--off the map to garentee update
	--uses minetest.hash_node_position
	pos_last = nil,
	flow_last = nil,
	flow_timer = 1,

}

function boat_test.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
		default.player_attached[name] = false
		default.player_set_animation(clicker, "stand" , 30)
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x = 0, y = 11, z = -3}, {x = 0, y = 0, z = 0})
		default.player_attached[name] = true
		minetest.after(0.2, function()
			default.player_set_animation(clicker, "sit" , 30)
		end)
		self.object:setyaw(clicker:get_look_yaw() - math.pi / 2)
	end
end

function boat_test.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
	self.pos_last = {x=math.huge,y=0,z=math.huge}
	self.flow_last = {x=0,y=0,z=0}
end

function boat_test.get_staticdata(self)
	return tostring(self.v)
end

function boat_test.on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end
	if self.driver and puncher == self.driver then
		self.driver = nil
		puncher:set_detach()
		default.player_attached[puncher:get_player_name()] = false
	end
	if not self.driver then
		self.removed = true
		-- delay remove to ensure player is detached
		minetest.after(0.1, function()
			self.object:remove()
		end)
		if not minetest.setting_getbool("creative_mode") then
			puncher:get_inventory():add_item("main", "boat_test:boat")
		end
	end
end

local player_mass = 740 --N
local boat_mass = 1000 --N
local player_force = 5220--3*1740 N
local water_force = 4500--4.5*1000 N
local player_turn_force = 3000--3*1000 N
local water_resistance = 200 --N/speed^2

function boat_test.on_step(self, dtime)
	--object synonims
	local driver = self.driver
	local object = self.object
	--physics constants
	local total_mass = boat_mass
	--vectors
	--other
	local velocity = object:getvelocity()
	local realpos = self.object:getpos()
	local pos = {x=math.floor(realpos.x+0.5),y=math.floor(realpos.y+0.5)
		,z=math.floor(realpos.z+0.5)}
	local node   = minetest.get_node({x=pos.x,y=pos.y,z=pos.z})
	local beached = false
	
	--setup physics variables
	local yaw = object:getyaw()
	--setup self.v and any dependant variables
	self.v = math.abs(get_v(velocity))
	
	
	
	--if moving the centre of the boat is expensive, disabled by default
	if MOVECENTRE and flowlib.node_is_liquid(node) then
		pos,node = move_centre(pos,realpos,node,BOATRAD)
	end
	
	local flow

	--make it float
	if flowlib.node_is_liquid(node) then
		--boat particles and sounds are pretty, enabled by default
		--get initial water direction
		if pos.x == self.pos_last.x and pos.y == self.pos_last.y
		and pos.z == self.pos_last.z then
			self.flow_timer = self.flow_timer - dtime
			if self.flow_timer < 0 then
				flow = flowlib.quick_flow(pos,node)
				self.flow_last.x = flow.x
				self.flow_last.z = flow.z
				self.flow_timer = 1
			else
				flow = table.copy(self.flow_last)
			end
		else
			flow = flowlib.quick_flow(pos,node)
			self.flow_last.x = flow.x
			self.flow_last.z = flow.z
			self.flow_timer = 1
			self.pos_last = pos
		end

		flow.x = flow.x*water_force ; flow.z = flow.z*water_force


		if PARTICLES then
			boat_particles(object,velocity,realpos)
		end
		--logic for floating smoothly in water
		self.in_water = true
		if (math.abs(velocity.y) < 0.3) and 
		(not flowlib.is_liquid({x=pos.x,y=pos.y+1,z=pos.z})) and 
		(realpos.y - pos.y) > 0.2 then
			--this sets the boat to sit just below the surface of
			--the liquid
			if math.abs(velocity.y) < 0.1 and (realpos.y - pos.y) > 0.4 then
				velocity.y = 0 
				object:setpos({x=realpos.x,y=pos.y+0.45,z=realpos.z})
			else
				flow.y = 0.5
			end
		--slow down boats that fall into water smoothly
		elseif velocity.y < 0 then
			flow.y = 10
		else
			flow.y = 4
		end
	--make it fall when not in water
	else
	--beach it
		flow = {x=0,y=0,z=0}
		local node_below = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
		if minetest.registered_nodes[node_below.name].walkable == true then
			flow.y = -10
			velocity.x = 0
			velocity.z = 0
			beached = true
			self.in_water = false
		--logic for floating smoothly in water
		elseif (math.abs(velocity.y) < 0.3) and 
		(flowlib.node_is_liquid(node_below)) and 
		(pos.y - realpos.y) > 0.2 then
		--must fall faster than float - flow physics only happen while in water
			flow.y = -3
			self.in_water = true
		else
			flow.y = -10
			self.in_water = false
		end
	end
	
	local player_turn_force = player_turn_force * self.v
	if beached then
		player_turn_force = 30
	end
	
	local water_resistance_vector = get_velocity_vector(water_resistance
			*self.v*self.v,yaw,0)
	if driver then
		total_mass = boat_mass + player_mass
		local player_force_vector
		local turn_force_vector
		local ctrl = self.driver:get_player_control()
		if ctrl.up and not beached then
			player_force_vector = get_velocity_vector(player_force,yaw,0)
		elseif ctrl.down and not beached then
			--if moving very slowly
			if not (self.v < 0.2) then
			--Multiplies by speed to avoid issues with turning multiple times
				player_force_vector = get_velocity_vector(-player_force*self.v,yaw,0)
			else
				velocity.x = 0
				velocity.z = 0
			end
		end
		--add to flow
		if player_force_vector then
			flow.x = flow.x + player_force_vector.x 
			flow.z = flow.z + player_force_vector.z	
		end

		if ctrl.left then
			if self.v < 0.05 then
				self.v = 0.05
				velocity = get_velocity_vector(self.v,yaw,velocity.y)
			end
			turn_force_vector = get_velocity_vector(player_turn_force,yaw+90,0)
		elseif ctrl.right then
			if self.v < 0.05 then
				self.v = 0.05
				velocity = get_velocity_vector(self.v,yaw,velocity.y)
			end
			--correct yaw change to turn right is 89 for some reason...
			turn_force_vector = get_velocity_vector(-player_turn_force,yaw+89,0)
		end
		--add to flow
		if turn_force_vector then
			flow.x = flow.x + turn_force_vector.x
			flow.z = flow.z + turn_force_vector.z
		end
	end
	--add any more functionality before this block
	object:setpos(self.object:getpos())
	object:setvelocity({x=velocity.x,y=velocity.y,z=velocity.z})
	object:setacceleration({x=(flow.x-water_resistance_vector.x)/total_mass,y=flow.y,z=(flow.z-water_resistance_vector.z)/total_mass})
end

minetest.register_entity("boat_test:boat", boat_test)

minetest.register_craftitem("boat_test:boat", {
	description = "boat_test boat boat",
	inventory_image = "boat_inventory.png",
	wield_image = "boat_wield.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		--if not is_water(pointed_thing.under) then
		--	return
		--end
		pointed_thing.under.y = pointed_thing.under.y + 1.0
		pointed_thing.under.y = pointed_thing.under.y
		minetest.add_entity(pointed_thing.under, "boat_test:boat")
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})


minetest.register_craft({
	output = "boat_test:boat",
	recipe = {
		{"","",""                              },
		{"group:tree","group:tree","group:tree"},
		{"group:tree","group:tree","group:tree"},
	},
})


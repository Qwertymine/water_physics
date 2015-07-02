function boat_particles(object,velocity,realpos)
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
function move_centre(pos,realpos,node,BOATRAD)
	if is_touching_water(realpos.x,pos.x,BOATRAD) then
		if is_water({x=pos.x-1,y=pos.y,z=pos.z}) then
			node = minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z})
			pos = {x=pos.x-1,y=pos.y,z=pos.z}
		elseif is_water({x=pos.x+1,y=pos.y,z=pos.z}) then
			node = minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z})
			pos = {x=pos.x+1,y=pos.y,z=pos.z}
		end
	end
	if is_touching_water(realpos.z,pos.z,BOATRAD) then
		if is_water({x=pos.x,y=pos.y,z=pos.z-1}) then
			node = minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1})
			pos = {x=pos.x,y=pos.y,z=pos.z-1}
		elseif is_water({x=pos.x,y=pos.y,z=pos.z+1}) then
			node = minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1})
			pos = {x=pos.x,y=pos.y,z=pos.z+1}
		end
	end
	return pos,node
end

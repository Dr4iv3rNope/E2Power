util.AddNetworkString("e2p_particles_create")

local whitelist_materials = {
	["effects/blooddrop"] = true,
	["effects/bloodstream"] = true,
	["effects/laser_tracer"] = true,
	["effects/select_dot"] = true,
	["effects/select_ring"] = true,
	["effects/tool_tracer"] = true,
	["effects/wheel_ring"] = true,
	["effects/base"] = true,
	["effects/blood"] = true,
	["effects/blood2"] = true,
	["effects/blood_core"] = true,
	["effects/blood_drop"] = true,
	["effects/blood_gore"] = true,
	["effects/blood_puff"] = true,
	["effects/blueblackflash"] = true,
	["effects/blueblacklargebeam"] = true,
	["effects/blueflare1"] = true,
	["effects/bluelaser1"] = true,
	["effects/bluemuzzle"] = true,
	["effects/bluespark"] = true,
	["effects/bubble"] = true,
	["effects/combinemuzzle1"] = true,
	["effects/combinemuzzle1_dark"] = true,
	["effects/combinemuzzle2"] = true,
	["effects/combinemuzzle2_dark"] = true,
	["effects/energyball"] = true,
	["effects/energysplash"] = true,
	["effects/exit1"] = true,
	["effects/fire_cloud1"] = true,
	["effects/fire_cloud2"] = true,
	["effects/fire_embers1"] = true,
	["effects/fire_embers2"] = true,
	["effects/fire_embers3"] = true,
	["effects/fleck_glass1"] = true,
	["effects/fleck_glass2"] = true,
	["effects/fleck_glass3"] = true,
	["effects/fleck_tile1"] = true,
	["effects/fleck_tile2"] = true,
	["effects/fleck_wood1"] = true,
	["effects/fleck_wood2"] = true,
	["effects/fog_d1_trainstation_02"] = true,
	["effects/gunshipmuzzle"] = true,
	["effects/gunshiptracer"] = true,
	["effects/hydragutbeam"] = true,
	["effects/hydragutbeamcap"] = true,
	["effects/hydraspinalcord"] = true,
	["effects/laser1"] = true,
	["effects/laser_citadel1"] = true,
	["effects/mh_blood1"] = true,
	["effects/mh_blood2"] = true,
	["effects/mh_blood3"] = true,
	["effects/muzzleflash1"] = true,
	["effects/muzzleflash2"] = true,
	["effects/muzzleflash3"] = true,
	["effects/muzzleflash4"] = true,
	["effects/redflare"] = true,
	["effects/rollerglow"] = true,
	["effects/slime1"] = true,
	["effects/spark"] = true,
	["effects/splash1"] = true,
	["effects/splash2"] = true,
	["effects/splash3"] = true,
	["effects/splash4"] = true,
	["effects/splashwake1"] = true,
	["effects/splashwake3"] = true,
	["effects/splashwake4"] = true,
	["effects/strider_bulge_dudv"] = true,
	["effects/strider_muzzle"] = true,
	["effects/strider_pinch_dudv"] = true,
	["effects/strider_tracer"] = true,
	["effects/stunstick"] = true,
	["effects/tracer_cap"] = true,
	["effects/tracer_middle"] = true,
	["effects/tracer_middle2"] = true,
	["effects/water_highlight"] = true,
	["effects/yellowflare"] = true,
	["effects/muzzleflashX"] = true,
	["effects/ember_swirling001"] = true,
	["shadertest/eyeball"] = true,
	["sprites/bloodparticle"] = true,
	["sprites/animglow02"] = true,
	["sprites/ar2_muzzle1"] = true,
	["sprites/ar2_muzzle3"] = true,
	["sprites/ar2_muzzle4"] = true,
	["sprites/flamelet1"] = true,
	["sprites/flamelet2"] = true,
	["sprites/flamelet3"] = true,
	["sprites/flamelet4"] = true,
	["sprites/flamelet5"] = true,
	["sprites/glow03"] = true,
	["sprites/light_glow02"] = true,
	["sprites/orangecore1"] = true,
	["sprites/orangecore2"] = true,
	["sprites/orangeflare1"] = true,
	["sprites/plasmaember"] = true,
	["sprites/redglow1"] = true,
	["sprites/redglow2"] = true,
	["sprites/rico1"] = true,
	["sprites/strider_blackball"] = true,
	["sprites/strider_bluebeam"] = true,
	["sprites/tp_beam001"] = true,
	["sprites/yellowflare"] = true,
	["sprites/frostbreath"] = true,
	["sprites/sent_ball"] = true,
}

local function particle(e2, data)
	if not E2P.ProcessRestriction(e2, E2P.BASIC) then return end

	net.Start("e2p_particles_create")
	net.WriteEntity(e2.entity)
	net.WriteString(data.material)
	net.WriteVector(data.pos)
	net.WriteFloat(data.pitch)
	net.WriteInt(data.roll_delta, 8)
	net.WriteUInt(data.start_alpha, 8)
	net.WriteUInt(data.end_alpha, 8)
	net.WriteUInt(data.start_size, 16)
	net.WriteUInt(data.end_size, 16)
	net.WriteFloat(data.die_time)
	net.WriteColor(data.color)
	net.WriteVector(data.velocity)
	net.WriteVector(e2.data.e2p_particle_data.gravity)
	net.WriteBool(e2.data.e2p_particle_data.collide)
	net.WriteFloat(e2.data.e2p_particle_data.bounce)
end

registerCallback("construct", function(e2)
	e2.data.e2p_particle_data = {
		gravity= Vector(0, 0, -9.8),
		collide = true,
		bounce = 0.3,
	}
end)

__e2setcost(500)

e2function void particle(
	number die_time,
	number start_size,
	number end_size,
	string material,
	vector color,
	vector pos,
	vector velocity,
	number pitch,
	number roll_delta,
	number start_alpha,
	number end_alpha
)
	particle(self, {
		die_time = die_time,
		start_size = start_size,
		end_size = end_size,
		material = material,
		color = color,
		pos = pos,
		velocity = velocity,
		pitch = pitch,
		roll_delta = roll_delta,
		start_alpha = start_alpha,
		end_alpha = end_alpha
	})
end

e2function void particle(
	number die_time,
	number start_size,
	number end_size,
	string material,
	vector color,
	vector pos,
	vector velocity,
	number pitch,
	number roll_delta
)
	particle(self, {
		die_time = die_time,
		start_size = start_size,
		end_size = end_size,
		material = material,
		color = color,
		pos = pos,
		velocity = velocity,
		pitch = pitch,
		roll_delta = roll_delta,
		start_alpha = 255,
		end_alpha = 255
	})
end

e2function void particle(
	number die_time,
	number start_size,
	number end_size,
	string material,
	vector color,
	vector pos,
	vector velocity,
	number pitch
)
	particle(self, {
		die_time = die_time,
		start_size = start_size,
		end_size = end_size,
		material = material,
		color = color,
		pos = pos,
		velocity = velocity,
		pitch = pitch,
		roll_delta = 0,
		start_alpha = 255,
		end_alpha = 255
	})
end

e2function void particle(
	number die_time,
	number start_size,
	number end_size,
	string material,
	vector color,
	vector pos,
	vector velocity
)
	particle(self, {
		die_time = die_time,
		start_size = start_size,
		end_size = end_size,
		material = material,
		color = color,
		pos = pos,
		velocity = velocity,
		pitch = 0,
		roll_delta = 0,
		start_alpha = 255,
		end_alpha = 255
	})
end

__e2setcost(50)

e2function void particleGravity(vector gravity)
	gravity = Vector(gravity[0], gravity[1], gravity[2])

	self.e2.data.e2p_particle_data.gravity = gravity
end

e2function void particleCollision(number enable)
	self.e2.data.e2p_particle_data.collide = collide ~= 0
end

e2function void particleBounce(number bounce)
	self.e2.data.e2p_particle_data.bounce = bounce
end

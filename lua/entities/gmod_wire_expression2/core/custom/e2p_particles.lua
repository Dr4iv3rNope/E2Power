local particle_limit = CreateConVar("wire_expression2_e2p_particle_limit", "10", FCVAR_ARCHIVE)
local particle_cooldown = CreateConVar("wire_expression2_e2p_particle_cooldown", "0.1", FCVAR_ARCHIVE)

util.AddNetworkString("e2p_particles_create")

local whitelist_materials = {
	["effects/blooddrop"] = true,
	["effects/select_dot"] = true,
	["effects/base"] = true,
	["effects/blood"] = true,
	["effects/blood2"] = true,
	["effects/blood_core"] = true,
	["effects/blood_drop"] = true,
	["effects/blood_gore"] = true,
	["effects/blood_puff"] = true,
	["effects/blueblackflash"] = true,
	["effects/bluelaser1"] = true,
	["effects/bluemuzzle"] = true,
	["effects/bluespark"] = true,
	["effects/bubble"] = true,
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
	["effects/slime1"] = true,
	["effects/splash1"] = true,
	["effects/splash2"] = true,
	["effects/splash3"] = true,
	["effects/splash4"] = true,
	["effects/splashwake1"] = true,
	["effects/splashwake3"] = true,
	["effects/splashwake4"] = true,
	["effects/strider_bulge_dudv"] = true,
	["effects/strider_pinch_dudv"] = true,
	["effects/strider_tracer"] = true,
	["effects/tracer_cap"] = true,
	["effects/tracer_middle"] = true,
	["effects/tracer_middle2"] = true,
	["effects/water_highlight"] = true,
	["shadertest/eyeball"] = true,
	["sprites/animglow02"] = true,
	["sprites/glow03"] = true,
	["sprites/light_glow02"] = true,
	["sprites/plasmaember"] = true,
	["sprites/redglow2"] = true,
	["sprites/strider_blackball"] = true,
	["sprites/yellowflare"] = true,
	["sprites/sent_ball"] = true,
}

local function processParticleLimit(e2, data)
	local ply = e2.player
	local count = ply._e2p_particle_limit or 0

	if count > particle_limit:GetInt() then
		e2:throw("Particle limit!")

		return false
	end

	timer.Create("e2p reset particle limit " .. ply:UserID(), data.die_time, 1, function()
		if not IsValid(ply) then return end

		ply._e2p_particle_limit = nil
	end)

	ply._e2p_particle_limit = count + 1

	return true
end

local function particle(e2, data)
	if not E2P.ProcessRestriction(e2, E2P.BASIC) then return end

	data.material = data.material:lower()

	if not whitelist_materials[data.material] then
		return e2:throw("Particle material is not whitelisted!")
	end

	if not e2.player:TimeoutAction("e2p particle cooldown", particle_cooldown:GetFloat()) then
		return e2:throw("Particle spawn cooldown!")
	end

	data.die_time = math.Clamp(data.die_time, 0.1, 10)
	data.start_size = math.Clamp(data.start_size, 0, 5)
	data.end_size = math.Clamp(data.end_size, 0, 5)

	if not processParticleLimit(e2, data) then return end

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
	net.Broadcast()
end

registerCallback("construct", function(e2)
	e2.data.e2p_particle_data = {
		gravity = Vector(0, 0, -9.8),
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
	color = Color(color[1], color[2], color[3])
	pos = Vector(pos[1], pos[2], pos[3])
	velocity = Vector(velocity[1], velocity[2], velocity[3])

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
	color = Color(color[1], color[2], color[3])
	pos = Vector(pos[1], pos[2], pos[3])
	velocity = Vector(velocity[1], velocity[2], velocity[3])

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
	color = Color(color[1], color[2], color[3])
	pos = Vector(pos[1], pos[2], pos[3])
	velocity = Vector(velocity[1], velocity[2], velocity[3])

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
	color = Color(color[1], color[2], color[3])
	pos = Vector(pos[1], pos[2], pos[3])
	velocity = Vector(velocity[1], velocity[2], velocity[3])

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

__e2setcost(10)

e2function void particleGravity(vector gravity)
	gravity = Vector(gravity[1], gravity[2], gravity[3])

	self.e2.data.e2p_particle_data.gravity = gravity
end

e2function void particleCollision(number enable)
	self.e2.data.e2p_particle_data.collide = collide ~= 0
end

e2function void particleBounce(number bounce)
	self.e2.data.e2p_particle_data.bounce = bounce
end

e2function number particleLimit()
	return particle_limit:GetInt()
end

e2function number hasParticleLimit()
	local count = ply._e2p_particle_limit or 0
	local hasLimit = count > particle_limit:GetInt()

	return hasLimit and 1 or 0
end

e2function number particleCooldown()
	return particle_cooldown:GetFloat()
end

e2function number hasParticleCooldown()
	local hasCooldown = not self.player:TimeoutIsExpired()

	return hasCooldown and 1 or 0
end

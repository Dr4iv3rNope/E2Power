local particles = {}
local emitter = ParticleEmitter(Vector())

net.Receive("e2p_particles_create", function()
	local e2			= net.ReadEntity()
	local material		= net.ReadString()
	local pos			= net.ReadVector()
	local pitch			= net.ReadFloat()
	local roll_delta	= net.ReadInt(8)
	local start_alpha	= net.ReadUInt(8)
	local end_alpha		= net.ReadUInt(8)
	local start_size	= net.ReadUInt(16)
	local end_size		= net.ReadUInt(16)
	local die_time		= net.ReadFloat()
	local color			= net.ReadColor()
	local velocity		= net.ReadVector()
	local gravity		= net.ReadVector()
	local collide		= net.ReadBool()
	local bounce		= net.ReadFloat()

	local e2_particles = particles[e2]

	if not e2_particles then
		e2_particles = {}

		particles[e2] = e2_particles
	end

	local particle = emitter:Add(material, pos)
	particle:SetAngles(Angle(pitch, 0, 0))
	particle:SetRollDelta(roll_delta)
	particle:SetStartAlpha(start_alpha)
	particle:SetEndAlpha(end_alpha)
	particle:SetStartSize(start_size)
	particle:SetEndSize(end_size)
	particle:SetDieTime(die_time)
	particle:SetColor(color)
	particle:SetVelocity(velocity)
	particle:SetGravity(gravity)
	particle:SetCollide(collide)
	particle:SetBounce(bounce)

	table.insert(e2_particles, particle)
end)

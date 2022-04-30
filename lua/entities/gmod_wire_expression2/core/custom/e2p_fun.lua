
local blacklist_effects = {
	["dof_node"] = true,
	["smoke"] = true,
	["hl1gaussbeam"] = true
}

local function createExplosion(inflictor, attacker, pos, radius, damage)
	util.BlastDamage(inflictor, attacker, pos, radius, damage)

	local effectData = EffectData()
	effectData:SetOrigin(pos)
	util.Effect("explosion", effectData)
end

local damage_types = {
	ACID =					1048576,
	AIRBOAT =				33554432,
	ALWAYSGIB =				8192,
	BLAST =					64,
	BLAST_SURFACE =			134217728,
	BUCKSHOT =				536870912,
	BULLET =				2,
	BURN =					8,
	CLUB =					128,
	CRUSH =					1,
	DIRECT =				268435456,
	DISSOLVE =				67108864,
	DROWN =					16384,
	DROWNRECOVER =			524288,
	ENERGYBEAM =			1024,
	FALL =					32,
	GENERIC =				0,
	NERVEGAS =				65536,
	NEVERGIB =				4096,
	PARALYZE =				32768,
	PHYSGUN =				8388608,
	PLASMA =				16777216,
	POISON =				131072,
	PREVENT_PHYSICS_FORCE =	2048,
	RADIATION =				262144,
	REMOVENORAGDOLL =		4194304,
	SHOCK =					256,
	SLASH =					4,
	SLOWBURN =				2097152,
	SONIC =					512,
	VEHICLE =				16,
}

local function takeDamage(ent, ply, damage, type, force, attacker, inflictor)
	if not ply:HasE2PLevel(E2P.ADVANCED) then
		damage = math.Clamp(damage, 1, 100)
		attacker = self.player
		inflictor = self.entity
	end

	local dmg = DamageInfo()
	dmg:SetDamage(damage)
	dmg:SetDamageType(damage_types[type:upper()] or damage_types.GENERIC)
	dmg:SetAttacker(attacker or ply)
	dmg:SetInflictor(inflictor or ply)
	dmg:SetDamageForce(force or Vector())

	ent:TakeDamageInfo(dmg)
end

__e2setcost(100)

e2function void entity:shootTo(vector start, vector dir, number spread, number force, number damage, string effect)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	effect = effect:lower()

	if blacklist_effects[effect] then
		error(string.format("Эффект %s запрещен!", effect))
	end

	local bullet = {
		Num = 1,
		Src = start,
		Dir = Vector(dir[1], dir[2], dir[3]),
		Spread = Vector(spread, spread, 0),
		Tracer = 1,
		TracerName = effect,
		Force = math.Clamp(force, 0, 10000),
		Damage = damage,
		Attacker = self.player,
	}

	this:FireBullets(bullet)
end

e2function void shake(vector pos, number amplitude, number frequency, number duration, number radius)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	pos = Vector(pos[1], pos[2], pos[3])

	util.ScreenShake(pos, amplitude, frequency, duration, radius)
end

e2function void explosion(number damage, number radius, vector pos)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	pos = Vector(pos[1], pos[2], pos[3])

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		damage = math.Clamp(damage, 1, 100)
		radius = math.Clamp(radius, 0, 1000)
	end

	util.BlastDamage(
		self.player,
		self.player,
		pos,
		radius,
		damage
	)
end

e2function void entity:explosion(number damage, number radius)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		damage = math.Clamp(damage, 1, 100)
		radius = math.Clamp(radius, 0, 1000)
	end

	createExplosion(
		this,
		self.player,
		this:GetPos(),
		radius,
		damage
	)
end

e2function void entity:explosion()
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	local radius = this:OBBMaxs() - this:OBBMins()
	radius = (radius.x^2 + radius.y^2 + radius.z^2) ^ 0.5

	createExplosion(
		this,
		self.player,
		this:GetPos(),
		radius * 10,
		radius * 3
	)
end

e2function void explosion(number damage, number radius, vector pos, entity attacker, entity inflictor)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	pos = Vector(pos[1], pos[2], pos[3])

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		damage = math.Clamp(damage, 1, 100)
		radius = math.Clamp(radius, 0, 1000)
		attacker = self.player
		inflictor = self.entity
	end

	createExplosion(inflictor, attacker, pos, radius, damage)
end

e2function void explosion(vector pos)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	pos = Vector(pos[1], pos[2], pos[3])

	createExplosion(self.entity, self.player, pos, 100, 100)
end

e2function void entity:takeDamage(number damage, string type)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	takeDamage(this, self.player, damage, type)
end

e2function void entity:takeDamage(number damage, string type, vector force)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	force = Vector(force[1], force[2], force[3])

	takeDamage(this, self.player, damage, type, force)
end

e2function void entity:takeDamage(number damage, string type, vector force, entity attacker, entity inflictor)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	force = Vector(force[1], force[2], force[3])

	takeDamage(this, self.player, damage, type, force, attacker, inflictor)
end

e2function void entity:takeDamage(number damage, entity attacker, entity inflictor)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	takeDamage(this, self.player, damage, "GENERIC", 0, attacker, inflictor)
end

e2function void entity:takeDamage(number damage)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	takeDamage(this, self.player, damage, "GENERIC", 0, self.player, self.entity)
end

e2function void noDuplications()
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end

	self.entity.original	= "selfDestruct()"
	self.entity.buffer		= "selfDestruct()"
	self.entity._original	= "selfDestruct()"
	self.entity._buffer		= "selfDestruct()"
end

e2function void hideMyAss(number hide)
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end

	self.entity:SetNoDraw(true)
	self.entity:SetPos(Vector())
end

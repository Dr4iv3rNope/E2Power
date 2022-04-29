local entity_spawn_cooldown = CreateConVar("wire_expression2_e2p_entity_spawn_cooldown", "1", FCVAR_ARCHIVE)

local whitelist = {
	["rpg_missile"] = true,
	["crossbow_bolt"] = true,
	["item_healthvial"] = true,
	["item_healthkit"] = true,
	["item_battery"] = true
}

local function canSpawnEntity(class)
	return whitelist[class]
end

local function entitySpawn(e2, class, pos, ang, freeze)
	if not E2P.ProcessRestriction(e2, E2P.BASIC) then return end

	if not e2.player:TimeoutAction("e2p entitySpawn cooldown", entity_spawn_cooldown:GetFloat()) then
		return e2:throw("Entity spawn cooldown!")
	end

	pos = pos or (e2.entity:GetPos() + (e2.entity:GetUp() * 25))
	ang = ang or e2.entity:GetAngles()

	if not canSpawnEntity(class) then
		return e2:throw("Entity class is not whitelisted!")
	end

	local ent = ents.Create(class)
	if not IsValid(ent) then return e2:throw("Failed to create entity", nil) end

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetOwner(e2.player)
	ent:Spawn()

	local phys = ent:GetPhysicsObject()

	if IsValid(phys) then
		phys:EnableMotion(freeze)
		phys:Wake()
	end

	e2.player:AddCleanup("props", ent)

	undo.Create(string.format("entitySpawn %s", tostring(ent)))
	undo.AddEntity(ent)
	undo.SetPlayer(e2.player)
	undo.Finish()

	return ent
end

__e2setcost(500)

e2function entity entitySpawn(string class, number frozen)
	return entitySpawn(self, class, nil, nil, frozen == true)
end

e2function entity entitySpawn(entity template, number frozen)
	if not IsValid(template) then return end

	return entitySpawn(self, template:GetClass(), nil, nil, frozen ~= 0)
end

e2function entity entitySpawn(string class, vector pos, number frozen)
	pos = Vector(pos[0], pos[1], pos[2])

	return entitySpawn(self, class, pos, nil, frozen ~= 0)
end

e2function entity entitySpawn(entity template, vector pos, number frozen)
	if not IsValid(template) then return end

	pos = Vector(pos[0], pos[1], pos[2])

	return entitySpawn(self, template:GetClass(), pos, nil, frozen ~= 0)
end

e2function entity entitySpawn(string class, angle ang, number frozen)
	ang = Angle(ang[0], ang[1], ang[2])

	return entitySpawn(self, class, nil, ang, frozen ~= 0)
end

e2function entity entitySpawn(entity template, angle ang, number frozen)
	if not E2P.ProcessValidEntity(self, template) then return end

	ang = Angle(ang[0], ang[1], ang[2])

	return entitySpawn(self, template:GetClass(), nil, ang, frozen ~= 0)
end

e2function entity entitySpawn(string class, vector pos, angle ang, number frozen)
	pos = Vector(pos[0], pos[1], pos[2])
	ang = Angle(ang[0], ang[1], ang[2])

	return entitySpawn(self, class, pos, ang, frozen ~= 0)
end

e2function entity entitySpawn(entity template, vector pos, angle ang, number frozen)
	pos = Vector(pos[0], pos[1], pos[2])
	ang = Angle(ang[0], ang[1], ang[2])

	if not E2P.ProcessValidEntity(self, template) then return end

	return entitySpawn(self, template:GetClass(), pos, ang, frozen ~= 0)
end

__e2setcost(100)

e2function void entity:setModel(string model)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	this:SetModel(model)
	this:PhysicsInit(this:GetSolid())
end

e2function void entity:setOwnerNoEntity()
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidEntity(self, this) then return end

	this:SetOwner(nil)
end

__e2setcost(10)

e2function void entity:setHealth(number health)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		health = math.Clamp(health, 0, this:GetMaxHealth())
	end

	this:SetHealth(health)
end

e2function void entity:heal(number amount)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		local amount_to_full_hp = math.max(0, this:GetMaxHealth() - amount)

		amount = math.Clamp(amount, 0, amount_to_full_hp)
	end

	this:SetHealth(math.Clamp(this:Health() + amount, 0, E2P.INT_MAX))
end

e2function void entity:setMaxHealth(number health)
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	this:SetMaxHealth(math.Clamp(health, 0, E2P.INT_MAX))
end

e2function void entity:ignite(number duration)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	this:Ignite(duration, 0)
end

e2function void entity:extinguish()
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	this:Extinguish()
end

__e2setcost(50)

e2function void entity:setFire(string input, string param, number delay)
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end
	if not E2P.ProcessValidEntity(self, this) then return end

	this:Fire(input, param, delay)
end

e2function void entity:setKeyValue(string name, value)
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end
	if not E2P.ProcessValidEntity(self, this) then return end

	this:SetKeyValue(name, value)
end

e2function void entity:remove()
	if not E2P.ProcessIsOwner(self, this) then return end

	SafeRemoveEntity(this)
end

e2function void entity:remove(number second)
	if not E2P.ProcessIsOwner(self, this) then return end

	SafeRemoveEntityDelayed(this, second)
end

e2function void entity:noCollideAll(number state)
	if not E2P.ProcessIsOwner(self, this) then return end

	this:SetCollisionGroup(state ~= 0 and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE)
end

e2function void entity:setVel(vector velocity)
	if not E2P.ProcessIsOwner(self, this) then return end

	velocity = Vector(velocity[0], velocity[1], velocity[2])

	local phys = this:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetVelocity(velocity)
	else
		this:SetVecloity(velocity)
	end
end

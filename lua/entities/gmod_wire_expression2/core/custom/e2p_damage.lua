-- [Entity] = (Set of expression2s)
local damageListeners = {}

local function listenEntity(e2, ent)
	local listeners = damageListeners[ent]

	if not listeners then
		listeners = x.Set()

		damageListeners[ent] = listeners
	end

	listeners:Insert(e2.entity)
	e2.data.e2pListeningEntities:Insert(ent)
end

local function unlistenEntity(e2, ent)
	local listeners = damageListeners[ent]
	if not listeners then return end

	listeners:Delete(e2.entity)
	e2.data.e2pListeningEntities:Delete(ent)
end

local function unlistenEntityAll(ent)
	local listeners = damageListeners[ent]
	if not listeners then return end

	local e2s = listeners.Values

	for i = 1, #e2s do
		local e2 = e2s[i]

		if IsValid(e2) then
			e2.context.data.e2pListeningEntities:Delete(ent)
		else
			-- FIXME: may break the code?
			--listeners:delete(e2)
		end
	end

	damageListeners[ent] = nil
end

registerCallback("construct", function(e2)
	e2.data.e2pListeningEntities = x.Set()
end)

registerCallback("destruct", function(e2)
	local entities = e2.data.e2pListeningEntities.Values

	for i = 1, #entities do
		local ent = entities[i]
		local listeners = damageListeners[ent]

		listeners:Delete(e2.entity)

		if listeners:Length() == 0 then
			damageListeners[ent] = nil
		end
	end
end)

hook.Add("EntityRemoved", "e2p damage", function(ent)
	unlistenEntityAll(ent)
end)

hook.Add("EntityTakeDamage", "e2p damage", function(ent, dmg)
	local listeners = damageListeners[ent]

	if listeners then
		ent.e2pLastDamage = {
			Damage		= dmg:GetDamage(),
			Attacker	= dmg:GetAttacker(),
			Inflictor	= dmg:GetInflictor(),
			Position	= dmg:GetDamagePosition(),
			Type		= dmg:GetDamageType()
		}

		local e2s = listeners.Values

		for i = 1, #e2s do
			local e2 = e2s[i]

			e2.context.data.e2pDamageClk = ent
			e2:Execute()
			e2.context.data.e2pDamageClk = nil
		end
	end
end)

__e2setcost(100)

e2function void runOnDamage(number active)
	if active ~= 0 then
		listenEntity(self, self.entity)
	else
		unlistenEntity(self, self.entity)
	end
end

e2function void runOnDamage(number active, entity ent)
	if not E2P.ProcessValidEntity(self, ent) then return end

	if active ~= 0 then
		listenEntity(self, ent)
	else
		unlistenEntity(self, ent)
	end
end

local function getLastDamageInfo(e2, ent)
	if not E2P.ProcessValidEntity(e2, ent) then return nil end
	if not damageListeners[ent] then return nil end

	return ent.e2pLastDamage
end

__e2setcost(10)

e2function number entity:getDamage()
	local lastDamage = getLastDamageInfo(self, this)
	if not lastDamage then return 0 end

	return lastDamage.damage
end

e2function entity entity:getAttacker()
	local lastDamage = getLastDamageInfo(self, this)
	if not lastDamage then return nil end

	return lastDamage.attacker
end

e2function entity entity:getInflictor()
	local lastDamage = getLastDamageInfo(self, this)
	if not lastDamage then return nil end

	return lastDamage.inflictor
end

e2function vector entity:getDamagePos()
	local lastDamage = getLastDamageInfo(self, this)
	if not lastDamage then return E2P.NULL_ARRAY3 end

	return lastDamage.pos
end

local damageTypes = {
	[1048576]	= "DMG_ACID",
	[33554432]	= "DMG_AIRBOAT",
	[8192]		= "DMG_ALWAYSGIB",
	[64]		= "DMG_BLAST",
	[134217728]	= "DMG_BLAST_SURFACE",
	[536870912]	= "DMG_BUCKSHOT",
	[2]			= "DMG_BULLET",
	[8]			= "DMG_BURN",
	[128]		= "DMG_CLUB",
	[1]			= "DMG_CRUSH",
	[268435456]	= "DMG_DIRECT",
	[67108864]	= "DMG_DISSOLVE",
	[16384]		= "DMG_DROWN",
	[524288]	= "DMG_DROWNRECOVER",
	[1024]		= "DMG_ENERGYBEAM",
	[32]		= "DMG_FALL",
	[0]			= "DMG_GENERIC",
	[65536]		= "DMG_NERVEGAS",
	[4096]		= "DMG_NEVERGIB",
	[32768]		= "DMG_PARALYZE",
	[8388608]	= "DMG_PHYSGUN",
	[16777216]	= "DMG_PLASMA",
	[131072]	= "DMG_POISON",
	[2048]		= "DMG_PREVENT_PHYSICS_FORCE",
	[262144]	= "DMG_RADIATION",
	[4194304]	= "DMG_REMOVENORAGDOLL",
	[256]		= "DMG_SHOCK",
	[4]			= "DMG_SLASH",
	[2097152]	= "DMG_SLOWBURN",
	[512]		= "DMG_SONIC",
	[16]		= "DMG_VEHICLE",
}

e2function string entity:getDamageType()
	local lastDamage = getLastDamageInfo(self, this)
	if not lastDamage then return "" end

	return damageTypes[lastDamage.type] or ""
end

__e2setcost(1)

e2function entity damageEntClk()
	return self.data.e2pDamageClk
end

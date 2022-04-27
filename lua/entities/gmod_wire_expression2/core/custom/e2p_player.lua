__e2setcost(10)

e2function void entity:setArmor(number armor)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		armor = math.Clamp(armor, 0, this:GetMaxArmor())
	end

	this:SetArmor(armor)
end

__e2setcost(100)

local function playerNoclip(e2, target, enable)
	if not IsValid(target) then return end
	if not target:IsPlayer() then return end

	if not e2.player:HasE2PLevel(E2P.ADVANCED) then
		if this ~= e2.player then return end

		if hook.Run("PlayerNoClip", target, enable) == false then
			return
		end
	end

	this:SetMoveType(enable and MOVETYPE_NOCLIP or MOVETYPE_WALK)
end

e2function void entity:playerNoclip(number enable)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	playerNoclip(self, this, enable ~= 0)
end

e2function void entity:playerNoclipToggle()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	local enable = this:GetMoveType() ~= MOVETYPE_NOCLIP

	playerNoclip(self, this, enable)
end

e2function void entity:playerModel(string model)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	if self.player:HasE2PLevel(E2P.ADVANCED) then
		if this ~= self.player then return end
	end

	model = player_manager.TranslatePlayerModel(model)

	this:SetModel(model)
end

__e2setcost(50)

e2function void entity:playerLock()
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:Lock()
end

e2function void entity:playerUnlock()
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:UnLock()
end

e2function void entity:playerFreeze()
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:Freeze(true)
end

e2function void entity:playerUnFreeze()
	if not E2P.ProcessRestriction(self, E2P.FULL) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:Freeze(false)
end

e2function void stripWeapons()
	self.player:StripWeapons()
end

e2function void entity:stripWeapons()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	if self.player:HasE2PLevel(E2P.ADVANCED) then
		if this ~= self.player then return end
	end

	this:StripWeapons()
end

e2function void entity:giveWeapon(string weapon)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	local weapon_info = weapons.GetStored(weapon)
	if not weapon_info then return end

	if not self.player:HasE2PLevel(E2P.BASIC) then
		if this ~= self.player then return end
	end

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		if hook.Run("PlayerGiveSWEP", weapon, weapon_info) == false then
			return
		end
	end

	this:Give(weapon)
end

e2function array entity:weapons()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetWeapons()
end

e2function string entity:getUserGroup()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetUserGroup()
end

e2function number entity:isUserGroup(string group)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:IsUserGroup(group) and 1 or 0
end

e2function void spawn()
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	self.player:Spawn()
end

e2function void entity:plyJumpPower(number power)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:SetJumpPower(power)
end

e2function void entity:plyRunSpeed(number speed)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:SetRunSpeed(speed)
end

e2function void entity:plyWalkSpeed(number speed)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:SetWalkSpeed(speed)
end

e2function void entity:plyCrouchWalkSpeed(number speed)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:SetCrouchedWalkSpeed(speed)
end

e2function number entity:plyGetRunSpeed()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetRunSpeed()
end

e2function number entity:plyGetWalkSpeed()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetWalkSpeed()
end

e2function number entity:plyGetMaxSpeed()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetMaxSpeed()
end

e2function number entity:plyGetJumpPower()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetJumpPower()
end

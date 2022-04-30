__e2setcost(10)

e2function void entity:setArmor(number armor)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		armor = math.Clamp(armor, 0, this:GetMaxArmor())
	end

	this:SetArmor(armor)
end

__e2setcost(100)

local function playerNoclip(e2, target, enable)
	if not e2.player:HasE2PLevel(E2P.ADVANCED) then
		if this ~= e2.player then return self:throw("You can only target yourself!") end

		if hook.Run("PlayerNoClip", target, enable) == false then
			return self:throw("You cannot noclip!")
		end
	end

	this:SetMoveType(enable and MOVETYPE_NOCLIP or MOVETYPE_WALK)
end

e2function void entity:playerNoclip(number enable)
	if not E2P.ProcessValidPlayer(self, this) then return end

	playerNoclip(self, this, enable ~= 0)
end

e2function void entity:playerNoclipToggle()
	if not E2P.ProcessValidPlayer(self, this) then return end

	local enable = this:GetMoveType() ~= MOVETYPE_NOCLIP

	playerNoclip(self, this, enable)
end

e2function void entity:playerModel(string model)
	if not E2P.ProcessValidPlayer(self, this) then return end

	if self.player:HasE2PLevel(E2P.ADVANCED) then
		if this ~= self.player then return self:throw("You can only target yourself!") end
	end

	model = player_manager.TranslatePlayerModel(model)

	this:SetModel(model)
end

__e2setcost(50)

e2function void entity:playerLock()
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:Lock()
end

e2function void entity:playerUnlock()
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:UnLock()
end

e2function void entity:playerFreeze()
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:Freeze(true)
end

e2function void entity:playerUnFreeze()
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:Freeze(false)
end

__e2setcost(500)

e2function void stripWeapons()
	self.player:StripWeapons()
end

e2function void entity:stripWeapons()
	if not E2P.ProcessValidPlayer(self, this) then return end

	if self.player:HasE2PLevel(E2P.ADVANCED) then
		if this ~= self.player then return self:throw("You can only target yourself!") end
	end

	this:StripWeapons()
end

e2function void entity:giveWeapon(string weapon)
	if not E2P.ProcessValidPlayer(self, this) then return end

	local weapon_info = weapons.GetStored(weapon)
	if not weapon_info then return self:throw("Invalid weapon!") end

	if not weapon_info.Spawnable then
		return self:throw("Weapon is not spawnable!")
	end

	if not self.player:HasE2PLevel(E2P.BASIC) then
		if this ~= self.player then return self:throw("You can only target yourself!") end
	end

	if not self.player:HasE2PLevel(E2P.ADVANCED) then
		if not self.player:IsAdmin() and weapon_info.AdminOnly then
			return self:throw("Weapon is admin only!")
		end
	end

	if hook.Run("PlayerGiveSWEP", self.player, weapon, weapon_info) == false then
		return self:throw("You cannot give that weapon!")
	end

	this:Give(weapon)
end

__e2setcost(10)

e2function array entity:weapons()
	if not E2P.ProcessValidPlayer(self, this) then return end

	return this:GetWeapons()
end

e2function string entity:getUserGroup()
	if not E2P.ProcessValidPlayer(self, this) then return end

	return this:GetUserGroup()
end

e2function number entity:isUserGroup(string group)
	if not E2P.ProcessValidPlayer(self, this) then return end

	return this:IsUserGroup(group) and 1 or 0
end

e2function void spawn()
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end

	self.player:Spawn()
end

e2function void entity:plyJumpPower(number power)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:SetJumpPower(power)
end

e2function void entity:plyRunSpeed(number speed)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:SetRunSpeed(speed)
end

e2function void entity:plyWalkSpeed(number speed)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:SetWalkSpeed(speed)
end

e2function void entity:plyCrouchWalkSpeed(number speed)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	this:SetCrouchedWalkSpeed(speed)
end

e2function number entity:plyGetRunSpeed()
	if not E2P.ProcessValidPlayer(self, this) then return -1 end

	return this:GetRunSpeed()
end

e2function number entity:plyGetWalkSpeed()
	if not E2P.ProcessValidPlayer(self, this) then return -1 end

	return this:GetWalkSpeed()
end

e2function number entity:plyGetMaxSpeed()
	if not E2P.ProcessValidPlayer(self, this) then return -1 end

	return this:GetMaxSpeed()
end

e2function number entity:plyGetJumpPower()
	if not E2P.ProcessValidPlayer(self, this) then return -1 end

	return this:GetJumpPower()
end

__e2setcost(10)

e2function number entity:lookUpBone(string boneName)
	if !IsValid(this) then return -1 end
	return this:LookupBone(boneName) or -1
end

__e2setcost(200)

e2function vector entity:playerBonePos(number index)
	if not E2P.ProcessValidPlayer(self, this) then return end

	local pos = this:GetBonePosition(this:TranslatePhysBoneToBone(index))

	if not pos then
		return self:throw("Invalid bone!")
	end

	return pos
end

e2function angle entity:playerBoneAng(number index)
	if not E2P.ProcessValidPlayer(self, this) then return end

	local _, ang = this:GetBonePosition(this:TranslatePhysBoneToBone(index))

	if not ang then
		return self:throw("Invalid bone!")
	end

	return ang
end

__e2setcost(300)

e2function vector entity:playerBonePos(string boneName)
	if not E2P.ProcessValidPlayer(self, this) then return end

	local pos = this:GetBonePosition(this:LookupBone(boneName))

	if not pos then
		return self:throw("Invalid bone!")
	end

	return pos
end

e2function angle entity:playerBoneAng(number index)
	if not E2P.ProcessValidPlayer(self, this) then return end

	local _, ang = this:GetBonePosition(this:LookupBone(boneName))

	if not ang then
		return self:throw("Invalid bone!")
	end

	return ang
end

__e2setcost(500)

e2function void playerSetBoneAng(number index, angle ang)
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end

	ang = Angle(ang[1], ang[2], ang[3])

	self.player:ManipulateBoneAngles(index, ang)
end

e2function void entity:playerSetBoneAng(number index, angle ang)
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	ang = Angle(ang[1], ang[2], ang[3])

	this:ManipulateBoneAngles(index, ang)
end

__e2setcost(600)

e2function void playerSetBoneAng(string boneName, angle ang)
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end

	ang = Angle(ang[1], ang[2], ang[3])

	self.player:ManipulateBoneAngles(self.player:LookupBone(boneName), ang)
end

e2function void entity:playerSetBoneAng(string boneName, angle ang)
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	ang = Angle(ang[1], ang[2], ang[3])

	this:ManipulateBoneAngles(this:LookupBone(boneName), ang)
end

__e2setcost(10)

e2function number entity:playerIsRagdoll()
	if not E2P.ProcessValidPlayer(self, this) then return 0 end

	return IsValid(this._e2p_ragdoll) and 1 or 0
end

registerCallback("construct", function(e2)
	e2.data.e2p_player_ragdolls = {}
end)

registerCallback("destruct", function(e2)
	for ply, _ in pairs(e2.data.e2p_player_ragdolls) do
		if IsValid(ply) then
			ply._e2p_ragdoll:Remove()
		end
	end
end)

__e2setcost(15000)

e2function entity entity:playerRagdoll()
	if not E2P.ProcessRestriction(self, E2P.ADVANCED) then return end
	if not E2P.ProcessValidPlayer(self, this) then return end

	if not this:Alive() then
		return self:throw("Player must be alive!")
	end

	if this:InVehicle() then
		this:ExitVehicle()
	end

	if not IsValid(this._e2p_ragdoll) then
		local ragdoll = ents.Create("prop_ragdoll")

		if not IsValid(ragdoll) then
			return self:throw("Cannot create ragdoll!")
		end

		this._e2p_ragdoll = ragdoll
		self.data.e2p_player_ragdolls[this] = true

		ragdoll:SetPos(this:GetPos())
		ragdoll:SetAngles(this:GetAngles())
		ragdoll:SetAngles(this:GetAngles())
		ragdoll:SetModel(this:GetModel())
		ragdoll:Spawn()
		ragdoll:Activate()

		local velocity = this:GetVelocity()

		for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			local phys = ragdoll:GetPhysicsObjectNum(i)

			if IsValid(phys) then
				phys:SetVelocity(velocity)
			end
		end

		ragdoll:CallOnRemove("restore player", function()
			if not IsValid(this) then return end

			this:SetParent(nil)
			this:UnSpectate()

			local ragdoll = this._e2p_ragdoll
			this._e2p_ragdoll = nil

			local yaw = ragdoll:GetAngles().yaw
			local pos = ragdoll:GetPos()
			pos.z = pos.z + 10

			this:Spawn()

			this:SetPos(pos)
			this:SetAngles(Angle(0, yaw, 0))

			self.data.e2p_player_ragdolls[this] = nil
		end)

		this:SetParent(ragdoll)
		this:Spectate(OBS_MODE_CHASE)
		this:SpectateEntity(ragdoll)
		this:StripWeapons()

		return ragdoll
	else
		this._e2p_ragdoll:Remove()

		return nil
	end
end

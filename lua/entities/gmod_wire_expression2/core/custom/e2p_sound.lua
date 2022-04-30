local sound_play_cooldown = CreateConVar("wire_expression2_e2p_sound_play_cooldown", "0.5", FCVAR_ARCHIVE)

__e2setcost(200)

local function normalizePath(path)
	return path:Trim():lower()
end

local function normalizeVolume(volume)
	return math.Clamp(volume, 0, 100) / 100
end

local function normalizePitch(pitch)
	return math.Clamp(pitch, 0, 255)
end

local function cooldownPlaySound(e2)
	if not e2.player:TimeoutAction("sound play cooldown", sound_play_cooldown:GetFloat()) then
		e2:throw("Sound play cooldown!")

		return false
	end

	return true
end

local function restrictLoopingSound(e2, path)
	-- TODO: find a better way to detect looping sound?
	if path:find("loop") then
		e2:throw("Looping sound is not allowed!")

		return false
	end

	return true
end

e2function void soundPlayAll(string path, number volume, number pitch)
	if E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not cooldownPlaySound(self) then return end

	path = normalizePath(path)

	if not restrictLoopingSound(self, path) then return end

	volume = normalizeVolume(volume)
	pitch = normalizePitch(pitch)

	for _, ply in ipairs(player.GetAll()) do
		ply:EmitSound(path, 75, pitch, volume, CHAN_AUTO)
	end
end

e2function void soundPlayWorld(string path, vector pos, number distance, number pitch, number volume)
	if E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not cooldownPlaySound(self) then return end

	path = normalizePath(path)

	if not restrictLoopingSound(self, path) then return end

	pos = Vector(pos[1], pos[2], pos[3])
	distance = math.Clamp(distance, 20, 140)
	pitch = normalizePitch(pitch)
	volume = normalizeVolume(volume)

	sound.Play(path, pos, distance, pitch, volume)
end

e2function void entity:soundPlaySingle(string path, number volume, number pitch)
	if E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if E2P.ProcessValidEntity(self, this) then return end
	if not cooldownPlaySound(self) then return end

	path = normalizePath(path)

	if not restrictLoopingSound(self, path) then return end

	volume = normalizeVolume(volume)
	pitch = normalizePitch(pitch)

	this:EmitSound(path, 75, pitch, volume, CHAN_AUTO)
end

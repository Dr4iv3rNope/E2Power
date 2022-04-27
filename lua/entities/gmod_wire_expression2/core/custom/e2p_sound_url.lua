local load_cooldown = CreateConVar("wire_expression2_e2p_sound_url_load_cooldown", "1", FCVAR_ARCHIVE)
local max_fft_count = CreateConVar("wire_expression2_e2p_sound_url_max_fft_per_sec", "5", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local fft_response_timeout = CreateConVar("wire_expression2_e2p_sound_url_fft_response_timeout", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local id_length_limit = CreateConVar("wire_expression2_e2p_sound_url_id_length_limit", "16", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

local streams = {}

util.AddNetworkString("e2p_sound_url_play")
util.AddNetworkString("e2p_sound_url_stop")
util.AddNetworkString("e2p_sound_url_volume")
util.AddNetworkString("e2p_sound_url_playback_state") -- pause/resume
util.AddNetworkString("e2p_sound_url_parent")
util.AddNetworkString("e2p_sound_url_fft")

local tick_interval = engine.TickInterval()

local function plyTimeoutFFT(ply)
	return ply:TimeoutAction("e2p send fft", max_fft_count:GetFloat() * tick_interval)
end

local function normalizeID(id)
	return id:sub(1, id_length_limit:GetInt())
end

local function requestFFT(e2, id)
	local e2_streams = streams[e2]
	if not e2_streams then return end

	id = normalizeID(id)

	local info = e2_streams[id]
	if not info then return end

	if plyTimeoutFFT(e2.player) then
		if not IsValid(info._pending_fft_player) or CurTime() > info._pending_fft_timeout then
			net.Start("e2p_sound_url_fft")
			net.WriteEntity(e2.entity)
			net.WriteString(id)
			net.Send(e2.player)

			info._pending_fft_player = e2.player
			info._pending_fft_timeout = CurTime() + fft_response_timeout:GetFloat()
		end
	end

	return info.fft
end

local function stop(e2, id)
	id = normalizeID(id)

	local e2_streams = streams[e2]
	if not e2_streams or not e2_streams[id] then return end

	net.Start("e2p_sound_url_stop")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.Broadcast()

	e2_streams[id] = nil
end

local function play(e2, id, url, sync)
	id = normalizeID(id)

	local e2_streams = streams[e2]

	if not e2_streams then
		e2_streams = {}

		streams[e2] = e2_streams
	end

	local info = {
		url = url,
		start_time = CurTime(),
		fft = {}
	}

	e2_streams[id] = info

	net.Start("e2p_sound_url_play")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.WriteString(url)
	net.WriteFloat(info.start_time)
	net.WriteBool(sync == true)
	net.Broadcast()
end

local function setPlaybackState(e2, id, pause)
	id = normalizeID(id)

	local e2_streams = streams[e2]
	if not e2_streams or not e2_streams[id] then return end

	net.Start("e2p_sound_url_playback_state")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.WriteBool(pause)
	net.Broadcast()
end

local function setVolume(e2, id, volume)
	id = normalizeID(id)

	local e2_streams = streams[e2]
	if not e2_streams or not e2_streams[id] then return end

	net.Start("e2p_sound_url_playback_state")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.WriteFloat(volume)
	net.Broadcast()
end

local function setParent(e2, id, parent)
	local is_entity = isentity(parent)

	auroralib.Assert(type(parent) == "Vector" or is_entity)

	id = normalizeID(id)

	local e2_streams = streams[e2]
	if not e2_streams or not e2_streams[id] then return end

	net.Start("e2p_sound_url_parent")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.WriteBool(is_entity)

	if is_entity then
		net.WriteEntity(parent)
	else
		net.WriteVector(parent)
	end

	net.Broadcast()
end

net.Receive("e2p_sound_url_fft", function(_, ply)
	local e2 = net.ReadEntity()

	local e2_streams = streams[e2.context]
	if not e2_streams then return end

	local id = normalizeID(net.ReadString())
	local info = e2_streams[id]
	if not info then return end

	if info._pending_fft_player ~= ply then return end

	local fft = {}
	local count = net.ReadUInt(8)

	for i = 1, count do
		fft[i] = net.ReadFloat()
	end

	info.fft = fft
	info._pending_fft_player = nil
end)

registerCallback("destruct", function(e2)
	streams[e2] = nil
end)

local function inCooldown(e2)
	return not e2.player:TimeoutAction("e2p sound url load cooldown", load_cooldown:GetFloat())
end

__e2setcost(500)

e2function void soundURLload(string id, string url, number volume, number noplay, vector pos)
	if inCooldown(self) then return end

	play(self, id, url, false)
	setPlaybackState(self, id, noplay == 0)
	setVolume(self, id, volume)
	setParent(self, id, pos)
end

e2function void soundURLload(string id, string url, number volume, number noplay, entity parent)
	if inCooldown(self) then return end

	play(self, id, url, false)
	setPlaybackState(self, id, noplay == 0)
	setVolume(self, id, volume)
	setParent(self, id, parent)
end

e2function void entity:soundURLload(string id, string url, number volume, number noplay)
	if not IsValid(this) then return end
	if inCooldown(self) then return end

	play(self, id, url, false)
	setPlaybackState(self, id, noplay == 0)
	setVolume(self, id, volume)
	setParent(self, id, this)
end

e2function void soundURLplay(string id)
	setPlaybackState(self, id, false)
end

e2function void soundURLpause(string id)
	setPlaybackState(self, id, true)
end

e2function void soundURLvolume(string id, number volume)
	setVolume(self, id, volume)
end

e2function void soundURLpos(string id, vector pos)
	setParent(self, id, pos)
end

e2function void soundURLparent(string id, entity parent)
	setParent(self, id, parent)
end

e2function void soundURLdelete(string id)
	stop(self, id)
end

e2function void soundURLPurge()
	if inCooldown(self) then return end

	local e2_streams = streams[self]
	if not e2_streams then return end

	for id, _ in pairs(e2_streams) do
		stop(self, id)
	end

	streams[self] = nil
end

e2function array entity:soundFFT(string id)
	if not IsValid(this) then return end

	return requestFFT(this.context, id)
end

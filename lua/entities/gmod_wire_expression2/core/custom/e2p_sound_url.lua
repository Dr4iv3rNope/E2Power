local loadCooldown			= CreateConVar("wire_expression2_e2p_sound_url_load_cooldown", "1", FCVAR_ARCHIVE)
local maxFFTCount			= CreateConVar("wire_expression2_e2p_sound_url_max_fft_per_sec", "5", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local fftResponseTimeout	= CreateConVar("wire_expression2_e2p_sound_url_fft_response_timeout", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local idLengthLimit			= CreateConVar("wire_expression2_e2p_sound_url_id_length_limit", "16", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

local streams = {}

util.AddNetworkString("e2p_sound_url_play")
util.AddNetworkString("e2p_sound_url_stop")
util.AddNetworkString("e2p_sound_url_volume")
util.AddNetworkString("e2p_sound_url_playback_state") -- pause/resume
util.AddNetworkString("e2p_sound_url_parent")
util.AddNetworkString("e2p_sound_url_fft")

local tickInterval = engine.TickInterval()

local function plyTimeoutFFT(ply)
	return ply:TimeoutAction("e2p send fft", maxFFTCount:GetFloat() * tickInterval)
end

local function normalizeID(id)
	return id:sub(1, idLengthLimit:GetInt())
end

local function requestFFT(e2, id)
	local e2Streams = streams[e2]
	if not e2Streams then return end

	id = normalizeID(id)

	local info = e2Streams[id]
	if not info then return end

	if plyTimeoutFFT(e2.player) then
		if not IsValid(info._pendingFFTPlayer) or CurTime() > info._pendingFFTtimeout then
			net.Start("e2p_sound_url_fft")
			net.WriteEntity(e2.entity)
			net.WriteString(id)
			net.Send(e2.player)

			info._pendingFFTPlayer = e2.player
			info._pendingFFTtimeout = CurTime() + fftResponseTimeout:GetFloat()
		end
	end

	return info.fft
end

local function stop(e2, id)
	id = normalizeID(id)

	local e2Streams = streams[e2]
	if not e2Streams or not e2Streams[id] then return end

	net.Start("e2p_sound_url_stop")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.Broadcast()

	e2Streams[id] = nil
end

local function play(e2, id, url, sync)
	id = normalizeID(id)

	local e2Streams = streams[e2]

	if not e2Streams then
		e2Streams = {}

		streams[e2] = e2Streams
	end

	local info = {
		url = url,
		start_time = CurTime(),
		fft = {}
	}

	e2Streams[id] = info

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

	local e2Streams = streams[e2]
	if not e2Streams or not e2Streams[id] then return end

	net.Start("e2p_sound_url_playback_state")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.WriteBool(pause)
	net.Broadcast()
end

local function setVolume(e2, id, volume)
	id = normalizeID(id)

	local e2Streams = streams[e2]
	if not e2Streams or not e2Streams[id] then return end

	net.Start("e2p_sound_url_playback_state")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.WriteFloat(volume)
	net.Broadcast()
end

local function setParent(e2, id, parent)
	local isEntity = isentity(parent)

	x.Assert(type(parent) == "Vector" or isEntity)

	id = normalizeID(id)

	local e2Streams = streams[e2]
	if not e2Streams or not e2Streams[id] then return end

	net.Start("e2p_sound_url_parent")
	net.WriteEntity(e2.entity)
	net.WriteString(id)
	net.WriteBool(isEntity)

	if isEntity then
		net.WriteEntity(parent)
	else
		net.WriteVector(parent)
	end

	net.Broadcast()
end

net.Receive("e2p_sound_url_fft", function(_, ply)
	local e2 = net.ReadEntity()

	local e2Streams = streams[e2.context]
	if not e2Streams then return end

	local id = normalizeID(net.ReadString())
	local info = e2Streams[id]
	if not info then return end

	if info._pendingFFTPlayer ~= ply then return end

	local fft = {}
	local count = net.ReadUInt(8)

	for i = 1, count do
		fft[i] = net.ReadFloat()
	end

	info.fft = fft
	info._pendingFFTPlayer = nil
end)

registerCallback("destruct", function(e2)
	streams[e2] = nil
end)

local function inCooldown(e2)
	if not e2.player:TimeoutAction("e2p sound url load cooldown", loadCooldown:GetFloat()) then
		e2:throw("Sound URL cooldown")

		return false
	end

	return true
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
	if not E2P.ProcessValidEntity(self, parent) then return end
	if inCooldown(self) then return end

	play(self, id, url, false)
	setPlaybackState(self, id, noplay == 0)
	setVolume(self, id, volume)
	setParent(self, id, parent)
end

e2function void entity:soundURLload(string id, string url, number volume, number noplay)
	if not E2P.ProcessValidEntity(self, this) then return end
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
	if not E2P.ProcessValidEntity(self, parent) then return end

	setParent(self, id, parent)
end

e2function void soundURLdelete(string id)
	stop(self, id)
end

e2function void soundURLPurge()
	if inCooldown(self) then return end

	local e2Streams = streams[self]
	if not e2Streams then return end

	for id, _ in pairs(e2Streams) do
		stop(self, id)
	end

	streams[self] = nil
end

e2function array entity:soundFFT(string id)
	if not E2P.ProcessValidEntity(self, this) then return end

	return requestFFT(this.context, id)
end

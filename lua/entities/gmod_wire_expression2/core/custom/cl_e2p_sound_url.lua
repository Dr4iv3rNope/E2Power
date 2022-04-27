local max_fft_count = CreateConVar("wire_expression2_e2p_sound_url_max_fft_per_sec", "0")

local streams = {}

net.Receive("e2p_sound_url_play", function()
	local e2 = net.ReadEntity()
	local id = net.ReadString()
	local url = net.ReadString()
	local start_time = net.ReadFloat()
	local sync = net.ReadBool()

	if not IsValid(e2) then return end

	local e2_streams = streams[e2]

	if not e2_streams then
		e2_streams = {}

		streams[e2] = e2_streams
	end

	local prev_info = e2_streams[id]

	if prev_info then
		prev_info.remove = true
	end

	local info = {
		url = url,
		start_time = start_time,
		station = nil,
		pause = false,
		parent = Vector(),
		volume = 1,
		remove = false
	}

	e2_streams[id] = info

	sound.PlayURL(url, "noplay noblock 3d", function(station, _, err)
		if not IsValid(station) then
			e2_streams[id] = nil

			return auroralib.ErrorNoHalt("[E2P Sound] Failed to play %s: %s", url, err)
		end

		info.station = station

		station:Set3DFadeDistance(200, 500)

		hook.Add("Tick", station, function()
			if info.remove then
				station:Stop()
				info.station = nil

				hook.Remove("Tick", station)

				e2_streams[id] = nil

				if next(e2_streams) == nil then
					streams[e2] = nil
				end

				return
			end

			local state = station:GetState()

			if info.pause == true then
				if state ~= GMOD_CHANNEL_PAUSED then
					station:Pause()
				end
			elseif info.pause == false then
				if state ~= GMOD_CHANNEL_PLAYING then
					station:Play()
				end
			end

			info.pause = nil

			if sync then
				station:SetTime(CurTime() - start_time)

				sync = nil
			end

			if station:GetState() == GMOD_CHANNEL_PAUSED then return end

			station:SetVolume(info.volume)

			if isentity(info.parent) then
				if IsValid(info.parent) then
					station:SetPos(info.parent:GetPos())
				end
			else
				station:SetPos(info.parent)
			end
		end)
	end)
end)

net.Receive("e2p_sound_url_fft", function()
	local e2 = net.ReadEntity()
	local id = net.ReadString()

	if not IsValid(e2) then return end

	local e2_streams = streams[e2]
	if not e2_streams then return end

	local info = e2_streams[id]
	if not info then return end
	if not IsValid(info.station) then return end

	local fft = {}
	info.station:FFT(fft, FFT_256)

	net.Start("e2p_sound_url_fft")
	net.WriteEntity(e2)
	net.WriteString(id)
	net.WriteUInt(#fft, 8)

	for i = 1, #fft do
		net.WriteFloat(fft[i])
	end

	net.SendToServer()
end)

net.Receive("e2p_sound_url_volume", function()
	local e2 = net.ReadEntity()
	local id = net.ReadString()
	local volume = net.ReadFloat()

	if not IsValid(e2) then return end

	local e2_streams = streams[e2]
	if not e2_streams then return end

	local info = e2_streams[id]
	if not info then return end

	info.volume = volume
end)

net.Receive("e2p_sound_url_playback_state", function()
	local e2 = net.ReadEntity()
	local id = net.ReadString()
	local pause = net.ReadBool()

	if not IsValid(e2) then return end

	local e2_streams = streams[e2]
	if not e2_streams then return end

	local info = e2_streams[id]
	if not info then return end

	info.pause = pause
end)

net.Receive("e2p_sound_url_parent", function()
	local e2 = net.ReadEntity()
	if not IsValid(e2) then return end

	local id = net.ReadString()
	local is_parent_entity = net.ReadBool()
	local parent = is_parent_entity and net.ReadEntity() or net.ReadVector()

	local e2_streams = streams[e2]
	if not e2_streams then return end

	local info = e2_streams[id]
	if not info then return end

	info.parent = parent
end)

net.Receive("e2p_sound_url_stop", function()
	local e2 = net.ReadEntity()
	local id = net.ReadString()

	if not IsValid(e2) then return end

	local e2_streams = streams[e2]
	if not e2_streams then return end

	local info = e2_streams[id]
	if not info then return end

	info.remove = true
end)

hook.Add("EntityRemoved", "e2p sound url", function(e2)
	local e2_streams = streams[e2]
	if not e2_streams then return end

	for id, info in pairs(e2_streams) do
		info.remove = true
	end
end)

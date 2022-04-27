auroralib.sql.Query(
	"CREATE TABLE IF NOT EXISTS e2p_data(" ..
		"steamid TEXT UNIQUE NOT NULL," ..
		"level INTEGER NOT NULL" ..
	")"
)

local PLAYER = FindMetaTable("Player")

function PLAYER:E2PQueryData()
	local data = auroralib.sql.First(
		"SELECT level FROM e2p_data WHERE steamid = ?",
		self:SteamID()
	)

	if not data then
		data = {
			level = E2P.NONE
		}

		auroralib.sql.Query(
			"INSERT INTO e2p_data VALUES(?, ?)",
			self:SteamID(),
			data.level
		)
	end

	return data
end

function PLAYER:E2PFetchFromDB(force)
	if not force and self._e2p_data then return end

	local data = self:E2PQueryData()
	self._e2p_data = data

	self:SetNWInt("e2p_level", data.level)
end

function PLAYER:SetE2PLevel(level)
	level = math.Clamp(level, E2P.FULL, E2P.ADVANCED)

	self:SetNWInt("e2p_level", level)
	self._e2p_data.level = level

	auroralib.sql.Query(
		"INSERT INTO e2p_data VALUES(?, ?)",
		self:SteamID(),
		level
	)
end

function PLAYER:HasE2PLevel(level)
	return self:GetE2PLevel() >= level
end

local error_message = "У вас не хватает прав на выполнение этой функции"

function E2P.ProcessRestriction(e2, min_level)
	local owner = e2.player

	if not IsValid(owner) then return false end
	if owner:IsSuperAdmin() then return true end
	if owner:HasE2PLevel(min_level) then return true end

	if e2:throw(error_message, false) == false then
		-- no strict mode is active

		error(error_message)
	end

	return false
end

hook.Add("PlayerInitialSpawn", "e2p fetch from db", function(ply)
	ply:E2PFetchFromDB(true)
end)
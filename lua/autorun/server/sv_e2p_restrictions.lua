x.QuerySQL(
	"CREATE TABLE IF NOT EXISTS e2p_data(" ..
		"steamid TEXT UNIQUE NOT NULL," ..
		"level INTEGER NOT NULL" ..
	")"
)

local PLAYER = FindMetaTable("Player")

function PLAYER:E2PQueryData()
	local data = x.QuerySQLFirst(
		"SELECT level FROM e2p_data WHERE steamid = ?",
		self:SteamID()
	)

	if not data then
		data = {
			Level = E2P.NONE
		}

		x.QuerySQL(
			"INSERT INTO e2p_data VALUES(?, ?)",
			self:SteamID(),
			data.Level
		)
	end

	data.Level = tonumber(data.level)

	return data
end

function PLAYER:E2PFetchFromDB(force)
	if not force and self._e2pData then return end

	local data = self:E2PQueryData()
	self._e2pData = data

	self:SetNWInt("e2p_level", data.Level)
end

function PLAYER:SetE2PLevel(level)
	level = math.Clamp(level, E2P.FULL, E2P.ADVANCED)

	self:SetNWInt("e2p_level", level)
	self._e2pData.Level = level

	x.QuerySQL(
		"REPLACE INTO e2p_data VALUES(?, ?)",
		self:SteamID(),
		level
	)
end

function PLAYER:HasE2PLevel(level)
	return self:IsSuperAdmin() or self:GetE2PLevel() >= level
end

local errorMessage = "У вас не хватает прав на выполнение этой функции"

function E2P.ProcessRestriction(e2, minLevel)
	local owner = e2.player

	if not IsValid(owner) then return false end
	if owner:IsSuperAdmin() then return true end
	if owner:HasE2PLevel(minLevel) then return true end

	if e2:throw(errorMessage, false) == false then
		-- no strict mode is active

		error(errorMessage)
	end

	return false
end

function E2P.ProcessValidEntity(e2, ent)
	if not IsValid(ent) then e2:throw("Invalid entity!") return false end

	return true
end

function E2P.ProcessValidPlayer(e2, ent)
	if not E2P.ProcessValidEntity(e2, ent) then return false end
	if not ent:IsPlayer() then e2:throw("Entity must be a valid player!") return false end

	return true
end

function E2P.ProcessValidWeapon(e2, ent)
	if not E2P.ProcessValidEntity(e2, ent) then return false end
	if not ent:IsWeapon() then e2:throw("Entity must be a valid weapon!") return false end

	return true
end

function E2P.ProcessIsOwner(e2, ent)
	if not E2P.ProcessValidEntity(e2, ent) then return false end

	if e2.player:HasE2PLevel(E2P.ADVANCED) then return true end
	if E2Lib.isOwner(e2, ent) then return true end

	e2:throw("You do not own this prop!")

	return false
end

hook.Add("PlayerInitialSpawn", "e2p fetch from db", function(ply)
	ply:E2PFetchFromDB(true)
end)

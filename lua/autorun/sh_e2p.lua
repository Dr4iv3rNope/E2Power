E2P = E2P or {}

E2P.FULL = -1
E2P.NONE = 0
E2P.BASIC = 1
E2P.ADVANCED = 2

E2P.PrettyLevels = {
	[E2P.FULL] =		"Полный",
	[E2P.NONE] =		"Нету",
	[E2P.BASIC] =		"Ограниченый",
	[E2P.ADVANCED] =	"Продвинутый"
}

E2P.INT_MAX = 2147483647

local PLAYER = FindMetaTable("Player")

if SERVER then
	function PLAYER:GetE2PLevel()
		return self._e2p_data.level
	end
else
	function PLAYER:GetE2PLevel()
		return self:GetNWInt("e2p_level", E2P.NONE)
	end
end

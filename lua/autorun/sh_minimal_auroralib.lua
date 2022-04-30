if auroralib and not auroralib._MINIMAL then return end

auroralib = auroralib or {}
auroralib._MINIMAL = true

auroralib.Assert = assert
auroralib.ErrorNoHalt = ErrorNoHalt

auroralib.sql = auroralib.sql or {}

function auroralib.sql.QueryString(query, ...)
	local args = { ... }
	local argc = #args
	local argi = 1

	query = query:gsub("%?", function()
		auroralib.Assert(argi <= argc, "not enough arguments")
		local safe_str = SQLStr(args[argi])

		argi = argi + 1
		return safe_str
	end)

	return query
end

function auroralib.sql.Query(query, ...)
	local parsed_query = auroralib.sql.QueryString(query, ...)
	local output = sql_Query(parsed_query)

	if output == false then
		error(sql.LastError())
	end

	return output
end

function auroralib.sql.First(query, ...)
	local output = auroralib.sql.Query(query .. " LIMIT 1", ...)

	return output and output[1] or nil
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:TimeoutAction(id, timeout)
	local timeout_table = self._aurora_timeout_table
	local t = CurTime()

	if not timeout_table then
		timeout_table = {}

		self._aurora_timeout_table = timeout_table
	end

	local next_action = timeout_table[id] or 0

	if next_action > t then
		return false
	end

	timeout_table[id] = t + timeout
	return true
end

function ENTITY:TimeoutGetUntil(id)
	local timeout_table = self._aurora_timeout_table
	if not timeout_table then return 0 end

	return timeout_table[id] or 0
end

function ENTITY:TimeoutIsExpired(id)
	return CurTime() > self:TimeoutGetUntil(id)
end

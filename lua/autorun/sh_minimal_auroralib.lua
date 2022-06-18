if auroralib and not auroralib._MINIMAL then return end

local rawget = rawget
local rawset = rawset
local select = select
local table_insert = table.insert
local table_remove = table.remove
local auroralib_Assert = auroralib.Assert

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

local SET = {}

function SET.__index(tbl, k)
	return rawget(SET, k) or rawget(tbl, "values")[k]
end

function SET.__newindex(tbl, index, value)
	local values = rawget(tbl, "values")

	if values[index] == nil then
		SET.insert(tbl, value)

		return
	end

	rawset(values, index, value)
end

function SET:length()
	return #rawget(self, "values")
end

function SET:has(key)
	return rawget(self, "keys")[key] ~= nil
end

function SET:insert(...)
	local keys, values = rawget(self, "keys"), rawget(self, "values")
	local length = #values
	local pos, value

	if select("#", ...) == 1 then
		pos = length + 1
		value = select(1, ...)
	else
		pos = select(1, ...)
		value = select(2, ...)
	end

	auroralib_Assert(value ~= nil, "value cannot be nil")

	local index = keys[value]

	if index ~= nil then
		if index ~= pos then
			-- if index is different, move value

			self:remove(index)
		else
			-- if insert index is same, override value
			values[index] = value

			return pos
		end
	end

	keys[value] = table_insert(values, pos, value)

	self:reconstruct(pos + 1)

	return pos
end

function SET:remove(pos)
	local keys, values = rawget(self, "keys"), rawget(self, "values")

	local value = values[pos]
	if value == nil then return end

	table_remove(values, pos)
	keys[value] = nil

	self:reconstruct(pos)

	return value
end

function SET:delete(key)
	local keys, values = rawget(self, "keys"), rawget(self, "values")

	local index = keys[key]
	if index == nil then return end

	table_remove(values, index)
	keys[key] = nil

	self:reconstruct(index)
end

function SET:reconstruct(from)
	local keys, values = rawget(self, "keys"), rawget(self, "values")

	for i = from, #values do
		local v = values[i]

		keys[v] = i
	end
end

function auroralib.Set()
	return setmetatable({
		keys = {},
		values = {}
	}, SET)
end

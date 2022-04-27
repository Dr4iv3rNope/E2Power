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

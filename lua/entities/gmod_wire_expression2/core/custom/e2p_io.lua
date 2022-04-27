__e2setcost(10)

e2function void entity:setInput(string input, value)
	if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end

	this:TriggerInput(input , value)
end

e2function array entity:getOutput(string output)
	if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end

	return { this.Outputs[output].Value }
end

e2function angle entity:getOutputAngle(string output)
	if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end

	return this.Outputs[output].Value
end

e2function string entity:getOutputType(string output)
	if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end

	return type(this.Outputs[output].Value)
end

e2function string entity:getInputType(string input)
	if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end

	return type(this.Inputs[input].Value)
end

e2function array entity:getInputsList()
	if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end

	local result = {}
	local i = 1

	for k, v in pairs(this.Inputs) do
		result[i] = k

		i = i + 1
	end

	return result
end

e2function array entity:getOutputsList()
	if not IsValid(this) then return end
	if not E2Lib.isOwner(self, this) then return end

	local result = {}
	local i = 1

	for k, v in pairs(this.Outputs) do
		result[i] = k

		i = i + 1
	end

	return ret
end

__e2setcost(1)

e2function number entity:isPhysics()
	local isValid = IsValid(this) and IsValid(this:GetPhysicsObject())

	return isValid and 1 or 0
end

e2function number entity:isExist()
	return IsValid(this) and 1 or 0
end

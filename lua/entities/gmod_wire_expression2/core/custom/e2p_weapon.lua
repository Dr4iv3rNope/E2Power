__e2setcost(10)

e2function void entity:setClip1(number amount)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessValidWeapon(self, this) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	this:SetClip1(amount)
end

e2function void entity:setClip2(number amount)
	if not E2P.ProcessRestriction(self, E2P.BASIC) then return end
	if not E2P.ProcessValidWeapon(self, this) then return end
	if not E2P.ProcessIsOwner(self, this) then return end

	this:SetClip2(amount)
end

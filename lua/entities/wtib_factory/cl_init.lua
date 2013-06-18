include('shared.lua')
include('menu.lua')

local EffectDelay = 0.08

ENT.NextEffect = 0

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()

	local B = self:GetIsBuilding() and "Yes" or "No"
	return self.PrintName.."\nBuilding : "..B.."\nPercentage Complete : "..self:GetPercentageComplete().."%"
	
end

function ENT:Think()
	if self.NextEffect <= CurTime() and WTib.IsValid(self:GetCurObject()) then
		local Mins = self:GetCurObject():OBBMins()
		local Maxs = self:GetCurObject():OBBMaxs()
		local z = Mins.z+(((Maxs.z-Mins.z)/100)*self:GetPercentageComplete())

		for i=1,4 do
			local Attach = self:GetAttachment(self:LookupAttachment("las"..tostring(i)))
			local ed = EffectData()
				ed:SetStart(self:WorldToLocal(Attach.Pos))
				ed:SetOrigin(Vector(math.random(Mins.z,Maxs.x),math.random(Mins.y,Maxs.y),z))
				ed:SetEntity(self)
				ed:SetMagnitude(EffectDelay)
			util.Effect("wtib_factorylaser",ed)
		end
		
		self.NextEffect = CurTime() + EffectDelay
	end
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

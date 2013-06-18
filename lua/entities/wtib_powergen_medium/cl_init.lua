include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.." ("..tostring(self:GetIsOnline())..")\nBoosting : "..tostring(self:GetIsBoosting()).."\nTiberium Chemicals : "..self:GetChemicalsAmount()
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

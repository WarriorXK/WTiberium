include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.."\nTiberium Chemicals : "..math.Round(tostring(self:GetChemicalTiberiumAmount()))
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

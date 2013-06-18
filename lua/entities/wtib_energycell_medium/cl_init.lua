include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.."\nEnergy : "..math.Round(tostring(self:GetEnergyAmount()))
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

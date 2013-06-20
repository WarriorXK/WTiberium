include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	local on = "Off"
	if self.dt.Online then
		on = "On"
	end
	return self.PrintName.." ("..on..")\nEnergy : "..math.Round(tostring(self:GetEnergyAmount())).."\nRaw Tiberium : "..math.Round(tostring(self:GetRawTiberiumAmount()))
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

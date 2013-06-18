include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	local On = "Off"
	if self:GetIsOnline() then
		On = "On"
	end
	return self.PrintName.." ("..On..")\nHas Target : "..tostring(self:GetHasTarget()).."\nEnergy : "..math.Round(tostring(self:GetEnergyAmount()))
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

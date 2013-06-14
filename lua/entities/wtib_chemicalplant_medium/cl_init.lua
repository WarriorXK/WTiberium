include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	local on = "Off"
	if self:GetIsOnline() then
		on = "On"
	end
	return self.PrintName.." ("..on..")\nEnergy : "..math.Round(tostring(self:GetEnergyAmount())).."\nRefined Tiberium : "..math.Round(tostring(self:GetRefinedTiberiumAmount()))
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.." ("..tostring(self:GetIsOnline())..")\nBoosting : "..tostring(self:GetIsBoosting()).."\nRaw Tiberium :" .. self:GetRawTiberiumAmount() .. "\nLiquid Tiberium : "..self:GetLiquidsAmount()
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

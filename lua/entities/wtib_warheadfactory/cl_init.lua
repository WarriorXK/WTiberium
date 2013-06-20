include('shared.lua')
include('menu.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.."\nEnergy : "..self:GetEnergyAmount().."\nRaw : "..self:GetRawTiberiumAmount().."\nRefined : "..self:GetRefinedTiberiumAmount().."\nChemicals : "..self:GetChemicalsAmount().."\nLiquid : "..self:GetLiquidAmount()
end

language.Add(WTib.GetClass(ENT), ENT.PrintName)

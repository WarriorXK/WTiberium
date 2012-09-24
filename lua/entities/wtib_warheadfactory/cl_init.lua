include('shared.lua')
include('menu.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.."\nEnergy : "..self.dt.Energy.."\nRaw : "..self.dt.Raw.."\nRefined : "..self.dt.Refined.."\nChemicals : "..self.dt.Chemicals.."\nLiquid : "..self.dt.Liquid
end

language.Add(WTib.GetClass(ENT),ENT.PrintName)

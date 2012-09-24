include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.."\nRaw : "..self.dt.RawTiberium.."\nRefined : "..self.dt.RefTiberium.."\nChemicals : "..self.dt.Chemicals.."\nLiquid : "..self.dt.Liquids
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

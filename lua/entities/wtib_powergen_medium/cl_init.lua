include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	return self.PrintName.." ("..tostring(self.dt.Online)..")\nBoosting : "..tostring(self.dt.Boosting).."\nTiberium Chemicals : "..self.dt.Chemicals
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

include('shared.lua')

function ENT:Draw()
	local Size = 0.01*self.dt.Dispenser.dt.PercentageComplete
	self:SetModelScale(Vector(Size,Size,Size))
	self:DrawModel()
end

language.Add(WTib.GetClass(ENT),ENT.PrintName)

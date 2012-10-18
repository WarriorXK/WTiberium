include('shared.lua')

function ENT:Draw()

	self:SetModelScale( 0.01 * self.dt.Dispenser.dt.PercentageComplete, 0 )
	self:DrawModel()
	
end

language.Add(WTib.GetClass(ENT),ENT.PrintName)

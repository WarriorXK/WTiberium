AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/small_energy_cell.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"Energy","MaxEnergy"})
	WTib.AddResource(self,"energy",1000)
	WTib.RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,30,self)
end

function ENT:Think()
	self.dt.Energy = WTib.GetResourceAmount(self,"energy")
	WTib.TriggerOutput(self,"Energy",self.dt.Energy)
	WTib.TriggerOutput(self,"MaxEnergy",WTib.GetNetworkCapacity(self,"Energy"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end

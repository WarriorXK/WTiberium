AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/tiberium/medium_energy_cell.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"Energy","MaxEnergy"})
	WTib.RegisterEnt(self,"Storage")
	WTib.AddResource(self,"energy",3000)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	self:SetEnergyAmount(WTib.GetResourceAmount(self,"energy"))
	WTib.TriggerOutput(self,"Energy",self:GetEnergyAmount())
	WTib.TriggerOutput(self,"MaxEnergy",WTib.GetNetworkCapacity(self,"Energy"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/tiberium/medium_tiberium_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"RefinedTiberium","MaxRefinedTiberium"})
	WTib.RegisterEnt(self,"Storage")
	WTib.AddResource(self,"RefinedTiberium",3000)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	self:SetRefinedTiberiumAmount(WTib.GetResourceAmount(self,"RefinedTiberium"))
	WTib.TriggerOutput(self,"RefinedTiberium",self:GetRefinedTiberiumAmount())
	WTib.TriggerOutput(self,"MaxRawTiberium",WTib.GetNetworkCapacity(self,"RefinedTiberium"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end

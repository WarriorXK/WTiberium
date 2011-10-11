AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_tiberium_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"RefinedTiberium","MaxRefinedTiberium"})
	WTib.AddResource(self,"RefinedTiberium",3000)
	WTib.RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	self.dt.RefinedTiberium = WTib.GetResourceAmount(self,"RefinedTiberium")
	WTib.TriggerOutput(self,"RefinedTiberium",self.dt.RefinedTiberium)
	WTib.TriggerOutput(self,"MaxRawTiberium",WTib.GetNetworkCapacity(self,"RefinedTiberium"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end

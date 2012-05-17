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
	self.Outputs = WTib.CreateOutputs(self,{"RawTiberium","MaxRawTiberium"})
	WTib.RegisterEnt(self,"Storage")
	WTib.AddResource(self,"RawTiberium",3000)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	self.dt.RawTiberium = WTib.GetResourceAmount(self,"RawTiberium")
	WTib.TriggerOutput(self,"RawTiberium",self.dt.RawTiberium)
	WTib.TriggerOutput(self,"MaxRawTiberium",WTib.GetNetworkCapacity(self,"RawTiberium"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end

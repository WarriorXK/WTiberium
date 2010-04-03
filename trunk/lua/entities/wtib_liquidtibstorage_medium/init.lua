AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_chemical_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"LiquidTiberium","MaxChemicalTiberium"})
	WTib.AddResource(self,"LiquidTiberium",3000)
	WTib.RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,30,self)
end

function ENT:Think()
	local RefTib = WTib.GetResourceAmount(self,"LiquidTiberium")
	self.dt.LiquidTiberium = RefTib
	WTib.TriggerOutput(self,"LiquidTiberium",RefTib)
	WTib.TriggerOutput(self,"MaxLiquidTiberium",WTib.GetNetworkCapacity(self,"LiquidTiberium"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end
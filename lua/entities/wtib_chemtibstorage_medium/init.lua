AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()

	self:SetModel("models/tiberium/medium_chemical_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Outputs = WTib.CreateOutputs(self,{"ChemicalTiberium","MaxChemicalTiberium"})
	WTib.RegisterEnt(self,"Storage")
	WTib.AddResource(self,"ChemicalTiberium",3000)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	self:SetChemicalTiberiumAmount(WTib.GetResourceAmount(self,"ChemicalTiberium"))
	WTib.TriggerOutput(self,"ChemicalTiberium",self:GetChemicalTiberiumAmount())
	WTib.TriggerOutput(self,"MaxChemicalTiberium",WTib.GetNetworkCapacity(self,"ChemicalTiberium"))
end

function ENT:OnRestore()
	WTib.Restored(self)
end

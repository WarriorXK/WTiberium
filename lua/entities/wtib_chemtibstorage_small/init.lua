AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/tiberium/small_chemical_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"ChemicalTiberium","MaxChemicalTiberium"})
	WTib.RegisterEnt(self,"Storage")
	WTib.AddResource(self,"ChemicalTiberium",1000)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

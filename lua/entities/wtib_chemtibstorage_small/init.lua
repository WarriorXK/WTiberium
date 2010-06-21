AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/small_chemical_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"ChemicalTiberium","MaxChemicalTiberium"})
	WTib.AddResource(self,"ChemicalTiberium",1000)
	WTib.RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,23,self)
end
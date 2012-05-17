AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.ChemRequired = 25
ENT.EnergySupply = 150

function ENT:Initialize()
	self:SetModel("models/Tiberium/small_tiberium_reactor.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"On","Boost"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Chemicals","Boosting"})
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"ChemicalTiberium",0)
	WTib.AddResource(self,"LiquidTiberium",0)
	WTib.AddResource(self,"energy",0)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

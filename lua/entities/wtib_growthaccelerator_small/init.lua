AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.AccelerationLevel	= 1.5
ENT.MaxRange			= 170
ENT.MinRange			= 10

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_growth_accelerator.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"On","SetRange"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Range","MaxRange","Energy"})
	WTib.AddResource(self,"energy",0)
	WTib.RegisterEnt(self,"Generator")
	self:SetRange(self.MinRange)
	WTib.TriggerOutput(self,"MaxRange",self.MaxRange)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,23,self)
end

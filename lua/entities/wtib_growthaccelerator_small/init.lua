AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.MinAccelerationAmount	= 20
ENT.MaxAccelerationAmount	= 30
ENT.AccelerationDelay		= 5
ENT.InfectionChance			= 7
ENT.MaxRange				= 256
ENT.MinRange				= 10

ENT.EffectOrigin = Vector(0,0,13)
ENT.Scale = 2

function ENT:Initialize()
	self:SetModel("models/Tiberium/small_growth_accelerator.mdl")
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
	self:SetRange(self.MaxRange)
	WTib.TriggerOutput(self,"MaxRange",self.MaxRange)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

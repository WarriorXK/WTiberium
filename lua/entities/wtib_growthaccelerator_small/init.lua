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

ENT.EffectOrigin = Vector(0,0,16)
ENT.Scale = 2

function ENT:Initialize()

	self:SetModel("models/tiberium/acc_s.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:CommonInit()
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

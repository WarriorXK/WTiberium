AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.MaxCount = 7
ENT.MaxMul = 13
ENT.MinMul = 7

function ENT:Initialize()

	self:SetModel("models/tiberium/large_trip.mdl")
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

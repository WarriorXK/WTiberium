AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/tib_antidote.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Touch(ply)
	self:Use(ply)
end

function ENT:Use(ply)
	if ply:IsPlayer() and (ply:Health() < ply:GetMaxHealth() or WTib.IsInfected(ply)) then
		ply:SetHealth(math.Clamp(ply:Health()+20,1,ply:GetMaxHealth()))
		WTib.Disenfect(ply)
		ply:EmitSound("items/medshot4.wav")
		self:Remove()
		return
	end
end

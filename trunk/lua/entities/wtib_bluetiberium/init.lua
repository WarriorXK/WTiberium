AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_gammarays/tiberium.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetColor(self.r,self.g,self.b,150)
	self:SetMaterial("models/debug/debugwhite")
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.NextProduce = CurTime()+math.Rand(30,60)
	self.NextGas = CurTime()+math.Rand(5,60)
	self:Think()
	self:SetTiberiumAmount(math.Rand(200,500))
end

function ENT:SpawnFunction(p,t)
	return WTib_CreateTiberiumByTrace(t,"wtib_bluetiberium",p)
end

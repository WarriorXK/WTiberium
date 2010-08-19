AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.Launched = false

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiberium_missile.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.dt.Warhead = 1
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,9,self)
end

function ENT:Think()
	self:GetWarheadTable().Think(self)
end

function ENT:SetWarhead(int)
	self:GetWarheadTable(int).OnApply(self)
	self.dt.Warhead = int
end

function ENT:Launch(ply)
	self.WDSO = ply
	self.NoPhysicsPickup = true
	constraint.RemoveAll(self)
	self:SetParent(nil)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(30)
		phys:Wake()
	end
	self.Launched = true
	self:GetWarheadTable().Launch(self)
end

function ENT:CanBeMounted()
	return !WTib.IsValid(self.Launcher) and !self.Launched
end

function ENT:LoadToLauncher(ent)
	self.Launcher = ent
	self:SetAngles(ent:GetAngles())
	self:SetPos(ent:GetPos())
	self:SetParent(ent)
	constraint.Weld(ent,self,0,0,0,false)
	constraint.NoCollide(ent,self,0,0)
end

function ENT:PhysicsCollide(data,phys)
	if data.HitEntity and self.Launched and data.HitEntity != self.MissileL then
		self:Explode(data)
	end
end

function ENT:PhysicsUpdate(phys)
	if !self.Launched then return end
	phys:ApplyForceCenter(self:GetForward()*20000)
	if self.Target and self.Target != Vector(0,0,0) and (self.LockDelay or 0) <= CurTime() then
		local Dist = math.min((self.Target-self:GetPos()):Length(),5000)
		local Mod = math.Clamp(math.abs(Dist-5000)/3000,0.5,70)
		local TAng = (self.Target-self:GetPos()):Angle()
		local ang = self:GetAngles()
		ang.p = math.ApproachAngle(ang.p,TAng.p,Mod)
		ang.r = math.ApproachAngle(ang.r,TAng.r,Mod)
		ang.y = math.ApproachAngle(ang.y,TAng.y,Mod)
		if self:GetAngles() != ang then
			self:SetAngles(ang)
		end
		if Dist < 5 then
			self:Explode()
		end
	end
end

function ENT:Explode(data)
	self:GetWarheadTable().Explode(self,data)
end

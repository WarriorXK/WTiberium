AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.ProjectileSpeed = 80
ENT.LockDelay = 0
ENT.TargetPos = Vector(0,0,0)
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
	self:StartMotionController()
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think() self:NextThink(CurTime()+1) return true end

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
	self:SetPhysicsAttacker(ply)
	self.LockDelay = CurTime()+self.Launcher.LockDelay
	self.Launched = true
	local e = ents.Create("env_fire_trail")
	e:SetAngles(self:GetAngles())
	e:SetPos(self:LocalToWorld(Vector(-70,0,7)))
	e:SetParent(self)
	e:Spawn()
	e:Activate()
	self:DeleteOnRemove(e)
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
		self:Explode(data, data.HitPos, data.HitEntity, data.Speed, data.HitNormal)
	end
end

function ENT:PhysicsSimulate(phys,deltatime)
	if !self.Launched then return end
	phys:Wake()
	self.TAngle = (ValidEntity(self.Launcher) and self.Launcher.Locked and self.LockDelay < CurTime()) and (Vector(self.Launcher.CoX,self.Launcher.CoY,self.Launcher.CoZ)-self:GetPos()):Angle() or self:GetAngles()
	local pr = {}
	pr.secondstoarrive	= 0.5
	pr.pos				= self:GetPos()+self:GetForward()*self.ProjectileSpeed
	pr.maxangular		= 5000
	pr.maxangulardamp	= 10000
	pr.maxspeed			= 1000000
	pr.maxspeeddamp		= 10000
	pr.dampfactor		= 0.1
	pr.teleportdistance	= 0
	pr.deltatime		= deltatime
	pr.angle			= self.TAngle
	phys:ComputeShadowControl(pr)
end

function ENT:Explode(HitPos, Ent, Speed, Normal)
	util.BlastDamage(self,ValidEntity(self.WDSO) and self.WDSO or self,self:GetPos(),math.Rand(200,300),math.Rand(300,400))
	local ed = EffectData()
	ed:SetOrigin(HitPos or self:GetPos())
	ed:SetStart(HitPos or self:GetPos())
	ed:SetScale(3)
	util.Effect("Explosion",ed)
	self:Remove()
end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.ProjectileSpeed = 80
ENT.LockDelay = 0
ENT.TargetPos = Vector(0,0,0)
ENT.Launched = false

ENT.Warhead = {}
ENT.Warhead.Range = 62.5
ENT.Warhead.Damage = 220
ENT.Warhead.DOT_DPS = 12.5

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
	
		self:Explode(data.HitPos, data.HitEntity, data.Speed, data.HitNormal)
		
	end
	
end

function ENT:PhysicsSimulate(phys,deltatime)

	if !self.Launched then return end
	
	phys:Wake()
	
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
	pr.angle			= (IsValid(self.Launcher) and self.Launcher.Locked and self.LockDelay < CurTime()) and (Vector(self.Launcher.CoX,self.Launcher.CoY,self.Launcher.CoZ)-self:GetPos()):Angle() or self:GetAngles()
	phys:ComputeShadowControl(pr)
	
end

function ENT:Explode(HitPos, Ent, Speed, Normal)
	
	local dmginfo = DamageInfo()
	dmginfo:SetInflictor(self)
	dmginfo:SetAttacker(self.WDSO)
	dmginfo:SetDamageType(DMG_BLAST)
	
	WTib.DebugPrintTable(self.Warhead)
	
	for _,v in pairs(ents.FindInSphere(HitPos, self.Warhead.Range)) do
		
		if IsValid(v) and ((v:IsPlayer() and v:Health() > 0) or v:IsNPC()) then
			
			if self.Warhead.DOT_DPS > 0 then WTib.Infect(v, self.WDSO, self, self.Warhead.DOT_DPS, self.Warhead.DOT_DPS + 2, true) end
			
			local Dmg = self.Warhead.Damage * math.Clamp(-((HitPos:Distance(v:NearestPoint(HitPos)) / self.Warhead.Range)-1),0.2,1)
			print(Dmg)
			dmginfo:SetDamage(Dmg)
			v:TakeDamageInfo(dmginfo)
			
		end
		
	end
	
	local ed = EffectData()
		ed:SetOrigin(HitPos)
		ed:SetNormal(Normal)
	util.Effect("Explosion", ed)
	
	self:Remove()
	
end

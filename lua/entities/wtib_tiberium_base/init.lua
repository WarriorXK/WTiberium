AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextReproduce = 0
ENT.NextGrow = 0

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiberium_crystal1.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:DrawShadow(false)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:InitTiberium()
end

function ENT:SpawnFunction(p,t)
	return WTib.CreateTiberium(self,self.Class,t,p)
end

function ENT:InitTiberium()
	if self:GetField() <= 0 then
		self:SetField(WTib.CreateField(self))
	end
	self:SetTiberiumAmount(self.TiberiumStartAmount)
	for i=2,100 do
		if (self:GetMaxTiberiumAmount()/i) == 250 then
			self.dt.ColorDevider = i
		end
	end
	self:SetColor(self.TiberiumColor.r,self.TiberiumColor.g,self.TiberiumColor.b,((self:GetTiberiumAmount()/self:GetColorDevider())/2)+100)
	self:CheckColor()
end

function ENT:Think()
	local MaxTiberium = self:GetMaxTiberiumAmount()
	if self.NextGrow <= CurTime() then
		self:SetTiberiumAmount(self:GetTiberiumAmount()+self.Growth_Addition)
		self.NextGrow = CurTime()+self.Growth_Delay
	end
	if self.NextReproduce <= CurTime() and self:GetTiberiumAmount() >= self.Reproduce_TiberiumRequired then
		self:AttemptReproduce()
	end
	self.dt.CrystalSize = self:GetTiberiumAmount()/MaxTiberium
	self:CheckColor()
	self:DamageTouchingEntities()
	self:NextThink(CurTime()+1)
	return true
end

function ENT:OnTakeDamage(dmginfo)
	if self.Damage_Explosive and dmginfo:IsExplosionDamage() and dmginfo:GetDamage() > self.Damage_Explode_RequiredDamage then
		timer.Simple(math.random(self.Damage_ExplosionDelay-0.2,self.Damage_ExplosionDelay+0.2),self.Explode,self,dmginfo)
		self.OnTakeDamage = function() end
	end
end

function ENT:Explode(dmginfo)
	if ValidEntity(self) then
		util.BlastDamage(self,self,self:LocalToWorld(self:OBBCenter()),self.Damage_Explode_Size,self.Damage_Explode_Damage)
		local ed = EffectData()
			ed:SetOrigin(self:LocalToWorld(self:OBBCenter()))
			ed:SetStart(self:LocalToWorld(self:OBBCenter()))
			ed:SetScale(self.Damage_Explode_Size)
			ed:SetRadius(self.Damage_Explode_Size*10)
		util.Effect("Explosion",ed)
		self:Remove()
	end
end

function ENT:CheckColor()
	local inc = 2
	local Or,Og,Ob,Oa = self:GetColor()
	self:SetColor(
		math.Approach(Or,self.TiberiumColor.r,inc),
		math.Approach(Og,self.TiberiumColor.g,inc),
		math.Approach(Ob,self.TiberiumColor.b,inc),
		math.Approach(Oa,((self:GetTiberiumAmount()/self:GetColorDevider())/2)+100,inc)
	)
end

function ENT:DamageTouchingEntities()
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_ACID)
	dmginfo:SetDamage((self:GetCrystalSize()*10)+(self:GetTiberiumAmount()/100))
	local Range = 60*self:GetCrystalSize()
	for k,v in pairs(ents.FindInSphere(self:GetPos(),Range)) do
		if (v:IsPlayer() and v:Alive()) or v:IsNPC() then
			v:TakeDamageInfo(dmginfo)
		end
	end
end

function ENT:AttemptReproduce()
	local AllEntities = ents.GetAll()
	local Filter = {}
	for _,v in pairs(AllEntities) do
		if v.IsTiberium or (v.Alive and v:Alive()) then
			table.insert(Filter,v)
		end
	end
	for i=1,5 do
		local pos = self:LocalToWorld(self:OBBCenter())
		local t = WTib.Trace(pos,VectorRand()*math.random(-500,500),Filter)
		local ed = EffectData()
			ed:SetOrigin(pos)
			ed:SetStart(t.HitPos)
			ed:SetMagnitude(10)
			ed:SetScale(2)
		WTib.DebugEffect("WTib_DebugTrace",ed)
		local Save = true
		if !t.Hit then
			pos = t.HitPos
			t = WTib.Trace(t.HitPos,Vector(0,0,-1)*300,Filter)
			local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetStart(t.HitPos)
				ed:SetMagnitude(10)
				ed:SetScale(2)
			WTib.DebugEffect("WTib_DebugTrace",ed)
		end
		if ValidEntity(WTib.CreateTiberium(self,self.Class,t,self.WDSO)) then
			WTib.DebugPrint("New Tiberium grown from old")
			self.NextReproduce = CurTime()+self.Reproduce_Delay
			self:SetTiberiumAmount(self:GetTiberiumAmount()-self.Reproduce_TiberiumDrained)
			break
		else
			self.NextReproduce = CurTime()+2
		end
	end
end

function ENT:TakeSonicDamage(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount()-am)
end

function ENT:Die()
	self:Remove()
end

function ENT:SetField(num)
	self.dt.TiberiumField = num
end

function ENT:SetTiberiumAmount(am)
	if am <= 0 then
		self:Die()
	else
		self.dt.TiberiumAmount = math.Clamp(am,1,self:GetMaxTiberiumAmount())
	end
end
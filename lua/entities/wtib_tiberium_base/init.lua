AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextReproduce = 0
ENT.Produces = {}
ENT.NextGrow = 0

function ENT:Initialize()
	self:SetRandomModel()
	self:PhysicsInit(SOLID_BBOX)
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

function ENT:SetRandomModel()
	local Modl = ""
	if type(self.Models) == "table" then Modl = table.Random(self.Models) end
	if type(Modl) != "string" or !util.IsValidModel(Modl) then Modl = "models/Tiberium/tiberium_crystal1.mdl" end
	self:SetModel(Modl)
end

function ENT:SpawnFunction(p,t)
	return WTib.CreateTiberium(self,self.ClassName,t,p)
end

function ENT:InitTiberium()
	self.NextReproduce = 0
	self.Produces = {}
	self.NextGrow = 0
	if self:GetField() <= 0 then self:SetField(WTib.CreateField(self)) end // If no field was set before we spawned create one
	self:SetTiberiumAmount(self.TiberiumStartAmount)
	
	for i=2,100 do // Efficiency at its best
		if (self:GetMaxTiberiumAmount()/i) == 250 then
			self.dt.ColorDevider = i
		end
	end
	
	self:SetRenderMode(self.RenderMode)
	self:SetColor(Color(self.TiberiumColor.r,
						self.TiberiumColor.g,
						self.TiberiumColor.b,
						((self:GetTiberiumAmount()/self:GetColorDevider())/2)+100))
	self:CheckColor()
end

function ENT:Think()
	if self.NextGrow <= CurTime() then // Check if we should get more resources
		self:AddTiberiumAmount(self.Growth_Addition)
		self.NextGrow = CurTime()+self.Growth_Delay
	end
	if self.NextReproduce <= CurTime() and self:GetTiberiumAmount() >= self.Reproduce_TiberiumRequired then self:AttemptReproduce() end // Check if we should reproduce
	
	self:CalcSize()
	self:CheckColor()
	self:DamageTouchingEntities()
	
	self:NextThink(CurTime()+1)
	return true
end

function ENT:CalcSize()
	local LocalScale = (self:GetTiberiumAmount()/self:GetMaxTiberiumAmount())
	local FieldScale = 1 // Todo: Scale by distance from center
	self.dt.CrystalSize = (LocalScale * FieldScale)
end

function ENT:OnTakeDamage(dmginfo)
	if self.Damage_Explosive and dmginfo:IsExplosionDamage() and dmginfo:GetDamage() > self.Damage_Explode_RequiredDamage then
		timer.Simple(math.Rand(self.Damage_ExplosionDelay-0.5,self.Damage_ExplosionDelay+0.5),self.Explode,self,dmginfo)
		self.OnTakeDamage = function() end
	end
end

function ENT:Explode(dmginfo)
	if WTib.IsValid(self) then
		util.BlastDamage(self,self,self:LocalToWorld(self:OBBCenter()),self.Damage_Explode_Size,self.Damage_Explode_Damage)
		local ed = EffectData()
			ed:SetOrigin(self:LocalToWorld(self:OBBCenter()))
			ed:SetStart(self:LocalToWorld(self:OBBCenter()))
			ed:SetScale(self.Damage_Explode_Size)
			ed:SetRadius(self.Damage_Explode_Size*10)
		util.Effect("Explosion",ed)
		self:Die()
	end
end

function ENT:CheckColor()
	local inc = 2
	local Col = self:GetColor()
	self:SetRenderMode(self.RenderMode)
	self:SetColor(Color(
		math.Approach(Col.r,self.TiberiumColor.r,inc),
		math.Approach(Col.g,self.TiberiumColor.g,inc),
		math.Approach(Col.b,self.TiberiumColor.b,inc),
		math.Approach(Col.a,((self:GetTiberiumAmount()/self:GetColorDevider())/2)+75,inc))
	)
end

function ENT:DamageTouchingEntities()
	local CSize = (self:GetCrystalSize() + 0.5)
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_ACID)
	dmginfo:SetDamage((CSize*8)+(self:GetTiberiumAmount()/100))
	local Range = 50*CSize
	if Range < 5 then Range = 5 end
	for _,v in pairs(ents.FindInSphere(self:GetPos(),Range)) do
		if v:IsNPC() then
			v:TakeDamageInfo(dmginfo)
			if math.random(0,1) == 1 then WTib.Infect(v) end
		elseif v:IsPlayer() then
			if v:Armor() > 0 then // If the player has suit armor then only deal armor damage, no infection can occur
				v:SetArmor(v:Armor() - dmginfo:GetDamage())
				v:TakeDamage(0, self, self) // Shows the player that he is being damaged (Is there a better way?)
			else
				v:TakeDamageInfo(dmginfo)
				if math.random(0,1) == 1 then WTib.Infect(v) end
			end
		end
	end
end

function ENT:AttemptReproduce()
	if WTib.IsFieldFull(self:GetField()) then
		self.NextReproduce = CurTime()+self.Reproduce_Delay
		WTib.DebugPrint(tostring(self) .. " - Field is full")
		return
	end
	local Amount = 0
	for k,v in pairs(self.Produces) do
		if WTib.IsValid(v) then
			Amount = Amount+1
		else
			self.Produces[k] = nil
		end
	end
	if Amount >= self.Reproduce_MaxProduces then
		self.NextReproduce = CurTime()+self.Reproduce_Delay
		WTib.DebugPrint(tostring(self) .. " - To much!")
		return
	end
	local AllEntities = ents.GetAll()
	local Filter = {}
	for _,v in pairs(AllEntities) do
		if v.IsTiberium or (v.Alive and v:Alive()) then
			table.insert(Filter,v)
		end
	end
	for i=1,10 do
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
			t = WTib.Trace(t.HitPos,(self:GetUp()*-1)*300,Filter)
			local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetStart(t.HitPos)
				ed:SetMagnitude(10)
				ed:SetScale(2)
			WTib.DebugEffect("WTib_DebugTrace",ed)
		end
		local ent = WTib.CreateTiberium(self,self.ClassToSpawn,t,self.WDSO)
		if WTib.IsValid(ent) then
			table.insert(self.Produces,ent)
			WTib.DebugPrint("New Tiberium grown from old")
			self.NextReproduce = CurTime()+self.Reproduce_Delay
			self:DrainTiberiumAmount(self.Reproduce_TiberiumDrained)
			WTib.AddFieldMember(self:GetField(),ent)
			break
		else
			self.NextReproduce = CurTime()+60
		end
	end
end

function ENT:TakeSonicDamage(am) // Do something fancy?
	self:DrainTiberiumAmount(am)
end

function ENT:Die() // Do something fancy?
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

function ENT:AddTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() + am)
end

function ENT:DrainTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() - am)
end

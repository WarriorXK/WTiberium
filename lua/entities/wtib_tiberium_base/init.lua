AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextReproduce = 0
ENT.Produces = {}
ENT.NextGrow = 0

function ENT:SetRandomModel()

	local Modl = ""
	if type(self.Models) == "table" then Modl = table.Random(self.Models) end
	if type(Modl) != "string" or !util.IsValidModel(Modl) then Modl = "models/Tiberium/tiberium_crystal1.mdl" end // To make sure the selected model path from the table is valid
	
	self:SetModel(Modl)
	
end

function ENT:SpawnFunction(p,t)
	return WTib.CreateTiberium(self,self.ClassName,t,p)
end

function ENT:Think()

	if self.NextGrow <= CurTime() then // Check if we should get more resources
	
		self:AddTiberiumAmount(self.Growth_Addition)
		self.NextGrow = CurTime()+self.Growth_Delay
		
	end

	self:DamageTouchingEntities()

	self:NextThink(CurTime()+1)
	return true
	
end

function ENT:CalcSize()

	local LocalScale = (self:GetTiberiumAmount()/self:GetMaxTiberiumAmount())
	local FieldScale = 1 // Todo: Scale by distance from center
	self.dt.CrystalSize = (LocalScale * FieldScale)
	
end

function ENT:CheckColor()

	local Col = self:GetColor()
	
	self:SetRenderMode(self.RenderMode)
	self:SetColor(Color(
		math.Approach(Col.r, self.TiberiumColor.r, 5),
		math.Approach(Col.g, self.TiberiumColor.g, 5),
		math.Approach(Col.b, self.TiberiumColor.b, 5),
		math.Approach(Col.a, ((self:GetTiberiumAmount()/self:GetColorDevider())/2) + 75, 2))
	)
	
end

function ENT:OnTakeDamage(dmginfo)

	if self.Damage_Explosive and dmginfo:IsExplosionDamage() and dmginfo:GetDamage() >= self.Damage_Explode_RequiredDamage and type(self.Explode) == "function" then
	
		timer.Simple(math.Rand(self.Damage_ExplosionDelay - 0.5,self.Damage_ExplosionDelay + 0.5), function() self:Explode() end)
		
		self.OnTakeDamage = function() end
		
	end
	
end

function ENT:Explode()

	if WTib.IsValid(self) then
	
		util.BlastDamage(self,self,self:LocalToWorld(self:OBBCenter()),self.Damage_Explode_Size,self.Damage_Explode_Damage)
		
		local ed = EffectData()
			ed:SetOrigin(self:LocalToWorld(self:OBBCenter()))
			ed:SetStart(self:LocalToWorld(self:OBBCenter()))
			ed:SetScale(self.Damage_Explode_Size)
			ed:SetRadius(self.Damage_Explode_Size * 10)
		util.Effect("Explosion",ed)
		
		self:Die()
		
	end
	
end

function ENT:DamageTouchingEntities()

	local CSize = (self:GetCrystalSize() + 0.5)
	
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_ACID)
	dmginfo:SetDamage((CSize*8)+(self:GetTiberiumAmount()/100))

	for _,v in pairs(ents.FindInSphere(self:GetPos(), math.max(50 * CSize, 5))) do
	
		if v:IsNPC() then
		
			v:TakeDamageInfo(dmginfo)
			self:AttemptInfection(v)
			
		elseif v:IsPlayer() then
		
			if v:Armor() > 0 then // If the player has suit armor then only deal armor damage, no infection can occur
			
				v:SetArmor(v:Armor() - dmginfo:GetDamage())
				v:TakeDamage(0, self, self) // Shows the player that he is being damaged (Is there a better way?)
				
			else
			
				v:TakeDamageInfo(dmginfo)
				self:AttemptInfection(v)
				
			end
			
		end
		
	end
	
end

function ENT:AttemptInfection(ent)

	if WTib.Config.InfectionChance > 0 and math.random(1, WTib.Config.InfectionChance) == 1 then
		WTib.Infect(ent, self, self, 1, 3, false)
	end
	
end

function ENT:AttemptReproduce()
	if !self:CanReproduce() then return false end
	
	local Filter = {}
	for _,v in pairs(ents.GetAll()) do
		if v.IsTiberium or (v:IsPlayer() and v:Alive()) or v:IsNPC() then
			table.insert(Filter,v)
		end
	end
	
	for i=1, 7 do
	
		local pos = self:LocalToWorld(self:OBBCenter())
		local Rnd = i * 70
		local t = WTib.Trace(pos, VectorRand() * math.random(-Rnd, Rnd), Filter)
		
		if WTib.Debug then
			local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetStart(t.HitPos)
				ed:SetMagnitude(10)
				ed:SetScale(2)
			util.Effect("WTib_DebugTrace",ed)
		end
		
		if !t.Hit then
		
			pos = t.HitPos
			t = WTib.Trace(t.HitPos,(self:GetUp()*-1)*300,Filter)
			
			if WTib.Debug then
				local ed = EffectData()
					ed:SetOrigin(pos)
					ed:SetStart(t.HitPos)
					ed:SetMagnitude(10)
					ed:SetScale(2)
				util.Effect("WTib_DebugTrace",ed)
			end
			
		end
		
		if t.Hit then
		
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
	
	return false
	
end

function ENT:CanReproduce()

	if WTib.IsFieldFull(self:GetField()) then return false end
	
	local Amount = 0
	for k,v in pairs(self.Produces) do
		if WTib.IsValid(v) then
			Amount = Amount+1
		else
			self.Produces[k] = nil
		end
	end
	if Amount >= self.Reproduce_MaxProduces then return false end
	
	return true
	
end

function ENT:TakeSonicDamage(am) // Todo : Add an effect?
	self:DrainTiberiumAmount(am)
end

function ENT:Die() // Todo : Add an effect?
	self:Remove()
end

function ENT:SetField(num)
	self.dt.TiberiumField = num
end

function ENT:SetTiberiumAmount(am)

	if am <= 0 then self:Die() return end
	
	self.dt.TiberiumAmount = math.Clamp(am,1,self:GetMaxTiberiumAmount())
	
	if self.NextReproduce <= CurTime() and self:GetTiberiumAmount() >= self.Reproduce_TiberiumRequired then self:AttemptReproduce() end // Check if we should reproduce
	
	self:CalcSize()
	self:CheckColor()
	
end

function ENT:AddTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() + am)
end

function ENT:DrainTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() - am)
end

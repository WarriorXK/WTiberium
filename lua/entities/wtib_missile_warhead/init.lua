AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

function ENT:Initialize()
	self:SetModel("models/Tiberium/tiberium_warhead.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Touch(ent)

	if IsValid(ent) and ent:GetClass() == "wtib_missile_projectile" then
	
		if type(self.ApplyWarhead) == "function" then self:ApplyWarhead(ent) end
		
		self:Remove()
		return
		
	end
	
end

function ENT:SetWarheadValues(en, raw, ref, chem, liq)

	self:SetRawTiberiumAmount(raw)
	self:SetRefTiberiumAmount(ref)
	self:SetChemicalsAmount(chem)
	self:SetLiquidsAmount(liq)
	
end

function ENT:ApplyWarhead(missle)

	missle.Warhead = {}
	missle.Warhead.Range = math.max(50, (2.5 * self:GetRawTiberiumAmount()))
	missle.Warhead.Damage = 120 + (4 * self:GetRefTiberiumAmount())
	missle.Warhead.DOT_DPS = math.max(2, self:GetChemicalsAmount() / 2)
	
	missle.Explode = self.Explode
	
end

function ENT:Explode(HitPos, Ent, Speed, Normal)
	
	local dmginfo = DamageInfo()
	dmginfo:SetInflictor(self)
	if IsValid(self.WDSO) then dmginfo:SetAttacker(self.WDSO) end
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

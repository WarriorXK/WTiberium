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

	self.dt.RawTiberium = raw
	self.dt.RefTiberium = ref
	self.dt.Chemicals = chem
	self.dt.Liquids = liq
	
end

function ENT:ApplyWarhead(missle)
	missle.Explode = self.Explode
end

function ENT:Explode(HitPos, Ent, Speed, Normal)
	
	
	
	self:Remove()
end

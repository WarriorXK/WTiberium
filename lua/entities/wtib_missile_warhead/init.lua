AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.RawTiberium = 0
ENT.RefTiberium = 0
ENT.Chemicals = 0
ENT.Liquids = 0

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
	if ValidEntity(ent) and ent:GetClass() == "wtib_missile_projectile" then
		ent.Explode = self.Explode
		self:Remove()
		return
	end
end

function ENT:SetWarheadValues(en, raw, ref, chem, liq)
	self.RawTiberium = raw
	self.RefTiberium = ref
	self.Chemicals = chem
	self.Liquids = liq
end

function ENT:Explode()
	self:Remove()
end

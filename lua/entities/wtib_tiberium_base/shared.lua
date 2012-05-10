ENT.Type			= "anim"
ENT.PrintName		= "Tiberium Base"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true

ENT.RenderMode = RENDERMODE_TRANSTEXTURE

ENT.Reproduce_TiberiumRequired = 1000
ENT.Reproduce_TiberiumDrained = 400
ENT.Reproduce_MaxProduces = 5
ENT.Reproduce_Delay = 30

ENT.TiberiumStartAmount = 400
ENT.MaxTiberiumAmount = 2000
ENT.TiberiumColor = Color(0,0,0,0)
ENT.Models =	{
					"models/Tiberium/tiberium_crystal1.mdl",
					"models/Tiberium/tiberium_crystal3.mdl"
				}
ENT.ClassToSpawn = "wtib_tiberium_base"

ENT.Damage_Explode_RequiredDamage = 0
ENT.Damage_ExplosionDelay = 0
ENT.Damage_Explode_Damage = 0
ENT.Damage_Explode_Size = 0
ENT.Damage_Explosive = false

ENT.Growth_Addition = 30
ENT.Growth_Delay = 10

ENT.DecalSize = 1
ENT.Decal = ""

function ENT:SetupDataTables()
	self:DTVar("Int",0,"TiberiumAmount")
	self:DTVar("Int",1,"TiberiumType")
	self:DTVar("Int",2,"ColorDevider")
	self:DTVar("Int",3,"TiberiumField")
	self:DTVar("Float",0,"CrystalSize")
end

function ENT:GetTiberiumAmount()
	return self.dt.TiberiumAmount
end

function ENT:GetTiberiumType()
	return self.dt.TiberiumType
end

function ENT:GetMaxTiberiumAmount()
	return self.MaxTiberiumAmount
end

function ENT:GetColorDevider()
	return self.dt.ColorDevider
end

function ENT:GetCrystalSize()
	return self.dt.CrystalSize
end

function ENT:GetField()
	return self.dt.TiberiumField
end

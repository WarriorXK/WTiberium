ENT.Type			= "anim"
ENT.PrintName		= "Missile"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.WTib_IsMissile	= true

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Warhead")
end

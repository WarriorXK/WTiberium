ENT.Type			= "anim"
ENT.PrintName		= "Power Generator Medium"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Boosting")
	self:DTVar("Int",1,"Chemicals")
	self:DTVar("Bool",0,"Online")
end
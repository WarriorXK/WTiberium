ENT.Type			= "anim"
ENT.PrintName		= "Tiberium Radar"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Bool",0,"Online")
	self:DTVar("Bool",1,"HasTarget")
	self:DTVar("Int",0,"Energy")
end

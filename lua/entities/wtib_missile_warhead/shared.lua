ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Tiberium infused warhead"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"RawTiberium")
	self:DTVar("Int",1,"RefTiberium")
	self:DTVar("Int",2,"Chemicals")
	self:DTVar("Int",3,"Liquids")
end

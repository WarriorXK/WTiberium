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
	self:NetworkVar("Int",0,"RawTiberium")
	self:NetworkVar("Int",1,"RefTiberium")
	self:NetworkVar("Int",2,"Chemicals")
	self:NetworkVar("Int",3,"Liquids")
end

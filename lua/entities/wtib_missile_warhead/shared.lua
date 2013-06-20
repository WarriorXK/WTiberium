ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Tiberium infused warhead"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"RawTiberiumAmount")
	self:NetworkVar("Int",1,"RefinedTiberiumAmount")
	self:NetworkVar("Int",2,"TiberiumChemicalsAmount")
	self:NetworkVar("Int",3,"LiquidTiberiumAmount")
end

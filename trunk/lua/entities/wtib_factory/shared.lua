ENT.Type			= "anim"
ENT.PrintName		= "Factory"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"BuildingID")
	self:DTVar("Int",1,"PercentageComplete")
	self:DTVar("Bool",0,"IsBuilding")
	self:DTVar("Entity",0,"CurObject")
end

hook.Add("PhysgunPickup","WTib_Factory_CanPickupEnt",function(ply,ent)
	if ent:GetClass() == "wtib_factory_object" then
		return false
	end
end)
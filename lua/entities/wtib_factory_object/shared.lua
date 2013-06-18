ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Factory Object"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"Factory")
end

hook.Add("PhysgunPickup","WTib_Factory_CanPickupEnt_object",function(ply,ent)
	if ent:GetClass() == "wtib_factory_object" then
		return false
	end
end)

ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Dispenser Object"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "You shouldn't be able to spawn this, report this as an error"
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Dispenser")
end

hook.Add("PhysgunPickup","WTib_Dispenser_CanPickupEnt_object",function(ply, ent)
	if IsValid(ent) and ent:GetClass() == "wtib_dispenser_object" then
		return false
	end
end)

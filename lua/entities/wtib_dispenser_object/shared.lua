ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Dispenser Object"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Entity",0,"Dispenser")
end

hook.Add("PhysgunPickup","WTib_Dispenser_CanPickupEnt_object",function(ply,ent)
	if ent:GetClass() == "wtib_dispenser_object" then
		return false
	end
end)

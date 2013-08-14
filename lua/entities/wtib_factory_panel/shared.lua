ENT.Type			= "anim"
ENT.PrintName		= "Factory Object"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "You shouldn't be able to spawn this, report this as an error"
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"Factory")
end

local function Pickup(ply,ent)
	if IsValid(ent) and ent:GetClass() == "wtib_factory_panel" then
		return false
	end
end
hook.Add("PhysgunPickup","WTib_Factory_CanPickupEnt_Panel",Pickup)
hook.Add("GravGunPickupAllowed","WTib_Factory_CanPickupEnt_Panel",Pickup)
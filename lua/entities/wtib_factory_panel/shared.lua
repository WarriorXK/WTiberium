ENT.Type			= "anim"
ENT.PrintName		= "Factory Object"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Entity",0,"Factory")
end

local function Pickup(ply,ent)
	if IsValid(ent) and ent:GetClass() == "wtib_factory_panel" then
		return false
	end
end
hook.Add("PhysgunPickup","WTib_Factory_CanPickupEnt_Panel",Pickup)
hook.Add("GravGunPickupAllowed","WTib_Factory_CanPickupEnt_Panel",Pickup)
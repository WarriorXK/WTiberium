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

hook.Add("PhysgunPickup","WTib_Factory_CanPickupEnt_Panel",function(ply,ent)
	if ent:GetClass() == "wtib_factory_panel" then
		return false
	end
end)

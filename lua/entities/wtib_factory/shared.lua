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
	self:DTVar("Entity",1,"Panel")
end


hook.Add("OnPhysgunFreeze", "WTib_Factory_OnPhysgunFreeze", function(wep, phys, ent, ply)
	if ent:GetClass() == "wtib_factory" and ValidEntity(ent.dt.Panel) then
		ent.dt.Panel:GetPhysicsObject():EnableMotion(false)
	end
end)

hook.Add("PhysgunPickup", "WTib_Factory_PhysgunPickup", function(ply, ent)
	if ent:GetClass() == "wtib_factory" and ValidEntity(ent.dt.Panel) then
		ent.dt.Panel:GetPhysicsObject():EnableMotion(true)
	end
end)

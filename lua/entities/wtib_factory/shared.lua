ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Factory"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= "To create entities in the WTiberium addon pack"
ENT.Instructions	= "Place the Factory and use the panel to select an entity to create"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"BuildingID")
	self:DTVar("Int",1,"PercentageComplete")
	self:DTVar("Float",0,"TimeBuildStarted")
	self:DTVar("Bool",0,"IsBuilding")
	self:DTVar("Entity",0,"CurObject")
	self:DTVar("Entity",1,"Panel")
end


hook.Add("OnPhysgunFreeze", "WTib_Factory_OnPhysgunFreeze", function(wep, phys, ent, ply)
	if ent:GetClass() == "wtib_factory" and IsValid(ent.dt.Panel) then
		local Phys = ent.dt.Panel:GetPhysicsObject()
		if Phys:IsValid() then ent.dt.Panel:GetPhysicsObject():EnableMotion(false) end
	end
end)

hook.Add("PhysgunPickup", "WTib_Factory_PhysgunPickup", function(ply, ent)
	if ent:GetClass() == "wtib_factory" and IsValid(ent.dt.Panel) then
		local Phys = ent.dt.Panel:GetPhysicsObject()
		if Phys:IsValid() then ent.dt.Panel:GetPhysicsObject():EnableMotion(true) end
	end
end)

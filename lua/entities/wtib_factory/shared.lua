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
	self:NetworkVar("Int",0,"BuildingID")
	self:NetworkVar("Int",1,"PercentageComplete")
	self:NetworkVar("Float",0,"TimeBuildStarted")
	self:NetworkVar("Bool",0,"IsBuilding")
	self:NetworkVar("Entity",0,"CurObject")
	self:NetworkVar("Entity",1,"Panel")
end


hook.Add("OnPhysgunFreeze", "WTib_Factory_OnPhysgunFreeze", function(wep, phys, ent, ply)
	if ent:GetClass() == "wtib_factory" and IsValid(ent:GetPanel()) then
		local Phys = ent:GetPanel():GetPhysicsObject()
		if Phys:IsValid() then ent:GetPanel():GetPhysicsObject():EnableMotion(false) end
	end
end)

hook.Add("PhysgunPickup", "WTib_Factory_PhysgunPickup", function(ply, ent)
	if ent:GetClass() == "wtib_factory" and IsValid(ent:GetPanel()) then
		local Phys = ent:GetPanel():GetPhysicsObject()
		if Phys:IsValid() then ent:GetPanel():GetPhysicsObject():EnableMotion(true) end
	end
end)

list.Set("WTib_Tools_Generators", ENT.PrintName, { wtib_tool_generators_type = WTib.GetClass(ENT) })

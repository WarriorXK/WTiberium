ENT.Type			= "anim"
ENT.Base			= "wtib_tripmodule_medium"
ENT.PrintName		= "Large TRIP Module"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
	self:DTVar("Bool",0,"Online")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/large_trip.mdl",
	PercentDelay = 0.12,
	Information =	{
						ENT.PrintName,
						"\nUses Tiberium radiation to generate energy."
					},
	CreateEnt = function(factory,angles,pos,id)
		local ent = ents.Create(WTib.Factory.GetObjectByID(id).Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Factory.GetObjectByID(id).Model)
		return ent
	end
})

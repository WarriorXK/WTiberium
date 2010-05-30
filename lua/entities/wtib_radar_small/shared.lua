ENT.Type			= "anim"
ENT.Base			= "wtib_radar_medium"
ENT.PrintName		= "Small Tiberium Radar"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Bool",0,"Online")
	self:DTVar("Bool",1,"HasTarget")
	self:DTVar("Int",0,"Energy")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/small_tiberium_radar.mdl",
	PercentDelay = 0.02,
	Information =	{
						ENT.PrintName,
						"\nSmall Radar."
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

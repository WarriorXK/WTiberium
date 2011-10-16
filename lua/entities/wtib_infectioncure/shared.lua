ENT.Type			= "anim"
ENT.PrintName		= "Tiberium infection cure"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

WTib.Dispenser.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/tib_antidote.mdl",
	PercentDelay = 0.02,
	Information =	{
						SWEP.PrintName,
						"\nA vial that contains the antidote for tiberium infection."
					},
	CreateEnt = function(dispenser,angles,pos,id)
		local ent = ents.Create(WTib.Dispenser.GetObjectByID(id).Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Dispenser.GetObjectByID(id).Model)
		return ent
	end
})

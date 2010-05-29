ENT.Type			= "anim"
ENT.Base			= "wtib_reftibstorage_medium"
ENT.PrintName		= "Large Refined Tiberium Storage"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"RefinedTiberium")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/large_tiberium_storage.mdl",
	PercentDelay = 0.07,
	Information =	{
						ENT.PrintName,
						"\nStores up to 9000 units of refined Tiberium."
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

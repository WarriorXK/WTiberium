ENT.Type			= "anim"
ENT.PrintName		= "Medium Chemical Plant"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
	self:DTVar("Int",1,"RefinedTiberium")
	self:DTVar("Bool",0,"Online")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/chemical_plant.mdl",
	PercentDelay = 0.15,
	Information =	{
						ENT.PrintName,
						"\nConverts refined Tiberium into Tiberium chemicals."
					},
	CreateEnt = function( factory, angles, pos, id, ply )
		local Obj = WTib.Factory.GetObjectByID(id)
		local ent = ents.Create(Obj.Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(Obj.Model)
		
		if ply then
			ent.WDSO = ply
			undo.Create(Obj.Name)
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
			undo.Finish()
		end
		
		return ent
	end
})

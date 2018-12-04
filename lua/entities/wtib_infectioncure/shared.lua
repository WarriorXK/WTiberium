ENT.Type			= "anim"
ENT.PrintName		= "Tiberium infection cure"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "Cures infected players from a Tiberium infection and restores up to 20 health points"
ENT.Instructions	= "Activate or touch the entity to use it"

WTib.Dispenser.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/tiberium/tib_antidote.mdl",
	Angle = Angle(0,0,0),
	PercentDelay = 0.02,
	Information =	{
						ENT.PrintName,
						"\nPurpose :\n" .. ENT.Purpose,
						"\nInstructions :\n" .. ENT.Instructions
					},
	CreateEnt = function(dispenser,angles,pos,id,ply)
		local Obj = WTib.Dispenser.GetObjectByID(id)
		local ent = ents.Create(Obj.Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Dispenser.GetObjectByID(id).Model)
		
		if ply then
			ent.WDSO = ply
			undo.Create(Obj.Class)
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
				undo.SetCustomUndoText("Undone "..Obj.Name)
			undo.Finish()
		end
		
		return ent
	end
})

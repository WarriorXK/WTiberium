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
	Angle = Angle(0,0,0),
	PercentDelay = 0.02,
	Information =	{
						ENT.PrintName,
						"\nA vial that contains the antidote for tiberium infection."
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

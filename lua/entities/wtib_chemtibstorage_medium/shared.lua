ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Medium Chemical Storage "
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= "This module stores 3000 units of Tiberium Chemical gasses"
ENT.Instructions	= "Link this storage unit to a network that requires additional Tiberium Chemicals storage"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"ChemicalTiberiumAmount")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/medium_chemical_storage.mdl",
	PercentDelay = 0.04,
	Information =	{
						ENT.PrintName,
						"\nPurpose :\n" .. ENT.Purpose,
						"\nInstructions :\n" .. ENT.Instructions
					},
	CreateEnt = function( factory, angles, pos, id, ply )
		local Obj = WTib.Factory.GetObjectByID(id)
		local ent = ents.Create(Obj.Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(Obj.Model)
		ent:DropToFloor()
		
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

list.Set("WTib_Tools_Storage", ENT.PrintName, { wtib_tool_storage_type = WTib.GetClass(ENT) })

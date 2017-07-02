ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Medium Tiberium Radar"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "To locate Tiberium Crystals and Tiberium Parent Crystals up to 10000 units away"
ENT.Instructions	= "Supply the radar with Energy and turn it on, using wiremod you can read out the values"

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"IsOnline")
	self:NetworkVar("Bool",1,"HasTarget")
	self:NetworkVar("Int",0,"EnergyAmount")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/tiberium/medium_tiberium_radar.mdl",
	PercentDelay = 0.05,
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

list.Set("WTib_Tools_Generators", ENT.PrintName, { wtib_tool_generators_type = WTib.GetClass(ENT) })

ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Medium TRIP"
ENT.Author			= "kevkev/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "The Tiberium Radiation Induction Panel (TRIP) converts the radiation that is emitted by Tiberium crystals into energy"
ENT.Instructions	= "Point the TRIP towards Tiberium crystals and link it up to an energy storage module"
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
	Model = "models/Tiberium/medium_trip.mdl",
	PercentDelay = 0.08,
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

WTib.Stools.Generators.AddGenerator( WTib.GetClass(ENT), ENT.PrintName )

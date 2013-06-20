ENT.Type			= "anim"
ENT.Base			= "wtib_powergen_medium"
ENT.PrintName		= "Large Powerplant"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "To generate energy from Tiberium Chemicals, the Energy output can be boosted using Liquid Tiberium"
ENT.Instructions	= "Link the Power Generator to the required resources and turn it on"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"RawTiberiumAmount")
	self:NetworkVar("Int",1,"LiquidsAmount")
	self:NetworkVar("Bool",0,"IsOnline")
	self:NetworkVar("Bool",1,"IsBoosting")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/tiberium/large_tiberium_reactor.mdl",
	PercentDelay = 0.6,
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

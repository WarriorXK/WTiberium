ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Warhead Factory"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "The warhead factory produces custom made warheads to use with the missiles"
ENT.Instructions	= "Place the warhead factory and link it up to all requires resources, then use the factory and create the warhead using the UI"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"EnergyAmount")
	self:NetworkVar("Int",1,"RawTiberiumAmount")
	self:NetworkVar("Int",2,"RefinedTiberiumAmount")
	self:NetworkVar("Int",3,"ChemicalsAmount")
	self:NetworkVar("Float",0,"LiquidAmount")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/tiberium/tiberium_warhead_factory.mdl",
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

list.Set("WTib_Tools_Generators", ENT.PrintName, { wtib_tool_generators_type = WTib.GetClass(ENT) })

ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Warhead Factory"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
	self:DTVar("Int",1,"Raw")
	self:DTVar("Int",2,"Refined")
	self:DTVar("Int",3,"Chemicals")
	self:DTVar("Float",0,"Liquid")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/tiberium_warhead_factory.mdl",
	PercentDelay = 0.08,
	Information =	{
						ENT.PrintName,
						"\nCreates warheads to enhance your rockets."
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

ENT.Type			= "anim"
ENT.Base			= "wtib_energycell_medium"
ENT.PrintName		= "Small Energy Cell"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/small_energy_cell.mdl",
	PercentDelay = 0.03,
	Information =	{
						ENT.PrintName,
						"\nStores up to 1000 units of Energy."
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

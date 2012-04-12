ENT.Type			= "anim"
ENT.PrintName		= "Missile"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.WTib_IsMissile	= true

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Energy")
	self:DTVar("Int",0,"Raw")
	self:DTVar("Int",0,"Refined")
	self:DTVar("Int",0,"Chemical")
	self:DTVar("Float",0,"Liquid")
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/tiberium_missile.mdl",
	PercentDelay = 0.02,
	Information =	{
						ENT.PrintName,
						"\nThis factory converts refined Tiberium into Tiberium chemicals."
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

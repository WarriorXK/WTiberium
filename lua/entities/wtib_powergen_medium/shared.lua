ENT.Type			= "anim"
ENT.Base			= "base_entity"
ENT.PrintName		= "Medium Powerplant"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= "Generates 300 Energy in exchange for 50 Raw Tiberium, can be boosted with 10 Liquid Tiberium for an extra 400 Energy units"
ENT.Instructions	= "Link the Power Generator to the required resources and turn it on"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "RawTiberiumAmount")
	self:NetworkVar("Int", 1, "LiquidTiberiumAmount")
	self:NetworkVar("Bool", 0, "IsOnline")
	self:NetworkVar("Bool", 1, "IsBoosting")
end

function ENT:GetLiquidTiberiumAmount() 
	return self:GetDTInt(1);
end

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/tiberium/medium_tiberium_reactor.mdl",
	PercentDelay = 0.4,
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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

--ENT.MaxHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you
--ENT.aHealth = 500 --NightReaper:this doesn't seem to work right now, so I commented it out for you

function ENT:Initialize()
	self:SetModel("models/Tiberium/small_tiberium_storage.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib_CreateOutputs(self,{"Tiberium","MaxTiberium"})
	WTib_AddResource(self,"Tiberium",1500)
	WTib_RegisterEnt(self,"Storage")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_smalltibstorage")
	e:SetPos(t.HitPos+t.HitNormal*26)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	self:SetNWInt("Tib",WTib_GetResourceAmount(self,"Tiberium"))
	WTib_TriggerOutput(self,"Tiberium",WTib_GetResourceAmount(self,"Tiberium"))
	WTib_TriggerOutput(self,"MaxTiberium",WTib_GetNetworkCapacity(self,"Tiberium"))
end

function ENT:OnRemove()
	WTib_RemoveRDEnt(self)
	if (self.Outputs or self.Inputs) then
		WTib_Remove(self)
	end
end

function ENT:OnRestore()
	WTib_Restored(self)
end

function ENT:PreEntityCopy()
	WTib_BuildDupeInfo(self)
	if WireAddon then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(ply,Ent,CreatedEntities)
	WTib_ApplyDupeInfo(Ent,CreatedEntities)
	if WireAddon and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(ply,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
	end
end

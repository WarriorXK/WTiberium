AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_wasteland/coolingtank01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.NextRefine = 0
	self.Inputs = Wire_CreateInputs(self,{"On"})
	self.Outputs = Wire_CreateOutputs(self,{"Online"})
	WTib_AddResource(self,"TiberiumChemicals",0)
	WTib_AddResource(self,"Tiberium",0)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_chemicalplant")
	e:SetPos(t.HitPos+t.HitNormal*100)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local a = 0
	local rand = math.Rand(200,400)
	if self.Active and WTib_GetResourceAmount(self,"energy") >= rand*1.5 then
		if WTib_GetResourceAmount(self,"Tiberium") >= rand then
			if self.NextRefine <= CurTime() then
				WTib_ConsumeResource(self,"Tiberium",rand)
				WTib_ConsumeResource(self,"energy",rand*1.5)
				WTib_SupplyResource(self,"TiberiumChemicals",rand/math.Rand(1.5,2))
				self:EmitSound("wtiberium/refinery/ref.wav",200,40)
				self.NextRefine = CurTime()+2
			end
			a = 1
		end
	else
		self:TurnOff()
	end
	Wire_TriggerOutput(self,"Online",a)
end

function ENT:Use(ply)
	if !ply or !ply:IsValid() or !ply:IsPlayer() then return end
	if self.Active then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

function ENT:TriggerInput(name,val)
	if name == "On" then
		if val == 0 then
			self:TurnOff()
		else
			self:TurnOn()
		end
	end
end

function ENT:TurnOff()
	self:StopSound("apc_engine_start")
	if self.Active then
		self:EmitSound("apc_engine_stop")
	end
	self.Active = false
end

function ENT:TurnOn()
	self:EmitSound("apc_engine_start")
	self.Active = true
end

function ENT:OnRemove()
	if WTib_IsRD3() then
		RD.RemoveRDEntity(self)
	elseif Dev_Unlink_All and self.resources2links then
		Dev_Unlink_All(self)
	end
	if WireAddon and (self.Outputs or self.Inputs) then
		Wire_Remove(self)
	end
end

function ENT:OnRestore()
	if WireAddon then
		Wire_Restored(self)
	end
end

function ENT:PreEntityCopy()
	WTib_BuildDupeInfo(self)
	if WireAddon != nil then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(ply,Ent,CreatedEntities)
	WTib_ApplyDupeInfo(Ent,CreatedEntities)
	if WireAddon != nil and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(ply,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
	end
end

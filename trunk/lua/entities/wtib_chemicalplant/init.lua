AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextRefine = 0

function ENT:Initialize()
	self:SetModel("models/Tiberium/chemical_plant.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib_CreateInputs(self,{"On"})
	self.Outputs = WTib_CreateOutputs(self,{"Online","Energy","TiberiumChemicals","Tiberium"})
	WTib_AddResource(self,"TiberiumChemicals",0)
	WTib_AddResource(self,"Tiberium",0)
	WTib_AddResource(self,"energy",0)
	WTib_RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	if !t.Hit then return end
	local e = ents.Create("wtib_chemicalplant")
	e:SetPos(t.HitPos+t.HitNormal*43)
	e.WDSO = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Think()
	local En = WTib_GetResourceAmount(self,"energy")
	local T = WTib_GetResourceAmount(self,"Tiberium")
	local a = 0
	local rand = math.Rand(200,400)
	if self:GetNWBool("Online",true) and En >= rand*1.5 then
		if T >= rand then
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
	self:SetNWInt("energy",En)
	self:SetNWInt("Tib",T)
	WTib_TriggerOutput(self,"Online",a)
	WTib_TriggerOutput(self,"Energy",En)
	WTib_TriggerOutput(self,"TiberiumChemicals",WTib_GetResourceAmount(self,"TiberiumChemicals"))
	WTib_TriggerOutput(self,"Tiberium",T)
end

function ENT:Use(ply)
	if !ply or !ply:IsValid() or !ply:IsPlayer() then return end
	if self:GetNWBool("Online",true) then
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
	if self:GetNWBool("Online",false) then
		self:EmitSound("apc_engine_stop")
	end
	self:SetNWBool("Online",false)
end

function ENT:TurnOn()
	self:EmitSound("apc_engine_start")
	self:SetNWBool("Online",true)
end

WTib_ApplyFunctionsSV(ENT)

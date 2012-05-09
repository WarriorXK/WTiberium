AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.MinAccelerationAmount	= 40
ENT.MaxAccelerationAmount	= 50
ENT.AccelerationDelay		= 5
ENT.MaxRange				= 512
ENT.MinRange				= 10

ENT.EffectOrigin = Vector(0,0,32)
ENT.Scale = 2

ENT.NextCheck = 0

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_growth_accelerator.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"On","SetRange"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Range","MaxRange","Energy"})
	WTib.AddResource(self,"energy",0)
	WTib.RegisterEnt(self,"Generator")
	self:SetRange(self.MaxRange)
	WTib.TriggerOutput(self,"MaxRange",self.MaxRange)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	local Energy = WTib.GetResourceAmount(self,"energy")
	if self.NextCheck <= CurTime() and self.dt.Online then
		local TotalAdded = 0
		local Ents = {}
		for _,v in pairs(ents.FindInSphere(self:GetPos(),self:GetRange())) do
			if WTib.IsValid(v) then
				if v.IsTiberium then
					local Add = math.random(self.MinAccelerationAmount, self.MaxAccelerationAmount)
					TotalAdded = TotalAdded + Add
					Ents[v] = Add
				elseif v:IsPlayer() or v:IsNPC() then
					if math.random(0,2) == 1 then WTib.Infect(v) end
				end
			end
		end
		local Drain = ((TotalAdded / 4) + (self:GetRange() / 2)) / 2
		if Energy >= Drain then
			for k,v in pairs(Ents) do
				k:AddTiberiumAmount(v)
			end
			WTib.ConsumeResource(self,"energy",Drain)
			
			local ed = EffectData()
				ed:SetEntity(self)
				ed:SetOrigin(self.EffectOrigin)
				ed:SetScale(self.Scale)
				ed:SetMagnitude(self:GetRange())
			util.Effect("wtib_growthaccelerator_pulse", ed)
		else
			self:TurnOff()
		end
		self.NextCheck = CurTime()+self.AccelerationDelay
	end
	Energy = WTib.GetResourceAmount(self,"energy")
	
	WTib.TriggerOutput(self,"Energy",Energy)
	self.dt.Energy = Energy
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:Use(ply)
	if self.dt.Online then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

function ENT:TurnOn()
	if WTib.GetResourceAmount(self,"energy") <= 1 then return end
	if !self.dt.Online then
		self:EmitSound("apc_engine_start")
	end
	self.dt.Online = true
	WTib.TriggerOutput(self,"Online",1)
end

function ENT:OnRemove()
	self:TurnOff()
end

function ENT:TurnOff()
	self:StopSound("apc_engine_start")
	if self.dt.Online then
		self:EmitSound("apc_engine_stop")
	end
	self.dt.Online = false
	WTib.TriggerOutput(self,"Online",0)
end

function ENT:TriggerInput(name,val)
	if name == "On" then
		if val == 0 then
			self:TurnOff()
		else
			self:TurnOn()
		end
	elseif name == "SetRange" then
		self:SetRange(val)
	end
end

function ENT:SetRange(int)
	self.dt.Range = math.Clamp(int,self.MinRange,self.MaxRange)
	WTib.TriggerOutput(self,"Range", int)
end

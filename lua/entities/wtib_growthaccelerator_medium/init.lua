AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.AccelerationLevel	= 1.75
ENT.MaxRange			= 350
ENT.MinRange			= 10

ENT.AcceleratedEnts = {}
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
	return WTib.SpawnFunction(p,t,23,self)
end

function ENT:Think()
	local Energy = WTib.GetResourceAmount(self,"energy")
	if self.NextCheck <= CurTime() and self.dt.Online then
		local Ents = {}
		for _,v in pairs(ents.FindInSphere(self:GetPos(),self:GetRange())) do
			if ValidEntity(v) and v.IsTiberium then
				table.insert(Ents,v)
			end
		end
		for k,v in pairs(self.AcceleratedEnts) do
			if !table.HasValue(Ents,v) then
				if ValidEntity(v) then
					v:SetAcceleration(1)
				end
				self.AcceleratedEnts[k] = nil
			end
		end
		self.AcceleratedEnts = Ents
		local Drain = (table.Count(Ents)*(self:GetRange()/(20+self.AccelerationLevel)))*2
		if Energy >= Drain then
			for _,v in pairs(Ents) do
				v:SetAcceleration(self.AccelerationLevel)
			end
			WTib.ConsumeResource(self,"energy",Drain)
		else
			self:TurnOff()
		end
		self.NextCheck = CurTime()+2
	end
	Energy = WTib.GetResourceAmount(self,"energy")
	RefinedTiberium = WTib.GetResourceAmount(self,"RefinedTiberium")
	WTib.TriggerOutput(self,"Range",self:GetRange())
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
end

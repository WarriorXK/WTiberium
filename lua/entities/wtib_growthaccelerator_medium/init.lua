AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.MinAccelerationAmount	= 40
ENT.MaxAccelerationAmount	= 50
ENT.AccelerationDelay		= 5
ENT.InfectionChance			= 5
ENT.MaxRange				= 512
ENT.MinRange				= 10

ENT.EffectOrigin = Vector(0,0,32)
ENT.Scale = 2

ENT.NextCheck = 0

function ENT:Initialize()

	self:SetModel("models/tiberium/acc_m.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:CommonInit()
	
end

function ENT:CommonInit()

	self.Inputs = WTib.CreateInputs(self,{"On","SetRange"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Range","MaxRange","Energy"})
	WTib.TriggerOutput(self,"MaxRange",self.MaxRange)
	
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"energy",0)
	
	self:SetRange(self.MaxRange)
	WTib.TriggerOutput(self,"Range", self.MaxRange)

end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	local Energy = WTib.GetResourceAmount(self,"energy")
	
	if self.NextCheck <= CurTime() and self:GetIsOnline() then
	
		local TotalAdded = 0
		local Ents = {}
		
		for _,v in pairs(ents.FindInSphere(self:GetPos(),self:GetRange())) do
		
			if WTib.IsValid(v) then
			
				if v.IsTiberium then
				
					local Add = math.random(self.MinAccelerationAmount, self.MaxAccelerationAmount)
					TotalAdded = TotalAdded + Add
					Ents[v] = Add
					
				elseif (v:IsPlayer() and v:Armor() <= 0) or v:IsNPC() then
				
					if math.random(1, self.InfectionChance) == 1 then WTib.Infect(v, self, self, 1, 3, false) end
					
				end
				
			end
			
		end
		
		local Drain = ((TotalAdded / 4) + (self:GetRange() / 2)) / 2
		if Energy >= Drain then
		
			for k,v in pairs(Ents) do
				k:AddTiberiumAmount(v)
			end
			
			WTib.ConsumeResource(self,"energy",Drain)
			Energy = Energy - Drain
			
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

	WTib.TriggerOutput(self,"Energy", Energy)
	
	self:SetEnergyAmount(Energy)
	
	self:NextThink(CurTime()+0.2)
	return true
	
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:Use(ply)

	if self:GetIsOnline() then
		self:TurnOff()
	else
		self:TurnOn()
	end
	
end

function ENT:TurnOn()

	if WTib.GetResourceAmount(self,"energy") <= 1 then return end
	
	if !self:GetIsOnline() then
		self:EmitSound("apc_engine_start")
	end
	
	self:SetIsOnline(true)
	WTib.TriggerOutput(self,"Online",1)
	
end

function ENT:OnRemove()
	self:TurnOff()
end

function ENT:TurnOff()

	self:StopSound("apc_engine_start")
	
	if self:GetIsOnline() then
		self:EmitSound("apc_engine_stop")
	end
	
	self:SetIsOnline(false)
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
		WTib.TriggerOutput(self,"Range", self:GetRange())
		
	end
	
end

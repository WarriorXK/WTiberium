AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.ChemRequired = 50
ENT.EnergySupply = 300

ENT.NextSupply = 0

function ENT:Initialize()

	self:SetModel("models/Tiberium/medium_tiberium_reactor.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Inputs = WTib.CreateInputs(self,{"On","Boost"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Chemicals","Boosting"})
	
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"ChemicalTiberium",0)
	WTib.AddResource(self,"LiquidTiberium",0)
	WTib.AddResource(self,"energy",0)
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	local Chemicals = WTib.GetResourceAmount(self,"ChemicalTiberium")
	
	if self:GetIsOnline() and self.NextSupply <= CurTime() then
	
		if Chemicals >= self.ChemRequired then
		
			WTib.ConsumeResource(self,"ChemicalTiberium", self.ChemRequired)
			WTib.SupplyResource(self,"energy", self.EnergySupply)
			
			Chemicals = Chemicals - self.ChemRequired
			
			if self:GetIsBoosting() and WTib.GetResourceAmount(self,"LiquidTiberium") >= 10 then
			
				WTib.SupplyResource(self, "energy", self.EnergySupply * 1.4)
				WTib.ConsumeResource(self,"LiquidTiberium", 10)
				
			end
			
		else
		
			self:TurnOff()
			
		end
		
		self.NextSupply = CurTime()+1
		
	end
	
	WTib.TriggerOutput(self,"Chemicals", Chemicals)
	WTib.TriggerOutput(self,"Boosting", self:GetIsBoosting() and 1 or 0)
	
	self:SetChemicalsAmount(Chemicals)
	
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
		
	elseif name == "Boost" then
	
		self:SetIsBoosting(tobool(val))
		
	end
	
end

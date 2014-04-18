AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.RawTiberiumRequired = 50
ENT.LiquidBoostRequired = 10
ENT.EnergyBoostSupply = 400
ENT.EnergySupply = 300

ENT.NextSupply = 0

function ENT:Initialize()

	self:SetModel("models/tiberium/medium_tiberium_reactor.mdl")
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

	self.Inputs = WTib.CreateInputs(self,{"On","Boost"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Raw Tiberium","Liquid Tiberium","Boosting"})
	
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"RawTiberium",0)
	WTib.AddResource(self,"LiquidTiberium",0)
	WTib.AddResource(self,"energy",0)

end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	local RawTiberium = WTib.GetResourceAmount(self,"RawTiberium")
	local Liquids = WTib.GetResourceAmount(self,"LiquidTiberium")
	
	if self:GetIsOnline() and self.NextSupply <= CurTime() then
	
		if RawTiberium >= self.RawTiberiumRequired then
		
			WTib.ConsumeResource(self,"ChemicalTiberium", self.RawTiberiumRequired)
			local EnergyToSupply = self.EnergySupply
			
			RawTiberium = RawTiberium - self.RawTiberiumRequired
			
			if self:GetIsBoosting() and Liquids >= 10 then
			
				WTib.ConsumeResource(self,"LiquidTiberium", self.LiquidBoostRequired)
				EnergyToSupply = EnergyToSupply + self.EnergyBoostSupply
				
				Liquids = Liquids - self.LiquidBoostRequired
				
			end
			
			WTib.SupplyResource(self,"energy", EnergyToSupply)
			
		else
		
			self:TurnOff()
			
		end
		
		self.NextSupply = CurTime()+1
		
	end
	
	WTib.TriggerOutput(self,"Raw Tiberium", RawTiberium)
	WTib.TriggerOutput(self,"Liquid Tiberium", Liquids)
	WTib.TriggerOutput(self,"Boosting", self:GetIsBoosting() and 1 or 0)
	
	self:SetRawTiberiumAmount(RawTiberium)
	// Why?
	if type(self.SetLiquidTiberiumAmount) == "function" then self:SetLiquidTiberiumAmount(Liquids) else ErrorNoHalt("Invalid SetLiquidAmount on PowerGen : '" .. type(self.SetLiquidTiberiumAmount) .. "'") end
	
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

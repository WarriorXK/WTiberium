AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.NextChemical = 0

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
	
	self.Inputs = WTib.CreateInputs(self,{"On"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy","ChemicalTiberium","RefinedTiberium"})
	
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"ChemicalTiberium",0)
	WTib.AddResource(self,"RefinedTiberium",0)
	WTib.AddResource(self,"energy",0)
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	local Energy = WTib.GetResourceAmount(self,"energy")
	local RefinedTiberium = WTib.GetResourceAmount(self,"RefinedTiberium")
	
	if self.NextChemical <= CurTime() and self:GetIsOnline() then
	
		local Supply = math.Clamp(RefinedTiberium,0,100)
		local EDrain = math.ceil(Supply/2)
		
		if Supply > 0 and RefinedTiberium >= Supply*1.5 and Energy >= EDrain then
		
			WTib.ConsumeResource(self,"energy",EDrain)
			WTib.ConsumeResource(self,"RefinedTiberium", Supply * 1.5)
			WTib.SupplyResource(self,"ChemicalTiberium",Supply)
			
			Energy = Energy - EDrain
			RefinedTiberium = RefinedTiberium - (Supply * 1.5)
			
		else
		
			self:TurnOff()
			
		end
		
		self.NextChemical = CurTime()+1
		
	end
	
	WTib.TriggerOutput(self,"Energy",Energy)
	WTib.TriggerOutput(self,"ChemicalTiberium",WTib.GetResourceAmount(self,"ChemicalTiberium"))
	WTib.TriggerOutput(self,"RefinedTiberium",RefinedTiberium)
	
	self:SetEnergyAmount(Energy)
	self:SetRefinedTiberiumAmount(RefinedTiberium)
	
	self:NextThink(CurTime()+0.5)
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
		
	end
	
end

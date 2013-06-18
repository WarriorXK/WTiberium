AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.HarvestParents = false
ENT.MaxDrain = 200
ENT.Range = 200

ENT.NextHarvest = 0

function ENT:Initialize()

	self:SetModel("models/Tiberium/medium_harvester.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Inputs = WTib.CreateInputs(self,{"On", "HarvestParents"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy","RawTiberium"})
	
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"RawTiberium",0)
	WTib.AddResource(self,"energy",0)
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Harvest()

	local SPos = self:GetPos()
	
	for _,v in pairs(ents.FindInCone(self:GetPos(),self:GetUp(),self.Range,10)) do
	
		if v.IsTiberium then
		
			local Drain = math.min(v:GetTiberiumAmount(),self.MaxDrain)
			local Mul = 1.2
			if v.IsTiberiumParent then Mul = 1.5 end
			
			if WTib.GetResourceAmount(self,"energy") > Drain*Mul then
			
				if (v.IsTiberiumParent and v.HarvestParents) or !v.IsTiberiumParent then

					WTib.ConsumeResource(self,"energy",Drain*1.2)
					WTib.SupplyResource(self,"RawTiberium",Drain)
					v:SetTiberiumAmount(v:GetTiberiumAmount()-Drain)
					
				end
				
			else
			
				self:TurnOff()
				break
				
			end
		end
		
	end
	
end

function ENT:Think()

	if self.NextHarvest <= CurTime() and self:GetIsOnline() then
	
		if WTib.GetResourceAmount(self,"energy") < 10 then
		
			self:TurnOff()
			
		else
		
			WTib.ConsumeResource(self,"energy",10)
			
			self:Harvest()
			self.NextHarvest = CurTime()+1
		
		end

	end
	
	local Energy = WTib.GetResourceAmount(self,"energy")
	
	WTib.TriggerOutput(self,"Energy",Energy)
	WTib.TriggerOutput(self,"RawTiberium", WTib.GetResourceAmount(self,"RawTiberium"))
	
	self:SetEnergyAmount(Energy)
	
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

	if WTib.GetResourceAmount(self,"energy") <= 10 then return end
	
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
		
	elseif name == "HarvestParents" then
	
		self.HarvestParents = tobool(val)
		
	end
	
end

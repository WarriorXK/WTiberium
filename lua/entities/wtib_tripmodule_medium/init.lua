AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.MaxCount = 5
ENT.MaxMul = 10
ENT.MinMul = 5

function ENT:Initialize()

	self:SetModel("models/tiberium/medium_trip.mdl")
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

	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy"})
	
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"energy",0)

end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	local Count = 0
	local EnergyToAdd = 0

	for _,v in pairs(ents.FindInSphere(self:GetPos()+(self:GetForward()*(626)),625)) do

		if v.IsTiberium then
			if v.IsTiberiumParent then
				EnergyToAdd = EnergyToAdd + 3
			else
				EnergyToAdd = EnergyToAdd + 1
			end
			
			Count = Count+1
			if Count >= self.MaxCount then break end
			
		end
		
	end
	
	if EnergyToAdd > 0 then WTib.SupplyResource(self,"energy",EnergyToAdd*math.Rand(self.MinMul,self.MaxMul)) end
	
	local Energy = WTib.GetResourceAmount(self,"energy")
	
	self:SetIsOnline(Count >= 1)
	self:SetEnergyAmount(Energy)
	
	WTib.TriggerOutput(self,"Online", self:GetIsOnline() and 1 or 0)
	WTib.TriggerOutput(self,"Energy", Energy)
	
	self:NextThink(CurTime()+1)	
	return true
end

function ENT:OnRestore()
	WTib.Restored(self)
end

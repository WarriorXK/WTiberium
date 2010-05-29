AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.MaxCount = 5
ENT.MaxMul = 10
ENT.MinMul = 5

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_trip.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy"})
	WTib.AddResource(self,"energy",0)
	WTib.RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,16,self)
end

function ENT:Think()
	local Count = 0
	for _,v in pairs(ents.FindInCone(self:GetPos(),self:GetForward(),625,25)) do
		if v.IsTiberium then
			Count = Count+1
			if Count >= self.MaxCount then break end
		end
	end
	self.dt.Online = Count >= 1
	self.dt.Energy = WTib.GetResourceAmount(self,"energy")
	WTib.TriggerOutput(self,"Online",tonumber(self.dt.Online))
	WTib.TriggerOutput(self,"Energy",self.dt.Energy)
	WTib.SupplyResource(self,"energy",Count*math.Rand(self.MinMul,self.MaxMul))
	self:NextThink(CurTime()+1)
	return true
end

function ENT:OnRestore()
	WTib.Restored(self)
end

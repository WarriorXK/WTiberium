AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.Range = 20000

function ENT:Initialize()
	self:SetModel("models/Tiberium/large_tiberium_radar.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"On","Range","ParentOnly"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy","Found","GlobalX","GlobalY","GlobalZ","LocalX","LocalY","LocalZ"})
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"energy",0)
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

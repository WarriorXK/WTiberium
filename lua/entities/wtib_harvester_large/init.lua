AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")

ENT.MaxDrain = 400
ENT.Range = 400

function ENT:Initialize()

	self:SetModel("models/tiberium/large_harvester.mdl")
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

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

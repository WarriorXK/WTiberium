AddCSLuaFile("cl_init.lua")
AddCSLuaFile("menu.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("wtib_warheadfactory_openmenu")
util.AddNetworkString("wtib_warheadfactory_buildwarhead")

WTib.ApplyDupeFunctions(ENT)

ENT.LastErrorSound = 0
ENT.NextBuild = 0

// Percentages drained
ENT.Raw = 25
ENT.Refined = 25
ENT.Chemicals = 25
ENT.Liquid = 25

local Total = 1000 // The total amount of resources drained

local SpawnPos = Vector(27, 20, -8)

local SuccessSound = Sound("buttons/button14.wav")
local ErrorSound = Sound("buttons/button8.wav")

local ErrorSoundDelay = SoundDuration(ErrorSound)

/*
	Error Codes :
		0 - No error
		1 - Requires more resources
		2 - Device is still in cooldown
		3 - Total percentage does not equal 100
*/

function ENT:Initialize()

	self:SetModel("models/Tiberium/tiberium_warhead_factory.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Inputs = WTib.CreateInputs(self,{"Build", "Raw", "Refined", "Chemicals", "Liquid"})
	self.Outputs = WTib.CreateOutputs(self,{"Can Build", "Error Code"})
	
	WTib.TriggerOutput(self, "Error Code", 0)
	
	WTib.RegisterEnt(self, "Generator")
	
	WTib.AddResource(self, "energy", 0)
	WTib.AddResource(self, "RawTiberium", 0)
	WTib.AddResource(self, "RefinedTiberium", 0)
	WTib.AddResource(self, "ChemicalTiberium", 0)
	WTib.AddResource(self, "LiquidTiberium", 0)
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	self.dt.Energy = WTib.GetResourceAmount(self, "energy")
	self.dt.Raw = WTib.GetResourceAmount(self, "RawTiberium")
	self.dt.Refined = WTib.GetResourceAmount(self, "RefinedTiberium")
	self.dt.Chemicals = WTib.GetResourceAmount(self, "ChemicalTiberium")
	self.dt.Liquid = WTib.GetResourceAmount(self, "LiquidTiberium")
	
	local CBuild = 0
	if self:CanBuild() then CBuild = 1 end
	
	WTib.TriggerOutput(self, "Can Build", CBuild)
	
end

function ENT:Use(ply)

	net.Start("wtib_warheadfactory_openmenu")
		net.WriteEntity(self)
	net.Send(ply)

end

function ENT:CanBuild()

	local OnePercent = Total / 100

	return 	(self.NextBuild < CurTime() and
			(WTib.GetResourceAmount(self, "energy") >= Total) and
			(WTib.GetResourceAmount(self, "RawTiberium") >= (OnePercent * self.Raw)) and
			(WTib.GetResourceAmount(self, "RefinedTiberium") >= (OnePercent * self.Refined)) and
			(WTib.GetResourceAmount(self, "ChemicalTiberium") >= (OnePercent * self.Chemicals)) and
			(WTib.GetResourceAmount(self, "LiquidTiberium") >= (OnePercent * self.Liquid)))
end

function ENT:BuildWarhead()

	if self:CanBuild() then
	
		local Tot = math.Round(self.Raw + self.Refined + self.Chemicals + self.Liquid)
		if Tot == 100 then // The total percentage is 100

			local OnePercent = Total / 100
		
			WTib.ConsumeResource(self, "energy", Total)
			WTib.ConsumeResource(self, "RawTiberium", (OnePercent * self.Raw))
			WTib.ConsumeResource(self, "RefinedTiberium", (OnePercent * self.Refined))
			WTib.ConsumeResource(self, "ChemicalTiberium", (OnePercent * self.Chemicals))
			WTib.ConsumeResource(self, "LiquidTiberium", (OnePercent * self.Liquid))

			local ent = ents.Create("wtib_missile_warhead")
			ent:SetAngles( self:GetAngles() )
			ent:SetPos( self:LocalToWorld(SpawnPos) )
			ent:Spawn()
			ent:Activate()
			ent:SetWarheadValues(self.Energy, self.Raw, self.Refined, self.Chemicals, self.Liquid)
			
			self:EmitSound(SuccessSound)
			self.NextBuild = CurTime()+1
			
			WTib.TriggerOutput(self, "Error Code", 0)

		else
			WTib.TriggerOutput(self, "Error Code", 3)
			self:EmitSound(ErrorSound)
		end
		
	elseif self.LastErrorSound < CurTime() then
	
		self:EmitSound(ErrorSound)
		self.LastErrorSound = CurTime() + ErrorSoundDelay
		
		if self.NextBuild < CurTime() then
			WTib.TriggerOutput(self, "Error Code", 2)
		else
			WTib.TriggerOutput(self, "Error Code", 1)
		end
		
	end
	
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:TriggerInput(name,val)

	val = val >= 0 and math.Round(val) or 0

	if name == "Build" then
		if tobool(val) then
			self:BuildWarhead()
		end
	elseif name == "Raw" then
		self.Raw = tonumber(val)
	elseif name == "Refined" then
		self.Refined = tonumber(val)
	elseif name == "Chemicals" then
		self.Chemicals = tonumber(val)
	elseif name == "Liquid" then
		self.Liquid = tonumber(val)
	end
	
end

net.Receive( "wtib_warheadfactory_buildwarhead", function( len, ply )
	
	local ent = net.ReadEntity()
	
	local Raw = net.ReadFloat()
	local Refined = net.ReadFloat()
	local Chemicals = net.ReadFloat()
	local Liquid = net.ReadFloat()

	if WTib.IsValid(ent) then
		
		ent.Raw = Raw
		ent.Refined = Refined
		ent.Chemicals = Chemicals
		ent.Liquid = Liquid
		
		ent:BuildWarhead()

	end
	
end)

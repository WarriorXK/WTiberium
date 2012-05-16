AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.LastErrorSound = 0
ENT.NextBuild = 0

local Total = 1000 // The total amount of resources drained

// Percentages drained
ENT.Raw = 25
ENT.Refined = 25
ENT.Chemicals = 25
ENT.Liquid = 25

local SpawnPos = Vector(27, 20, -8)

local SuccessSound = Sound("buttons/button14.wav")
local ErrorSound = Sound("buttons/button8.wav")

local ErrorSoundDelay = SoundDuration(ErrorSound)

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
	self.Outputs = WTib.CreateOutputs(self,{"Can Build"})
	
	WTib.AddResource(self, "energy", 0)
	WTib.AddResource(self, "RawTiberium", 0)
	WTib.AddResource(self, "RefinedTiberium", 0)
	WTib.AddResource(self, "ChemicalTiberium", 0)
	WTib.AddResource(self, "LiquidTiberium", 0)
	WTib.RegisterEnt(self, "Generator")
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
end

function ENT:CanBuild()
	return self.NextBuild < CurTime()
end

function ENT:BuildWarhead()

	local Energy = WTib.GetResourceAmount(self, "energy")
	local RawTiberium = WTib.GetResourceAmount(self, "RawTiberium")
	local RefinedTiberium = WTib.GetResourceAmount(self, "RefinedTiberium")
	local ChemicalTiberium = WTib.GetResourceAmount(self, "ChemicalTiberium")
	local LiquidTiberium = WTib.GetResourceAmount(self, "LiquidTiberium")
	
	if self:CanBuild() then
		local Tot = math.Round(self.Raw + self.Refined + self.Chemicals + self.Liquid)
		if Tot == 100 then // The total percentage is 100
			
			local OnePercent = Total / 100
			
			local RawDrain = (OnePercent * self.Raw)
			local RefinedDrain = (OnePercent * self.Refined)
			local LiquidDrain = (OnePercent * self.Liquid)
			local ChemicalDrain = (OnePercent * self.Chemicals)
			
			if (RawTiberium >= RawDrain and RefinedTiberium >= RefinedDrain and ChemicalTiberium >= ChemicalDrain and LiquidTiberium >= LiquidDrain and Energy >= Total) then
	
				WTib.ConsumeResource(self,"energy", Total)
				WTib.ConsumeResource(self,"RawTiberium", RawDrain)
				WTib.ConsumeResource(self,"RefinedTiberium", RefinedDrain)
				WTib.ConsumeResource(self,"ChemicalTiberium", ChemicalDrain)
				WTib.ConsumeResource(self,"LiquidTiberium", LiquidDrain)

				local ent = ents.Create("wtib_missile_warhead")
				ent:SetAngles( self:GetAngles() )
				ent:SetPos( self:LocalToWorld(SpawnPos) )
				ent:Spawn()
				ent:Activate()
				ent:SetWarheadValues(self.Energy, self.Raw, self.Refined, self.Chemicals, self.Liquid)
				
				self:EmitSound(SuccessSound)
				self.NextBuild = CurTime()+1
			
			else
				
				print("Not enough resources :")
				print("\tEnergy :" .. Energy .. "/" .. Total)
				print("\tRaw :" .. RawTiberium .. "/" .. RawDrain)
				print("\tRefined :" .. RefinedTiberium .. "/" .. RefinedDrain)
				print("\tChemical :" .. ChemicalTiberium .. "/" .. ChemicalDrain)
				print("\tLiquid :" .. LiquidTiberium .. "/" .. ChemicalDrain)
				
				self:EmitSound(ErrorSound)
				
			end
			
		else
			
			print("Total is not 100 but (" .. Tot .. ") :")
			print("\tRaw : " .. self.Raw)
			print("\tRefined : " .. self.Refined)
			print("\tChemicals : " .. self.Chemicals)
			print("\tLiquid : " .. self.Liquid)
			
			self:EmitSound(ErrorSound)
			
		end
		
	elseif self.LastErrorSound < CurTime() then
		self:EmitSound(ErrorSound)
		self.LastErrorSound = CurTime()+ErrorSoundDelay
	end
	
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:TriggerInput(name,val)
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

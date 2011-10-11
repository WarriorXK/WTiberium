AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.Range = 10000

function ENT:Initialize()
	self:SetModel("models/Tiberium/medium_tiberium_radar.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"On","Range","ParentOnly"})
	self.Outputs = WTib.CreateOutputs(self,{"Online","Energy","Found","GlobalX","GlobalY","GlobalZ","LocalX","LocalY","LocalZ"})
	WTib.AddResource(self,"energy",0)
	WTib.RegisterEnt(self,"Generator")
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	self.dt.Energy = WTib.GetResourceAmount(self,"energy")
	local Target
	if self.dt.Online then
		local Amount = math.ceil(self.Range/50)
		if self.dt.Energy >= Amount then
			WTib.ConsumeResource("energy",Amount)
			if !WTib.IsValid(self.Target) then
				local Range = math.huge
				for _,v in pairs(ents.FindInSphere(self:GetPos(),self.Range)) do
					if v.IsTiberium then
						if self.ParentOnly then
							if v.IsParentCrystal then
								if self:GetPos():Distance(v:GetPos()) < Range then
									Target = v
								end
							end
						else
							if !v.IsParentCrystal then
								if self:GetPos():Distance(v:GetPos()) < Range then
									Target = v
								end
							end
						end
					end
				end
			else
				Target = self.Target
			end
		else
			self.dt.Online = false
		end
	end
	self:TriggerOutputs(Target)
	self.dt.HasTarget = self.dt.Online and WTib.IsValid(self.Target)
end

function ENT:TriggerOutputs(ent)
	if WTib.IsValid(ent) then
		local GPos = ent:GetPos()
		WTib.TriggerOutput(self,"GlobalX",GPos.x)
		WTib.TriggerOutput(self,"GlobalY",GPos.y)
		WTib.TriggerOutput(self,"GlobalZ",GPos.z)
		local LPos = self:WorldToLocal(GPos)
		WTib.TriggerOutput(self,"LocalX",LPos.x)
		WTib.TriggerOutput(self,"LocalY",LPos.y)
		WTib.TriggerOutput(self,"LocalZ",LPos.z)
		self.Target = ent
	else
		WTib.TriggerOutput(self,"GlobalX",0)
		WTib.TriggerOutput(self,"GlobalY",0)
		WTib.TriggerOutput(self,"GlobalZ",0)
		WTib.TriggerOutput(self,"LocalX",0)
		WTib.TriggerOutput(self,"LocalY",0)
		WTib.TriggerOutput(self,"LocalZ",0)
		self.Target = nil
	end
end

function ENT:TriggerInput(name,val)
	if name == "On" then
		self.dt.Online = tobool(val)
	elseif name == "Range" then
		self.Range = tostring(val)
	elseif name == "ParentsOnly" then
		self.ParentOnly = tobool(val)
	end
end

function ENT:OnRestore()
	WTib.Restored(self)
end

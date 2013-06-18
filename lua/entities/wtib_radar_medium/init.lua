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
	
	WTib.RegisterEnt(self,"Generator")
	WTib.AddResource(self,"energy",0)
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	local Energy = WTib.GetResourceAmount(self,"energy")
	local Target
	
	if self:GetIsOnline() then
	
		local Amount = math.ceil(self.Range/50)
		
		if Energy >= Amount then
		
			WTib.ConsumeResource(self, "energy",Amount)
			Energy = Energy - Amount
			
			if !WTib.IsValid(self.Target) then
			
				local Range = math.huge
				
				for _,v in pairs(ents.FindInSphere(self:GetPos(),self.Range)) do
				
					if v.IsTiberium then
					
						if self.ParentOnly then
						
							if v.IsTiberiumParent then
							
								if self:GetPos():Distance(v:GetPos()) < Range then
								
									Target = v
									
								end
								
							end
							
						else
						
							if !v.IsTiberiumParent then
							
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
		
			self:SetIsOnline(false)
			
		end
	end
	
	WTib.TriggerOutput(self,"Online",self:GetIsOnline() and 1 or 0)
	WTib.TriggerOutput(self,"Energy",Energy)
	
	self:TriggerOutputs(Target)
	self:SetHasTarget(self:GetIsOnline() and WTib.IsValid(self.Target))
	self:SetEnergyAmount(Energy)
	
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
		
		WTib.TriggerOutput(self,"Found",1)
		
		self.Target = ent
		
	else
	
		WTib.TriggerOutput(self,"GlobalX",0)
		WTib.TriggerOutput(self,"GlobalY",0)
		WTib.TriggerOutput(self,"GlobalZ",0)
		
		WTib.TriggerOutput(self,"LocalX",0)
		WTib.TriggerOutput(self,"LocalY",0)
		WTib.TriggerOutput(self,"LocalZ",0)
		
		WTib.TriggerOutput(self,"Found",0)
		
		self.Target = nil
		
	end
end

function ENT:TriggerInput(name,val)

	if name == "On" then
		self:SetIsOnline(tobool(val))
	elseif name == "Range" then
		self.Range = tostring(val)
	elseif name == "ParentsOnly" then
		self.ParentOnly = tobool(val)
	end
	
end

function ENT:OnRestore()
	WTib.Restored(self)
end

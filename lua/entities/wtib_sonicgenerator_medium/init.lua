AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.NextDrain = 0
ENT.MaxRange = 1000

function ENT:Initialize()

	self:SetModel("models/tiberium/sonic_field_emitter.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Inputs = WTib.CreateInputs( self, { "On", "Range" } )
	self.Outputs = WTib.CreateOutputs( self, { "Online", "Current Range", "Energy" } )
	
	WTib.RegisterEnt( self, "Generator" )
	WTib.AddResource( self, "energy", 0)
	
	self.dt.Range = self.MaxRange / 2
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	local Energy = WTib.GetResourceAmount(self,"energy")
	
	if self.NextDrain <= CurTime() and self.dt.Online then
	
		local EDrain = math.ceil( self.dt.Range * math.Rand(0.9, 1.1) )
		
		if Energy >= EDrain then
		
			WTib.ConsumeResource( self, "energy", EDrain )
			
			Energy = Energy - EDrain
			
		else
		
			self:TurnOff()
			
		end
		
		self.NextDrain = CurTime()+1
		
	end
	
	WTib.TriggerOutput( self, "Energy", Energy )
	WTib.TriggerOutput( self, "Current Range", self.dt.Range )
	
	self:NextThink(CurTime()+0.5)
	return true
	
end

function ENT:PreventCrystalSpawn( pos, class )

	local Energy = WTib.GetResourceAmount( self, "energy" )
	
	if self.dt.Online and Energy >= 20 then

		local zap = ents.Create("point_tesla")
		zap:SetKeyValue("targetname", "teslab")
		zap:SetKeyValue("m_SoundName" ,"DoSpark")
		zap:SetKeyValue("texture" ,"sprites/physbeam.spr")
		zap:SetKeyValue("m_Color" ,"200 200 255")
		zap:SetKeyValue("m_flRadius" , "50")
		zap:SetKeyValue("beamcount_min" ,"5")
		zap:SetKeyValue("beamcount_max", "15")
		zap:SetKeyValue("thick_min", "40")
		zap:SetKeyValue("thick_max", "80")
		zap:SetKeyValue("lifetime_min" ,"0.1")
		zap:SetKeyValue("lifetime_max", "0.2")
		zap:SetKeyValue("interval_min", "0.05")
		zap:SetKeyValue("interval_max" ,"0.08")
		zap:SetPos(pos)
		zap:Spawn()
		zap:Fire("DoSpark","",0)
		zap:Fire("kill","", 1)
	
		WTib.ConsumeResource( self, "energy", 20 )
		
		WTib.TriggerOutput( self, "Energy", Energy - 20 )	
		return true
		
	else
	
		WTib.TriggerOutput( self, "Energy", Energy )
		return false
	
	end

end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:Use(ply)

	if self.dt.Online then
	
		self:TurnOff()
		
	else
	
		self:TurnOn()
		
	end
	
end

function ENT:TurnOn()

	if WTib.GetResourceAmount( self, "energy" ) <= math.ceil( self.dt.Range * 0.9 ) then return end
	
	if !self.dt.Online then
		self:EmitSound( "apc_engine_start" )
	end
	
	self.dt.Online = true
	WTib.TriggerOutput( self, "Online", 1 )
	
end

function ENT:OnRemove()
	self:TurnOff()
end

function ENT:TurnOff()

	self:StopSound( "apc_engine_start" )
	
	if self.dt.Online then
		self:EmitSound( "apc_engine_stop" )
	end
	
	self.dt.Online = false
	WTib.TriggerOutput( self, "Online", 0 )
	
end

function ENT:TriggerInput(name,val)

	if name == "On" then
	
		if val == 0 then
		
			self:TurnOff()
			
		else
		
			self:TurnOn()
			
		end

	elseif name == "Range" then
	
		self.dt.Range = math.Clamp(val, 100, self.MaxRange)
		
	end
	
end

function WTib_SonicGenerator_TiberiumCanGrow(class, pos)
	
	for _,v in pairs(ents.FindByClass("wtib_sonicgenerator_*")) do
	
		if pos:Distance(v:GetPos()) <= v.dt.Range then
			
			if v:PreventCrystalSpawn(pos, class) then
			
				return false
				
			end
			
		end
	
	end
	
end
hook.Add("WTib_TiberiumCanGrow", "WTib_SonicGenerator_TiberiumCanGrow", WTib_SonicGenerator_TiberiumCanGrow)

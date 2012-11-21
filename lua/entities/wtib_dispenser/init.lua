AddCSLuaFile("cl_init.lua")
AddCSLuaFile("menu.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("wtib_dispenser_buildobject")
util.AddNetworkString("wtib_dispenser_openmenu")

WTib.ApplyDupeFunctions(ENT)

ENT.LastErrorSound = 0
ENT.LastBuild = 0

local NewObjectPos = Vector(7,14,23)

local SuccessSound = Sound("buttons/button14.wav")
local ErrorSound = Sound("buttons/button8.wav")

local ErrorSoundDelay = SoundDuration(ErrorSound)

function ENT:Initialize()

	self:SetModel("models/Tiberium/dispenser.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Inputs = WTib.CreateInputs(self,{"BuildID"})
	self.Outputs = WTib.CreateOutputs(self,{"IsBuilding","PercentageComplete"})
	
end

function ENT:SpawnFunction(p,t)
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()

	if self.dt.IsBuilding then
	
		if (self.LastBuild + WTib.Dispenser.GetObjectByID( self.dt.BuildingID ).PercentDelay) <= CurTime() then
			self.dt.PercentageComplete = self.dt.PercentageComplete + 1
			
			if self.dt.PercentageComplete >= 100 then
			
				local ply
				if IsValid(self.dt.CurObject.WDSO) and self.dt.CurObject.WDSO:IsPlayer() then ply = self.dt.CurObject.WDSO end
				
				local ent = WTib.Dispenser.GetObjectByID( self.dt.BuildingID ).CreateEnt( self, self.dt.CurObject:GetAngles(), self.dt.CurObject:GetPos(), self.dt.BuildingID, ply )
				ent.WDSO = self.dt.CurObject.WDSO
				ent.WTib_Dispenser_Weld = constraint.Weld( self, ent, 0, 0, 0, true )
				
				self.dt.CurObject:Remove()
				self.dt.CurObject = nil
				self.dt.IsBuilding = false
				WTib.TriggerOutput( self, "IsBuilding", 0 )
				
			end
			
			WTib.TriggerOutput( self, "PercentageComplete", self.dt.PercentageComplete )
			
			self.LastBuild = CurTime()
		end
		
	end
	
	self:NextThink(CurTime())
	return true
	
end

function ENT:Use(ply)

	if !self.dt.IsBuilding then
	
		// Notify the client that the menu needs to open
		net.Start("wtib_dispenser_openmenu")
			net.WriteEntity(self)
		net.Send(ply)
		
	else
	
		self:EmitSound(ErrorSound)
		
	end
	
end

function ENT:BuildObject(id, ply)

	if !self.dt.IsBuilding and WTib.Dispenser.GetObjectByID(id) then
	
		local Attach = self:GetAttachment(self:LookupAttachment("item"))
		self.dt.BuildingID = id
		self.dt.PercentageComplete = 0
		self.dt.IsBuilding = true
		
		self.dt.CurObject = ents.Create("wtib_dispenser_object")
		self.dt.CurObject:SetAngles(self:LocalToWorldAngles(WTib.Dispenser.GetObjectByID(id).Angle or Angle(0,0,0)))
		self.dt.CurObject:SetModel(WTib.Dispenser.GetObjectByID(id).Model)
		self.dt.CurObject:Spawn()
		self.dt.CurObject:Activate()
		//self.dt.CurObject:SetPos(WorldToLocal(Attach.Pos,self:GetAngles(),self.dt.CurObject:OBBCenter(),self:GetAngles()))
		self.dt.CurObject:SetPos(self:LocalToWorld(NewObjectPos))
		self.dt.CurObject:SetParent(self)
		self.dt.CurObject.dt.Dispenser = self
		self.dt.CurObject.WDSO = ply
		
		local ed = EffectData()
			ed:SetEntity(self.dt.CurObject)
		util.Effect("wtib_dispenser", ed)
		
		WTib.TriggerOutput(self,"IsBuilding",1)
		return true
		
	end
	
	return false
	
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:TriggerInput(name,val)

	if name == "BuildID" then
	
		if self:BuildObject(math.Round(val)) then
			self:EmitSound(SuccessSound)
		elseif self.LastErrorSound < CurTime() then
			self:EmitSound(ErrorSound)
			self.LastErrorSound = CurTime()+ErrorSoundDelay
		end
		
	end
	
end

function WTib_Dispenser_PickupWeldRemover(ply, ent)

	if IsValid(ent.WTib_Dispenser_Weld) then
	
		ent.WTib_Dispenser_Weld:Remove()
		
	end
	
end
hook.Add( "GravGunPickupAllowed", "WTib_Dispenser_GravGunPickupAllowed", WTib_Dispenser_PickupWeldRemover)
hook.Add( "PhysgunPickup", "WTib_Dispenser_PhysgunPickup", WTib_Dispenser_PickupWeldRemover)

net.Receive( "wtib_dispenser_buildobject", function( len, ply )

	local ent = net.ReadEntity()
	local BID = net.ReadFloat()
	
	if WTib.IsValid(ent) then
		if ent:BuildObject( math.Round(BID), ply ) then
			ent:EmitSound(SuccessSound)
		elseif ent.LastErrorSound < CurTime() then
			ent:EmitSound(ErrorSound)
			ent.LastErrorSound = CurTime()+ErrorSoundDelay
		end
	end
	
end)

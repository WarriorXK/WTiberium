AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.LastErrorSound = 0
ENT.LastBuild = 0

local SuccessSound = Sound("buttons/button14.wav")
local ErrorSound = Sound("buttons/button8.wav")

local ErrorSoundDelay = SoundDuration(ErrorSound)

function ENT:Initialize()
	self:SetModel("models/Tiberium/factory.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Inputs = WTib.CreateInputs(self,{"BuildID"})
	self.Outputs = WTib.CreateOutputs(self,{"IsBuilding","PercentageComplete"})
	if WDS2 then WDS2.InitProp(self, 10000, 1, "AP") end
end

function ENT:SpawnFunction(p,t)
	local ent = WTib.SpawnFunction(p,t,self)
	if ValidEntity(ent) then
		
		// Spawn the control panel
		local Panel = ents.Create("wtib_factory_panel")
		Panel:Spawn()
		Panel:Activate()
		
		// Position the control panel
		local Attach = ent:GetAttachment(ent:LookupAttachment("panel"))
		Panel:SetPos(Attach.Pos)
		Panel:SetAngles(Attach.Ang)
		
		// Attach it to the factory
		Panel:SetParent(ent)
		Panel.dt.Factory = ent
		ent.dt.Panel = Panel
		Panel.WDSO = p
		
	end
	return ent
end

function ENT:Think()
	if self.dt.IsBuilding then
		if self.LastBuild+WTib.Factory.GetObjectByID(self.dt.BuildingID).PercentDelay <= CurTime() then
			self.dt.PercentageComplete = self.dt.PercentageComplete+1
			if self.dt.PercentageComplete >= 100 then
				local ply
				if ValidEntity(self.dt.CurObject.WDSO) and self.dt.CurObject.WDSO:IsPlayer() then ply = self.dt.CurObject.WDSO end
				
				// Call the function that creates the actual entity
				local ent = WTib.Factory.GetObjectByID(self.dt.BuildingID).CreateEnt(self, self.dt.CurObject:GetAngles(), self.dt.CurObject:GetPos(), self.dt.BuildingID, ply)
				ent.WDSO = self.dt.CurObject.WDSO
				
				// Remove the fake object
				self.dt.CurObject:Remove()
				self.dt.CurObject = nil
				
				// Reset some factory values
				self.dt.IsBuilding = false
				self.dt.TimeBuildStarted = 0
				WTib.TriggerOutput(self,"IsBuilding",0)
				
			end
			self.LastBuild = CurTime()
		end
	end
	WTib.TriggerOutput(self,"PercentageComplete",tonumber(self.dt.PercentageComplete))
	self:NextThink(CurTime())
	return true
end

function ENT:PanelUse(ply)
	if !self.dt.IsBuilding then
	
		// Notify the client that the menu needs to open
		umsg.Start("wtib_factory_openmenu",ply)
			umsg.Entity(self)
		umsg.End()
		
	else
		self:EmitSound(ErrorSound)
	end
end

function ENT:BuildObject(id,ply)
	if !self.dt.IsBuilding and WTib.Factory.GetObjectByID(id) then
		local Obj = WTib.Factory.GetObjectByID(id)
		
		// (Re)set all values on the factory
		self.dt.BuildingID = id
		self.dt.PercentageComplete = 0
		self.dt.IsBuilding = true
		self.dt.TimeBuildStarted = CurTime()
		
		// Create the fake object
		self.dt.CurObject = ents.Create("wtib_factory_object")
		self.dt.CurObject:SetAngles(self:LocalToWorldAngles(Obj.Angle or Angle(0,0,0)))
		self.dt.CurObject:SetModel(Obj.Model)
		self.dt.CurObject:Spawn()
		self.dt.CurObject:Activate()
		
		// Position the fake object
		local ModelOffset = Vector(0,0,self.dt.CurObject:OBBMins().z):Distance(Vector(0,0,self.dt.CurObject:GetPos().z))
		local SpawnPos = self:GetAttachment(self:LookupAttachment("spawn")).Pos
		SpawnPos.z = SpawnPos.z + ModelOffset
		self.dt.CurObject:SetPos(SpawnPos)
		self.dt.CurObject:DropToFloor()
		
		// Parent the fake object and give it the values it needs
		self.dt.CurObject:SetParent(self)
		self.dt.CurObject.dt.Factory = self
		self.dt.CurObject.WDSO = ply or self
		
		WTib.TriggerOutput(self,"IsBuilding",1)
		
		// Create the effects for the factory
		local ed = EffectData()
			ed:SetEntity(self)
		util.Effect("wtib_factorybuilding", ed)
		
		return true
	end
	return false
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:OnRemove()
	if ValidEntity(self.dt.Panel) then self.dt.Panel:Remove() end
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

net.Receive( "wtib_factory_buildobject", function( len )
	
	local ply = Entity(net.ReadLong())
	local ent = net.ReadEntity()

	if WTib.IsValid(ent) then
		if ent:BuildObject(math.Round(net.ReadFloat()),ply) then
			ent:EmitSound(SuccessSound)
		elseif ent.LastErrorSound < CurTime() then
			ent:EmitSound(ErrorSound)
			ent.LastErrorSound = CurTime()+ErrorSoundDelay
		end
	end
	
end)

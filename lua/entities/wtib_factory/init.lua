AddCSLuaFile("cl_init.lua")
AddCSLuaFile('menu.lua')
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("wtib_factory_buildobject")
util.AddNetworkString("wtib_factory_openmenu")

WTib.ApplyDupeFunctions(ENT)

ENT.LastErrorSound = 0
ENT.LastBuild = 0

local SuccessSound = Sound("buttons/button14.wav")
local ErrorSound = Sound("buttons/button8.wav")

local ErrorSoundDelay = SoundDuration(ErrorSound)

function ENT:Initialize()

	self:SetModel("models/tiberium/factory.mdl")
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
	
	if WDS2 then WDS2.InitProp(self, 10000, 1, "AP") end
	
end

function ENT:SpawnFunction(p,t)

	local ent = WTib.SpawnFunction(p,t,self)
	
	WTib_FactoryPanelSpawn(ent)
	
	return ent
	
end

function WTib_FactoryPanelSpawn(ent)

	if IsValid(ent) and ent:GetClass() == "wtib_factory" then

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
		Panel:SetFactory(ent)
		ent:SetPanel(Panel)
		Panel.WDSO = p

	end

end

function ENT:Think()

	if self:GetIsBuilding() then
	
		if self.LastBuild+WTib.Factory.GetObjectByID(self:GetBuildingID()).PercentDelay <= CurTime() then
		
			self:SetPercentageComplete(self:GetPercentageComplete() + 1)
			
			if self:GetPercentageComplete() >= 100 then
			
				local ply
				if IsValid(self:GetCurObject().WDSO) and self:GetCurObject().WDSO:IsPlayer() then ply = self:GetCurObject().WDSO end
				
				// Call the function that creates the actual entity
				local ent = WTib.Factory.GetObjectByID(self:GetBuildingID()).CreateEnt(self, self:GetCurObject():GetAngles(), self:GetCurObject():GetPos(), self:GetBuildingID(), ply)
				ent.WDSO = self:GetCurObject().WDSO
				
				// Remove the fake object
				self:GetCurObject():Remove()
				self:SetCurObject(nil)
				
				// Reset some factory values
				self:SetIsBuilding(false)
				self:SetTimeBuildStarted(0)
				WTib.TriggerOutput(self,"IsBuilding",0)
				
			end
			
			WTib.TriggerOutput(self,"PercentageComplete", self:GetPercentageComplete())
			
			self.LastBuild = CurTime()
			
		end
		
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:PanelUse(ply)

	if !self:GetIsBuilding() then

		// Notify the client that the menu needs to open
		net.Start("wtib_factory_openmenu")
			net.WriteEntity(self)
		net.Send(ply)
		
	else
	
		self:EmitSound(ErrorSound)
		
	end
	
end

function ENT:BuildObject(id, ply)

	if !self:GetIsBuilding() and WTib.Factory.GetObjectByID(id) then
		local Obj = WTib.Factory.GetObjectByID(id)
		
		// (Re)set all values on the factory
		self:SetBuildingID(id)
		self:SetPercentageComplete(0)
		self:SetIsBuilding(true)
		self:SetTimeBuildStarted(CurTime())
		
		// Create the fake object
		local ent = ents.Create("wtib_factory_object")
		ent:SetAngles(self:LocalToWorldAngles(Obj.Angle or Angle(0,0,0)))
		ent:SetModel(Obj.Model)
		ent:Spawn()
		ent:Activate()
		
		// Position the fake object
		local ModelOffset = Vector(0,0,ent:OBBMins().z):Distance(Vector(0,0,ent:GetPos().z))
		local SpawnPos = self:WorldToLocal(self:GetAttachment(self:LookupAttachment("spawn")).Pos)
		SpawnPos.z = SpawnPos.z + ModelOffset
		ent:SetPos(self:LocalToWorld(SpawnPos))
		ent:DropToFloor()
		
		// Parent the fake object and give it the values it needs
		ent:SetParent(self)
		ent:SetFactory(self)
		ent.WDSO = ply
		
		self:SetCurObject(ent)
		
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
	if IsValid(self:GetPanel()) then self:GetPanel():Remove() end
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

net.Receive( "wtib_factory_buildobject", function( len, ply )
	
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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.NextEffect = 0
ENT.LastBuild = 0

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
end

function ENT:SpawnFunction(p,t)
	local ent = WTib.SpawnFunction(p,t,13,self)
	local Panel = ents.Create("wtib_factory_panel")
	Panel:Spawn()
	Panel:Activate()
	local Attach = ent:GetAttachment(ent:LookupAttachment("panel"))
	Panel:SetPos(Attach.Pos)
	Panel:SetAngles(Attach.Ang)
	Panel:SetParent(ent)
	Panel.dt.Factory = ent
	Panel.WDSO = p
	return ent
end

function ENT:Think()
	if self.dt.IsBuilding then
		if self.LastBuild+WTib.Factory.GetObjectByID(self.dt.BuildingID).PercentDelay <= CurTime() then
			self.dt.PercentageComplete = self.dt.PercentageComplete+1
			if self.dt.PercentageComplete >= 100 then
				local ent = WTib.Factory.GetObjectByID(self.dt.BuildingID).CreateEnt(self,self.dt.CurObject:GetAngles(),self.dt.CurObject:GetPos(),self.dt.BuildingID)
				ent.WDSO = self.dt.CurObject.WDSO
				self.dt.CurObject:Remove()
				self.dt.CurObject = nil
				self.dt.IsBuilding = false
				WTib.TriggerOutput(self,"IsBuilding",0)
			end
			self.LastBuild = CurTime()
		end
		if self.NextEffect <= CurTime() and WTib.IsValid(self.dt.CurObject) then
			local Mins = self.dt.CurObject:OBBMins()
			local Maxs = self.dt.CurObject:OBBMaxs()
			local z = Mins.z+(((Maxs.z-Mins.z)/100)*self.dt.PercentageComplete)

			for i=1,4 do
				local Attach = self:GetAttachment(self:LookupAttachment("las"..tostring(i)))
				local ed = EffectData()
					ed:SetStart(Attach.Pos)
					ed:SetOrigin(self.dt.CurObject:LocalToWorld(Vector(math.random(Mins.z,Maxs.x),math.random(Mins.y,Maxs.y),z)))
					ed:SetMagnitude(0.1)
					ed:SetNormal(self:GetUp())
				util.Effect("wtib_factorylaser",ed)
			end
			self.NextEffect = CurTime()+0.1
		end
	end
	WTib.TriggerOutput(self,"PercentageComplete",tonumber(self.dt.PercentageComplete))
	if !WTib.IsValid(self.PlayerUsingMe) then
		self.BeingUsed = false
		self.PlayerUsingMe = nil
	end
	self:NextThink(CurTime())
	return true
end

function ENT:PanelUse(ply)
	if !self.BeingUsed then
		umsg.Start("wtib_factory_openmenu",ply)
			umsg.Entity(self)
		umsg.End()
		self.PlayerUsingMe = ply
		self.BeingUsed = true
	end
end

function ENT:BuildObject(id,ply)
	if !self.dt.IsBuilding and WTib.Factory.GetObjectByID(id) then
		self.dt.BuildingID = id
		self.dt.PercentageComplete = 0
		self.dt.IsBuilding = true
		self.dt.CurObject = ents.Create("wtib_factory_object")
		self.dt.CurObject:SetAngles(self:GetAngles())
		self.dt.CurObject:SetModel(WTib.Factory.GetObjectByID(id).Model)
		self.dt.CurObject:Spawn()
		self.dt.CurObject:Activate()
		self.dt.CurObject:SetPos(self:LocalToWorld(Vector(0,0,Vector(0,0,self.dt.CurObject:OBBMins().z):Distance(Vector(0,0,self.dt.CurObject:GetPos().z))+30)))
		self.dt.CurObject:SetParent(self)
		self.dt.CurObject.dt.Factory = self
		self.dt.CurObject.WDSO = ply or self
		WTib.TriggerOutput(self,"IsBuilding",1)
	end
end

function ENT:OnRestore()
	WTib.Restored(self)
end

function ENT:TriggerInput(name,val)
	if name == "BuildID" then
		self:BuildObject(math.Round(val))
	end
end

concommand.Add("wtib_factory_closemenu",function(ply,com,args)
	local ent = ents.GetByIndex(args[1])
	if WTib.IsValid(ent) then
		ent.BeingUsed = false
		ent.PlayerUsingMe = nil
	end
end)

concommand.Add("wtib_factory_buildobject",function(ply,com,args)
	local ent = ents.GetByIndex(args[1])
	if WTib.IsValid(ent) then
		ent:BuildObject(math.Round(args[2]),ply)
	end
end)

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

WTib.ApplyDupeFunctions(ENT)

ENT.NextEffect = 0
ENT.LastBuild = 0

function ENT:Initialize()
	self:SetModel("models/Tiberium/dispenser.mdl")
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
	return WTib.SpawnFunction(p,t,self)
end

function ENT:Think()
	if self.dt.IsBuilding then
		if self.LastBuild+WTib.Dispenser.GetObjectByID(self.dt.BuildingID).PercentDelay <= CurTime() then
			self.dt.PercentageComplete = self.dt.PercentageComplete+1
			if self.dt.PercentageComplete >= 100 then
				local ply
				if ValidEntity(self.dt.CurObject.WDSO) and self.dt.CurObject.WDSO:IsPlayer() then ply = self.dt.CurObject.WDSO end
				local ent = WTib.Dispenser.GetObjectByID(self.dt.BuildingID).CreateEnt(self,self.dt.CurObject:GetAngles(),self.dt.CurObject:GetPos(),self.dt.BuildingID,ply)
				ent.WDSO = self.dt.CurObject.WDSO
				constraint.Weld(self,ent,0,0,4000,true)
				self.dt.CurObject:Remove()
				self.dt.CurObject = nil
				self.dt.IsBuilding = false
				WTib.TriggerOutput(self,"IsBuilding",0)
			end
			self.LastBuild = CurTime()
		end
		/*
		if self.NextEffect <= CurTime() then
			for i=1,2 do
				local Attach = self:GetAttachment(self:LookupAttachment("las"..tostring(i)))
				local ed = EffectData()
					ed:SetStart(Attach.Pos)
					ed:SetOrigin(self.dt.CurObject:GetPos())
					ed:SetMagnitude(0.1)
					ed:SetNormal(self:GetUp())
				util.Effect("wtib_dispenserlaser",ed)
			end
			self.NextEffect = CurTime()+0.1
		end
		*/
	end
	WTib.TriggerOutput(self,"PercentageComplete",tonumber(self.dt.PercentageComplete))
	if !WTib.IsValid(self.PlayerUsingMe) then
		self.BeingUsed = false
		self.PlayerUsingMe = nil
	end
	self:NextThink(CurTime())
	return true
end

function ENT:Use(ply)
	if !self.BeingUsed then
		umsg.Start("wtib_dispenser_openmenu",ply)
			umsg.Entity(self)
		umsg.End()
		self.PlayerUsingMe = ply
		self.BeingUsed = true
	end
end

function ENT:BuildObject(id,ply)
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
		self.dt.CurObject:SetPos(self:LocalToWorld(Vector(7,14,23)))
		self.dt.CurObject:SetParent(self)
		self.dt.CurObject.dt.Dispenser = self
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

net.Receive( "wtib_dispenser_closemenu", function( len )
	local ent = ents.GetByIndex(net.ReadLong())
	if WTib.IsValid(ent) then
		ent.BeingUsed = false
		ent.PlayerUsingMe = nil
	end
end)

net.Receive( "wtib_dispenser_buildobject", function( len )
	local ent = ents.GetByIndex(net.ReadLong())
	local ply = net.ReadEntity()
	if WTib.IsValid(ent) then
		ent:BuildObject(math.Round(net.ReadFloat()),ply)
	end
end)

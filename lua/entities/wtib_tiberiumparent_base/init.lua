AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextReproduce = 0
ENT.Produces = {}
ENT.NextGrow = 0

function ENT:Initialize()
	self:SetRandomModel()
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:DrawShadow(false)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:InitTiberium()
end

function ENT:SetRandomModel()
	local Modl = table.Random(self.Models)
	self:SetModel(util.IsValidModel(Modl) and Modl or "models/Tiberium/tiberium_parent.mdl")
end

function ENT:SpawnFunction(p,t)
	return WTib.CreateTiberium(self,self.ClassName,t,p)
end

function ENT:InitTiberium()
	self.NextReproduce = 0
	self.Produces = {}
	self.NextGrow = 0
	if self:GetField() <= 0 then self:SetField(WTib.CreateField(self)) end // If no field was set before we spawned create one
	self:SetTiberiumAmount(self.TiberiumStartAmount)
	
	for i=2,100 do // Efficiency at its best
		if (self:GetMaxTiberiumAmount()/i) == 250 then
			self.dt.ColorDevider = i
		end
	end
	
	self:SetRenderMode(self.RenderMode)
	self:SetColor(self.TiberiumColor)
end

function ENT:Think()
	if self.NextGrow <= CurTime() then // Check if we should get more resources
		self:AddTiberiumAmount(self.Growth_Addition)
		self.NextGrow = CurTime()+self.Growth_Delay
	end
	if self.NextReproduce <= CurTime() and self:GetTiberiumAmount() >= self.Reproduce_TiberiumRequired then self:AttemptReproduce() end // Check if we should reproduce

	self:NextThink(CurTime()+1)
	return true
end

function ENT:AttemptReproduce()
	if WTib.IsFieldFull(self:GetField()) then
		self.NextReproduce = CurTime()+self.Reproduce_Delay
		WTib.DebugPrint(tostring(self) .. " - Field is full")
		return
	end
	local Amount = 0
	for k,v in pairs(self.Produces) do
		if WTib.IsValid(v) then
			Amount = Amount+1
		else
			self.Produces[k] = nil
		end
	end
	local AllEntities = ents.GetAll()
	local Filter = {}
	for _,v in pairs(AllEntities) do
		if v.IsTiberium or (v.Alive and v:Alive()) then
			table.insert(Filter,v)
		end
	end
	for i=1,10 do
		local pos = self:LocalToWorld(self:OBBCenter())
		local t = WTib.Trace(pos,VectorRand()*math.random(-500,500),Filter)
		local ed = EffectData()
			ed:SetOrigin(pos)
			ed:SetStart(t.HitPos)
			ed:SetMagnitude(10)
			ed:SetScale(2)
		WTib.DebugEffect("WTib_DebugTrace",ed)
		local Save = true
		if !t.Hit then
			pos = t.HitPos
			t = WTib.Trace(t.HitPos,(self:GetUp()*-1)*300,Filter)
			local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetStart(t.HitPos)
				ed:SetMagnitude(10)
				ed:SetScale(2)
			WTib.DebugEffect("WTib_DebugTrace",ed)
		end
		local ent = WTib.CreateTiberium(self,self.ClassToSpawn,t,self.WDSO)
		if WTib.IsValid(ent) then
			table.insert(self.Produces,ent)
			WTib.DebugPrint("New Tiberium grown from old")
			self.NextReproduce = CurTime()+self.Reproduce_Delay
			self:DrainTiberiumAmount(self.Reproduce_TiberiumDrained)
			WTib.AddFieldMember(self:GetField(),ent)
			break
		else
			self.NextReproduce = CurTime()+60
		end
	end
end

function ENT:TakeSonicDamage(am) // Do something fancy?
	self:DrainTiberiumAmount(am)
end

function ENT:SetField(num)
	self.dt.TiberiumField = num
end

function ENT:SetTiberiumAmount(am)
	self.dt.TiberiumAmount = math.Clamp(am,1,self:GetMaxTiberiumAmount())
end

function ENT:AddTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() + am)
end

function ENT:DrainTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() - am)
end

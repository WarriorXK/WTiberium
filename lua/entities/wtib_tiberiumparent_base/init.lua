AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.NextReproduce = 0
ENT.Produces = {}
ENT.NextGrow = 0

function ENT:SetRandomModel()

	local Modl = ""
	if type(self.Models) == "table" then Modl = table.Random(self.Models) end
	if type(Modl) != "string" or !util.IsValidModel(Modl) then Modl = "models/Tiberium/tiberium_parent.mdl" end
	
	self:SetModel(Modl)
	
end

function ENT:SpawnFunction(p,t)
	return WTib.CreateTiberium(self,self.ClassName,t,p)
end

function ENT:Touch(ent)
	
	if IsValid(ent) then
		WTib.Infect(ent, self, self, 2, 5, false)
	end
	
end

function ENT:Think()

	if self.NextGrow <= CurTime() then // Check if we should get more resources
		self:AddTiberiumAmount(self.Growth_Addition)
		self.NextGrow = CurTime()+self.Growth_Delay
	end

	self:NextThink(CurTime()+1)
	return true
	
end

function ENT:AttemptReproduce()
	if !self:CanReproduce() then return false end
	
	local Filter = {}
	for _,v in pairs(ents.GetAll()) do
		if v.IsTiberium or (v:IsPlayer() and v:Alive()) or v:IsNPC() then
			table.insert(Filter,v)
		end
	end
	
	for i=1, 7 do
	
		local pos = self:LocalToWorld(self:OBBCenter())
		local Rnd = i * 70
		local t = WTib.Trace(pos, VectorRand() * math.random(-Rnd, Rnd), Filter)
		
		if WTib.Debug then
		
			local ed = EffectData()
				ed:SetOrigin(pos)
				ed:SetStart(t.HitPos)
				ed:SetMagnitude(10)
				ed:SetScale(2)
			util.Effect("WTib_DebugTrace",ed)
			
		end
		
		if !t.Hit then
		
			pos = t.HitPos
			t = WTib.Trace(t.HitPos,(self:GetUp()*-1)*400,Filter)
			
			if WTib.Debug then
			
				local ed = EffectData()
					ed:SetOrigin(pos)
					ed:SetStart(t.HitPos)
					ed:SetMagnitude(10)
					ed:SetScale(2)
				util.Effect("WTib_DebugTrace",ed)
				
			end
			
		end
		
		if t.Hit then
		
			local ent = WTib.CreateTiberium(self,self.ClassToSpawn,t,self.WDSO)
			if WTib.IsValid(ent) then
			
				table.insert(self.Produces,ent)
				WTib.AddFieldMember(self:GetField(),ent)
				
				WTib.DebugPrint("New Tiberium grown from old")
				self.NextReproduce = CurTime()+self.Reproduce_Delay
				self:DrainTiberiumAmount(self.Reproduce_TiberiumDrained)
				
				break

			end
			
		end
		
		self.NextReproduce = CurTime()+self.Reproduce_Delay
		
	end
	
	return false
	
end

function ENT:CanReproduce()
	if WTib.IsFieldFull(self:GetField()) then return false end
	return true
end

function ENT:TakeSonicDamage(am) // Do something fancy?
	self:DrainTiberiumAmount(am)
end

function ENT:SetField(num)
	self.dt.TiberiumField = num
end

function ENT:SetTiberiumAmount(am)

	self.dt.TiberiumAmount = math.Clamp(am, 1, self:GetMaxTiberiumAmount())
	
	if self.NextReproduce <= CurTime() and self:GetTiberiumAmount() >= self.Reproduce_TiberiumRequired then self:AttemptReproduce() end // Check if we should reproduce
	
end

function ENT:AddTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() + math.max(am, 0))
end

function ENT:DrainTiberiumAmount(am)
	self:SetTiberiumAmount(self:GetTiberiumAmount() - math.min(am, 0))
end

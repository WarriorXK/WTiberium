include('shared.lua')

ENT.GrowingSinceSpawn = true
ENT.LastLightSize = 0
ENT.LastSize = 0

function ENT:Draw()
	self:SetModelScale(Vector(self.Size,self.Size,self.Size))
	self:DrawModel()
end

function ENT:ThinkSize()
	local Target = 0.5 + (self:GetCrystalSize() / 1.7)
	
	local Speed = 0.0001
	if Target == self.LastSize then self.GrowingSinceSpawn = false end
	if self.GrowingSinceSpawn then Speed = 0.0004 end // Speed it up a bit if it has just been spawned
	
	self.Size = math.Approach(self.LastSize,Target,Speed)
	if self.Size < self.LastSize then // No shrinking
		self.Size = self.LastSize
	else
		self.LastSize = self.Size
	end
end

function ENT:Think()
	self:ThinkSize()
	self:CreateDLight()
	self:NextThink(CurTime()+1)
	return true
end

function ENT:CreateDLight()
	if (WTib.DynamicLight and !WTib.DynamicLight:GetBool()) or false then return end
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		local LightScale = WTib.DynamicLightSize:GetInt()
		local Col = self:GetColor()
		local Scl = 1.1
		local LightSize = math.Clamp(50 + (self.Size * 120),0,255)
		dlight.Pos = self:LocalToWorld(self:OBBCenter())
		dlight.r = Col.r
		dlight.g = Col.g
		dlight.b = Col.b
		dlight.Style = 1
		dlight.Brightness = 1
		dlight.Size = (LightSize*1.1)*LightScale
		dlight.Decay = (LightSize*5.5)*LightScale
		dlight.DieTime = CurTime()+1
	end
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

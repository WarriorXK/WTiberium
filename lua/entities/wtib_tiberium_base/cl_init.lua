include('shared.lua')

ENT.GrowingSinceSpawn = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.LightSize = 0
ENT.LastSize = 0

function ENT:Draw()
	self:SetModelScale(Vector(self.Size,self.Size,self.Size))
	self:DrawModel()
end

function ENT:ThinkSize()
	local Target = 0.5+(self:GetCrystalSize()/2)
	if Target == self.LastSize then self.GrowingSinceSpawn = false end
	local Speed = 0.0001
	if self.GrowingSinceSpawn then Speed = 0.0004 end
	self.Size = math.Approach(self.LastSize,Target,Speed)
	if self.Size < self.LastSize then
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
		self.LightSize = math.Approach(self.LightSize,math.Clamp((((self:GetTiberiumAmount()/self:GetColorDevider()) or 100)+5)*WTib.DynamicLightSize:GetInt(),0,300),2)
		local Col = self:GetColor()
		dlight.Pos = self:LocalToWorld(self:OBBCenter())
		dlight.r = Col.r
		dlight.g = Col.g
		dlight.b = Col.b
		dlight.Brightness = 1
		dlight.Size = self.LightSize
		dlight.Decay = self.LightSize*5
		dlight.DieTime = CurTime()+1
	end
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.GrowingSinceSpawn = true
ENT.NextSizeThink = 0
ENT.NextLight = 0
ENT.NextColor = 0
ENT.LastSize = 0
ENT.Size = 0

function ENT:Draw()
	self:SetModelScale( self.Size, 0 )
	self:DrawModel()
end

function ENT:Think()

	if self.NextSizeThink <= CurTime() then
		self:ThinkSize()
		self.NextSizeThink = CurTime()+0.05
		
	end

	if self.NextLight <= CurTime() then
		self:CreateDLight()
		self.NextLight = CurTime()+0.1
	end
	
	if self.NextColor <= CurTime() then
		self:CheckColor()
		self.NextColor = CurTime()+1
	end
end

function ENT:CheckColor()

	local Col = self:GetColor()

	self:SetRenderMode(self.RenderMode)
	self:SetColor(Color(
		math.Approach(Col.r, self.TiberiumColor.r, 5),
		math.Approach(Col.g, self.TiberiumColor.g, 5),
		math.Approach(Col.b, self.TiberiumColor.b, 5),
		math.Approach(Col.a, ((self:GetTiberiumAmount()/self:GetColorDevider())/2) + 75, 2))
	)
	
end

function ENT:ThinkSize()

	local Target = self:GetCrystalSize()*1.1
	if Target == self.LastSize then self.GrowingSinceSpawn = false end
	self.Size = math.Approach(self.LastSize, Target, self.GrowingSinceSpawn and 0.001 or 0.0003)
	self.LastSize = self.Size

end

function ENT:CreateDLight()

	if (WTib.DynamicLight and !WTib.DynamicLight:GetBool()) or false then return end

	local dlight = DynamicLight(0)
	if dlight then
		local Col = self:GetColor()
		dlight.Pos = self:LocalToWorld(self:OBBCenter())
		dlight.r = Col.r
		dlight.g = Col.g
		dlight.b = Col.b
		dlight.Style = 1
		dlight.NoModel = WTib.CheapDynamicLight:GetBool()
		dlight.NoWorld  = true
		dlight.Brightness = 1
		dlight.Size = math.Clamp(50 + (self.Size * 120),0,255) * WTib.DynamicLightSize:GetInt()
		dlight.Decay = dlight.Size
		dlight.DieTime = CurTime()+0.2
	end
	
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

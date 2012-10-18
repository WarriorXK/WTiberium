include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.GrowingSinceSpawn = true
ENT.NextSizeThink = 0
ENT.NextLight = 0
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
	
	self:CreateDLight()
	
end

function ENT:ThinkSize()

	local Target = 0.5 + (self:GetCrystalSize() / 1.7)

	if Target == self.LastSize then self.GrowingSinceSpawn = false end
	
	self.Size = math.max(self.LastSize, math.Approach(self.LastSize, Target, self.GrowingSinceSpawn and 0.001 or 0.0003))
	self.LastSize = self.Size

end

function ENT:CreateDLight()

	if (WTib.DynamicLight and !WTib.DynamicLight:GetBool()) or false then return end
	
	if self.NextLight <= CurTime() then
	
		local dlight = DynamicLight(0)
		if dlight then
			local Col = self:GetColor()
			dlight.Pos = self:LocalToWorld(self:OBBCenter())
			dlight.r = Col.r
			dlight.g = Col.g
			dlight.b = Col.b
			dlight.Style = 1
			dlight.NoModel = WTib.CheapDynamicLight:GetBool()
			dlight.Brightness = 1
			dlight.Size = math.Clamp(50 + (self.Size * 120),0,255) * WTib.DynamicLightSize:GetInt()
			dlight.Decay = dlight.Size
			dlight.DieTime = CurTime()+0.2
		end
		
		self.NextLight = CurTime()+0.1
		
	end
	
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

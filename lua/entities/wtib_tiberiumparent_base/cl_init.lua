include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.NextLight = 0

function ENT:DrawTranslucent()
	self:DrawModel()
end

function ENT:Think()

	self:CreateDLight()
	self:NextThink(CurTime()+1)
	return true
	
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
			dlight.Brightness = 3
			dlight.Size = 250 * WTib.DynamicLightSize:GetInt()
			dlight.Decay = dlight.Size
			dlight.DieTime = CurTime()+1.1
		end
		
		self.NextLight = CurTime()+1
		
	end
	
end
language.Add(WTib.GetClass(ENT), ENT.PrintName)

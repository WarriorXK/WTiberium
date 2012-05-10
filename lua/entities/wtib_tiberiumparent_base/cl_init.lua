include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.LastSize = 0

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
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
		local LightSize = 170
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

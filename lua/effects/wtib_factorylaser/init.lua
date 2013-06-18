
EFFECT.NextSpark = 0
EFFECT.GlowSize = 15
EFFECT.GlowMat = Material("models/factory_effect")
EFFECT.BeamMat = Material("cable/redlaser")

EFFECT.UBound = Vector(0, 0, 0)
EFFECT.LBound = Vector(0, 0, 0)

function EFFECT:Init(d)
	self.StartPos = d:GetStart()
	self.Factory = d:GetEntity()
	self.EndPos = d:GetOrigin()
	self.DieTime = CurTime()+d:GetMagnitude()
	
	self.LBound, self.UBound = self.Factory:GetModelRenderBounds()
	self:SetRenderBounds( self.Factory:LocalToWorld(self.UBound), self.Factory:LocalToWorld(self.LBound) )
	
end

function EFFECT:Think()
	return self.DieTime > CurTime() and self:ValidEnts()
end

function EFFECT:ValidEnts()
	return IsValid(self.Factory) and IsValid(self.Factory:GetCurObject())
end

function EFFECT:Render()

	if self:ValidEnts() then
	
		self:SetRenderBounds( self.Factory:LocalToWorld(self.UBound), self.Factory:LocalToWorld(self.LBound) )
	
		local Start = self.Factory:LocalToWorld(self.StartPos)
		local End = self.Factory:GetCurObject():LocalToWorld(self.EndPos)
		local Col = Color(200,50,50,255)
		
		render.SetMaterial(self.GlowMat)
		render.DrawSprite(Start, self.GlowSize, self.GlowSize, Col)
		
		render.SetMaterial(self.BeamMat)
		render.DrawBeam(Start, End, 10, 0, 0, Col)
		
		if self.NextSpark <= CurTime() then
		
			local ed = EffectData()
			ed:SetOrigin(End)
			ed:SetNormal(self.Factory:GetUp():GetNormal())
			ed:SetMagnitude(0.5)
			ed:SetScale(1)
			ed:SetRadius(1)
			util.Effect("Sparks",ed)
			self.NextSpark = CurTime()+0.3
			
		end
		
	end
end

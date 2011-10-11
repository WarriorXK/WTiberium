
EFFECT.BeamMat = Material("cable/redlaser")
EFFECT.NextSpark = 0

function EFFECT:Init(d)
	self.StartPos = d:GetStart()
	self.EndPos = d:GetOrigin()
	self.Factory = d:GetEntity()
	self.Normal = d:GetNormal()
	self.fDelta = 3
	self.Entity:SetRenderBoundsWS(self.StartPos,self.EndPos)
	self.DieTime = CurTime()+d:GetMagnitude()
end

function EFFECT:Think()
	return self.DieTime > CurTime() and self:ValidEnts()
end

function EFFECT:ValidEnts()
	return ValidEntity(self.Factory) and ValidEntity(self.Factory.dt.CurObject)
end

function EFFECT:Render()
	if self:ValidEnts() then
		render.SetMaterial(self.BeamMat)
		local Start = self.StartPos
		local End = self.Factory.dt.CurObject:LocalToWorld(self.EndPos)
		render.DrawBeam(Start,End,10,0,0,Color(255,0,0,255))
		if self.NextSpark <= CurTime() then
			local ed = EffectData()
			ed:SetOrigin(End)
			ed:SetNormal(self.Normal)
			ed:SetMagnitude(0.5)
			ed:SetScale(1)
			ed:SetRadius(1)
			util.Effect("Sparks",ed)
			self.NextSpark = CurTime()+0.3
		end
		self.Entity:SetRenderBoundsWS(Start,End)
	end
end

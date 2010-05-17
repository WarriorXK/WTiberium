
EFFECT.Mat = Material("cable/redlaser")
EFFECT.NextSpark = 0

function EFFECT:Init(d)
	self.StartPos = d:GetStart()
	self.EndPos = d:GetOrigin()
	self.Normal = d:GetNormal()
	self.fDelta = 3
	self.Entity:SetRenderBoundsWS(self.StartPos,self.EndPos)
	self.DieTime = CurTime()+d:GetMagnitude()
end

function EFFECT:Think()
	return self.DieTime > CurTime()
end

function EFFECT:Render()
	render.SetMaterial(self.Mat)
	render.DrawBeam(self.EndPos,self.StartPos,10,0,0,Color(255,0,0,255))
	if self.NextSpark <= CurTime() then
		local ed = EffectData()
		ed:SetOrigin(self.EndPos)
		ed:SetNormal(self.Normal)
		ed:SetMagnitude(1)
		ed:SetScale(1)
		ed:SetRadius(2)
		util.Effect("Sparks",ed)
		self.NextSpark = CurTime()+0.3
	end
end

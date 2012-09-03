
EFFECT.Mat = Material("cable/redlaser")

local Col = Color(255,0,0,255)

function EFFECT:Init(d)

	self.StartPos = d:GetStart()	
	self.EndPos = d:GetOrigin()
	
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
	self.DieTime = CurTime() + d:GetMagnitude()
	
end

function EFFECT:Think()
	return self.DieTime > CurTime()
end

function EFFECT:Render()
	render.SetMaterial(self.Mat)
	render.DrawBeam(self.EndPos, self.StartPos, 80, 0, 0, Col)
end

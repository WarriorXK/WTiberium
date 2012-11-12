
function EFFECT:Init(d)

	local Pos = d:GetOrigin() or d:GetStart()
	local Siz = d:GetScale() or d:GetMagnitude()
	
	self.Emitter = ParticleEmitter(Pos)
	self:SetRenderBounds(Pos * -Siz, Pos * Siz)
	
	local Grav = Vector(0, 0, -30)
	local RCol = math.random(50, 100)
	local Alph = math.Clamp(60 * Siz, 100, 255)
	
	for i=1, 12 do
	
		local part
		if self.Emitter then
			part = self.Emitter:Add("particle/SmokeStack.vtf", Pos + Vector(math.Rand(-15,15), math.Rand(-15, 15), math.Rand(-15, 15)))
		end
		
		if part then
			part:SetColor(RCol, RCol, RCol, Alph)
			part:SetAirResistance(200)
			part:SetDieTime(3.5)
			part:SetGravity(Grav)
			part:SetVelocity(Vector(math.random(-0.9, 0.9), math.random(-0.9, 0.9), math.random(0.5, 1)) * 300)
			part:SetLifeTime(0)
			part:SetRoll(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
			part:SetRollDelta(0)
			part:SetStartSize(80 * Siz)
			part:SetEndSize(10)
			part:SetStartAlpha(Alph)
			part:SetEndAlpha(20)
		end
		
	end
	
	if self.Emitter then
	
		self.Emitter:Finish()
		
	end
	
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

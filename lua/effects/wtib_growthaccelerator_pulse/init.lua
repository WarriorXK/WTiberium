
local Vect = Vector(0, 0, 0)

function EFFECT:Init(data)

	self.Ent = data:GetEntity()
	self.Offset = data:GetOrigin()
	self.Magnitude = data:GetMagnitude()
	
	self.Emitter = ParticleEmitter(self.Ent:GetPos())
	self:SetRenderBounds(self.Ent:LocalToWorld(self.Ent:OBBMins() * (self.Magnitude / 2)), self.Ent:LocalToWorld(self.Ent:OBBMaxs() * (self.Magnitude / 2)))
	
	if WTib.IsValid(self.Ent) then
	
		local part
		local StartPos = self.Ent:LocalToWorld(self.Offset)
		
		for i=0, 358, 2 do
		
			if self.Emitter then
			
				part = self.Emitter:Add("particle/Particle_Glow_03.vtf", StartPos)
				
			end
			
			if part then
			
				part:SetColor(0, 255, 100, 100)
				part:SetAirResistance(1)
				part:SetDieTime(2)
				part:SetGravity(Vect)
				
				local Ang = self.Ent:GetUp():Angle()
				Ang.y = i
				
				part:SetVelocity(Ang:Up() * (self.Magnitude / 1.9))
				part:SetLifeTime(0)
				part:SetRollDelta(0)
				part:SetStartSize(7)
				part:SetEndSize(15 * (self.Magnitude / 200))
				part:SetStartAlpha(100)
				part:SetEndAlpha(0)
				
			end
			
		end
		
	elseif self.Emitter then
	
		self.Emitter:Finish()
		
	end
	
end

function EFFECT:Think()
	return false
end

function EFFECT:Render() end

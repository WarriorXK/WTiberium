
local Vect = Vector(0,0,0)

function EFFECT:Init(data)
	self.OEnt = data:GetEntity()
	self.TEnt = Entity(data:GetScale())
	self.MaxLeng = data:GetMagnitude()
 	self.Emitter = ParticleEmitter(self.OEnt:GetPos())
	self.Entity:SetRenderBounds(self.OEnt:GetPos()*-self.MaxLeng,self.OEnt:GetPos()*self.MaxLeng)
end

function EFFECT:Think()
	if !WTib.IsValid(self.OEnt) or !WTib.IsValid(self.TEnt) or !self.TEnt.dt.Online or !table.HasValue(ents.FindInCone(self.OEnt:GetPos(),self.OEnt:GetUp(),self.MaxLeng,10),self.TEnt) then
		if self.Emitter then
			self.Emitter:Finish()
		end
		return false
	else
		return true
	end
end

function EFFECT:Render()
	if WTib.IsValid(self.TEnt) and WTib.IsValid(self.OEnt) then
		local part
		local StartPos = self.TEnt:LocalToWorld(Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10)))
		if self.Emitter then
			part = self.Emitter:Add("particle/Particle_Glow_03.vtf",StartPos)
		end
		if part then
			part:SetColor(0,150,0,100)
			part:SetAirResistance(5)
			part:SetDieTime(1.5)
			part:SetGravity(Vect)
			part:SetVelocity((self.OEnt:GetPos()-StartPos))
			part:SetLifeTime(0)
			part:SetRoll(self.OEnt:GetAngles())
			part:SetRollDelta(0)
			part:SetStartSize(7)
			part:SetEndSize(0)
			part:SetStartAlpha(100)
			part:SetEndAlpha(0)
		end
	end
end

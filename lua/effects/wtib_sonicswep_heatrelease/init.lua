
local Grav = Vector(0,0,90)

function EFFECT:Init(d)
	print("Effect2")
	self.Swep = d:GetEntity()
	if ValidEntity(self.Swep) then
		self.Emitter = ParticleEmitter(self.Swep:GetPos())
	end
	print(self.Swep)
end

function EFFECT:Think()
	local Valid = ValidEntity(self.Swep) and self.Swep.dt.Heat > 0 
	if Valid then
		if self.LastParticle <= CurTime() then
			self.LastParticle = CurTime()+0.12
			for k,v in pairs(self.Vents) do
				
				local Pos = self.Swep:GetPos()
				
				local Smoke = self.Emitter:Add("particles/smokey", Pos)
				Smoke:SetLifeTime(math.Rand(4,5))
				Smoke:SetDieTime(math.Rand(10,12))
				Smoke:SetStartAlpha(math.random(10,20))
				Smoke:SetEndAlpha(0)
				Smoke:SetStartSize(math.random(14,16))
				Smoke:SetEndSize(28)
				Smoke:SetRoll(math.Rand(-360,360))
				Smoke:SetRollDelta(math.Rand(-1,1))
				Smoke:SetAirResistance(300)
				Smoke:SetGravity(Grav * math.random(0.8,1.1))
				
			end
		end
	elseif self.Emitter then
		self.Emitter:Finish()
	end
	return Valid
end

function EFFECT:Render() end

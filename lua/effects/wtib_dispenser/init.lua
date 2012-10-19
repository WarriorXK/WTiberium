
EFFECT.GlowMat = Material("wds/effects/blankparticle")

local TopPos = Vector(5.33, 13.95, 38.3)
local LowPos = Vector(5.33, 13.95, -7.4)

local Vect = Vector(0,0,0)

function EFFECT:Init(d)

	self.DispenserObject = d:GetEntity()
	
	self.Emitter = ParticleEmitter(self.DispenserObject:GetPos())
	
end

function EFFECT:Think()
	local ValidEffect = IsValid(self.DispenserObject) and IsValid(self.DispenserObject.dt.Dispenser) and self.DispenserObject.dt.Dispenser.dt.PercentageComplete < 100
	
	if ValidEffect then
	
		for i=1,2 do
			
			local Pos = i==1 and TopPos or LowPos
			Pos = self.DispenserObject.dt.Dispenser:LocalToWorld(Pos)
			
			if self.Emitter then
			
				part = self.Emitter:Add( "particle/Particle_Glow_03.vtf", Pos )
				
				if part then
			
					part:SetColor(75, math.random(80,180), 255)
					part:SetAirResistance(20)
					part:SetDieTime(0.10)
					part:SetGravity(Vect)
					part:SetVelocity((self.DispenserObject:GetPos()-Pos) * 10)
					part:SetLifeTime(0)
					part:SetRollDelta(0)
					part:SetStartSize(1)
					part:SetEndSize(4)
					part:SetStartAlpha(100)
					part:SetEndAlpha(0)
					
				end
				
			end
			
		end
	
	else
	
		if self.Emitter then
		
			self.Emitter:Finish()
			
		end
		
	end
	
	return ValidEffect
end

function EFFECT:Render()
	
	local Col = Color(75, math.random(80,180), 255)
	
	render.SetMaterial(self.GlowMat)
	render.DrawSprite(self.DispenserObject.dt.Dispenser:LocalToWorld(TopPos), 2, 2, Col)
	
	render.SetMaterial(self.GlowMat)
	render.DrawSprite(self.DispenserObject.dt.Dispenser:LocalToWorld(LowPos), 2, 2, Col)
	
end

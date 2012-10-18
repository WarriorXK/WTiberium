
EFFECT.GlowMat = Material("models/factory_effect")

EFFECT.ProgressColors = {
							Color(255,0,0,255),		// 0- 25%
							Color(250,160,0,255),	// 25 - 50%
							Color(255,255,0,255),	// 50 - 75%
							Color(0,255,0,255)		// 75 - 100%
						}

EFFECT.ProgressLights =	{
							{ // 0- 25%
								Vector(265.4906, 20.5, 128.0693),
								Vector(266.3376, -20.5, 129.2608),
								
								Vector(20.5, -265.1653, 129.1528),
								Vector(-20.5, -265.8034, 128.8310),
								
								Vector(-265.4671, -20.5, 129.5130),
								Vector(-265.2523, 20.5, 128.2566),
								
								Vector(-20.5, 265.8126, 130.9859),
								Vector(20.5, 265.5844, 127.9182)
							},
							{ // 25 - 50%
								Vector(265.0175, 20.5, 227.5905),
								Vector(266.3386, -20.5, 226.9981),
								
								Vector(20.5, -265.2913, 225.7245),
								Vector(-20.5, -265.2181, 224.8639),
								
								Vector(-264.9470, -20.5, 226.5839),
								Vector(-265.2884, 20.5, 224.8727),
								
								Vector(-20.5, 265.7487, 227.3638),
								Vector(20.5, 264.0331, 226.9902)
							},
							{ // 50 - 75%
								Vector(243.7742, 13, 336.0752),
								Vector(243.3735, -13, 335.3388),
								
								Vector(13,-244.6993, 337.9952),
								Vector(-13, -241.9225, 335.6015),
								
								Vector(-243.7068, -13, 336.6204),
								Vector(-243.8705, 13, 335.8076),
								
								Vector(-13, 245.0813, 338.7108),
								Vector(13, 242.7083, 338.6653)
							},
							{ // 75 - 100%
								Vector(220.2656, 8, 409.0753),
								Vector(218.9827, -8, 410.0390),
								
								Vector(8, -219.7626, 410.4131),
								Vector(-8, -217.9224, 409.3769),
								
								Vector(-219.0033, -8, 408.9059),
								Vector(-217.9851, 8, 409.8657),
								
								Vector(-8, 220.3671, 410.7116),
								Vector(8, 219.6837, 410.2082)
							}
						}
EFFECT.Vents = 	{
					Vector(272.1103, 40.4054, 47.7907), // Pilar back
					Vector(272.1475, -38.9966, 47.7534),
					
					Vector(39.4808, -272.0665, 47.4756), // Pilar left
					Vector(-40.0319, -271.9588, 47.6452),
					
					Vector(-271.9715, -39.0546, 47.5306), // Pilar front
					Vector(-272.6660, 40.4568, 47.5930),
					
					Vector(-40.0571, 272.0305, 47.5480), // Pilar right
					Vector(39.4301, 272.1643, 47.6685)
				}

EFFECT.LastParticle = 0

local Grav = Vector(0,0,90)

function EFFECT:Init(d)

	self.Factory = d:GetEntity()
	
	if IsValid(self.Factory) then
	
		self.Emitter = ParticleEmitter(self.Factory:GetPos())
		
		local LBound, UBound = self.Factory:GetModelRenderBounds()
		self:SetRenderBounds( LBound, UBound )
		
	end
	
end

function EFFECT:Think()

	local Valid = IsValid(self.Factory) and self.Factory.dt.IsBuilding
	
	if Valid then
	
		if self.LastParticle <= CurTime() then
		
			self.LastParticle = CurTime()+0.12
			
			for k,v in pairs(self.Vents) do
			
				local Opposite = k % 2 == 0 and self.Vents[k - 1] or self.Vents[k + 1] // Get the vent opposing the current vent
				local PartVel = (v - Opposite):GetNormalized() * 50
				local Val = 3
				local RandVect = Vector(math.Rand(-Val,Val),math.Rand(-Val,Val),math.Rand(-Val,Val))
			
				local Smoke = self.Emitter:Add("particles/smokey", self.Factory:LocalToWorld(v))
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
				Smoke:SetVelocity(PartVel + RandVect)
				
			end
			
		end
		
	elseif self.Emitter then
	
		self.Emitter:Finish()
		
	end
	
	return Valid
	
end

function EFFECT:Render()

	local Progress = math.ceil(self.Factory.dt.PercentageComplete / ( 100 / table.Count( self.ProgressLights) ))
	local GlowSize = 15
	local Col = self.ProgressColors[Progress]
	
	render.SetMaterial(self.GlowMat)
	for _,v in pairs(self.ProgressLights[Progress]) do
		render.DrawSprite(self.Factory:LocalToWorld(v), GlowSize, GlowSize, Col)
	end
	
end

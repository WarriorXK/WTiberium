include('shared.lua')

local EffectColor = Color(200, 200, 255, 255)
local EffectMat = Material("wtiberium/effects/sonicgenerator")

local EffectMaxSize = 33
local EffectMinSize = 32

ENT.EffectGrowing = true
ENT.LastCurTime = 0
ENT.EffectSize = 32

function ENT:Draw()
	
	self:DrawModel()
	WTib.Render(self)
	
	if self.dt.Online then
	
		local Normal = (LocalPlayer():GetPos()-self:GetPos()):GetNormalized()
		render.SetMaterial(EffectMat)
		render.DrawSphere( self:GetPos(), self.EffectSize, 35, 35, EffectColor )
	
	end
	
end

function ENT:WTib_GetTooltip()
	local on = "Off"
	if self.dt.Online then
		on = "On"
	end
	return self.PrintName.." ("..on..")\nRange : "..math.Round(tostring(self.dt.Range))
end

function ENT:Think()

	if CurTime() != self.LastCurTime then // So that the effect stops when the game is pauzed
	
		local Target = self.EffectGrowing and EffectMaxSize or EffectMinSize
		self.EffectSize = math.Approach( self.EffectSize, Target, 0.3)
		if self.EffectSize == Target then self.EffectGrowing = !self.EffectGrowing end
		
	end
	
	self.LastCurTime = CurTime()
	
	self:NextThink(CurTime())
	return true
	
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

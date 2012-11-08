include('shared.lua')

local EffectColor = Color(200, 200, 255, 255)
local EffectMat = Material("wtiberium/effects/sonicgenerator")

function ENT:Draw()
	
	self:DrawModel()
	WTib.Render(self)
	
	if self.dt.Online then
	
		local Normal = (LocalPlayer():GetPos()-self:GetPos()):GetNormalized()
		render.SetMaterial(EffectMat)
		render.DrawSphere( self:GetPos(), 32, 35, 35, EffectColor )
	
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
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

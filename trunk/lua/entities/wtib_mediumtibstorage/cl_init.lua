include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib_Render(self)
	local tr = LocalPlayer():GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity == self then
		AddWorldTip(self:EntIndex(),,0.5,tr.HitPos,self)
	end
end

function ENT:WTib_GetTooltip()
	return "Tiberium : "..math.Round(tostring(self:GetNWInt("Tib",0)))
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
		self.NextRBUpdate = CurTime()+2
		WTib_UpdateRenderBounds(self)
	end
end
language.Add("wtib_mediumtibstorage","Medium Tiberium Tank")

include('shared.lua')

function ENT:WTib_GetTooltip()
	if self:GetNWBool("Armed",false) then return "" end
	return "Tiberium Missile\nCurrent Warhead : "..tostring(self:GetNWString("Warhead","None"))
end
language.Add("wtib_missile","Missile")
killicon.Add("wtib_missile","killicons/wtib_missile_killicon",Color(255,80,0,255))

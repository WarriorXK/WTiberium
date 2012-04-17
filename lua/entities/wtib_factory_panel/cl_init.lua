include('shared.lua')

local Color_White = Color(255,255,255,255)
local ScreenVect = Vector(-8,-17,73.6)
local ScreenAng = Angle(0,90,90)

function ENT:Draw()
	self:DrawModel()
	cam.Start3D2D(self:LocalToWorld(ScreenVect),self:LocalToWorldAngles(ScreenAng),0.25)
		self:Draw3D2D()
	cam.End3D2D()
end

function ENT:Draw3D2D()
	// Black background
	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(0,0,136,100)

	// The percentage completed
	local Text = "Idle"
	local Percent = 0
	local CurProj = "None"
	if WTib.IsValid(self.dt.Factory) then
		Percent = self.dt.Factory.dt.PercentageComplete
		if self.dt.Factory.dt.IsBuilding then
			Text = "Working, "..Percent.."%"
			
			CurProj = ""
			for k,v in pairs(string.Explode("",WTib.Factory.GetObjectByID(self.dt.Factory.dt.BuildingID).Name)) do
				CurProj = CurProj .. v
				if (k % 22) == 0 then CurProj = CurProj .. "\n" end
			end
			
		end
	end
	draw.DrawText(Text,"Trebuchet18",1,4,Color_White,ALIGN_LEFT)
	draw.DrawText("Current project : ","Trebuchet18",1,36,Color_White,ALIGN_LEFT)
	draw.DrawText(CurProj,"Trebuchet18",1,52,Color_White,ALIGN_LEFT)
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

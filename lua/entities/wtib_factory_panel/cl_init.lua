include('shared.lua')

local Color_White = Color(255, 255, 255, 255)
local ScreenVect = Vector(-8, -17, 73.6)
local ScreenAng = Angle(0, 90, 90)

function ENT:Draw()
	self:DrawModel()
	
	cam.Start3D2D(self:LocalToWorld(ScreenVect), self:LocalToWorldAngles(ScreenAng), 0.25)
		self:Draw3D2D()
	cam.End3D2D()
	
end

function ENT:Draw3D2D()

	render.PushFilterMin(WTib.AntiAliasingLevel:GetInt())
    render.PushFilterMag(WTib.AntiAliasingLevel:GetInt())

		// Black background
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, 136, 100)

		// The percentage completed
		local Text = "Idle"
		local CurProj = "None"
		
		if WTib.IsValid(self.dt.Factory) and self.dt.Factory.dt.IsBuilding then
		
			Text = "Working, " .. self.dt.Factory.dt.PercentageComplete .. "%"
			
			CurProj = ""
			for k,v in pairs(string.Explode("", WTib.Factory.GetObjectByID(self.dt.Factory.dt.BuildingID).Name)) do
			
				CurProj = CurProj .. v
				if (k % 19) == 0 then CurProj = CurProj .. "\n" end
				
			end
			
		end
		
		draw.DrawText(Text, "Trebuchet18", 1, 4, Color_White,ALIGN_LEFT)
		draw.DrawText("Current project :\n" .. CurProj,"Trebuchet18", 1, 36, Color_White,ALIGN_LEFT)
	
	render.PopFilterMin()
    render.PopFilterMag()
	
end

language.Add(WTib.GetClass(ENT), ENT.PrintName)

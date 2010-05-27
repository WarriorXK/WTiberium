include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	cam.Start3D2D(self:LocalToWorld(Vector(9,-15,24)),self:LocalToWorldAngles(Angle(0,90,90)),0.15)
		self:Draw3D2D()
	cam.End3D2D()
	WTib.Render(self)
end

function ENT:Draw3D2D()
	// Black background
	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(0,0,90,90)

	// The percentage completed
	local Text = "Idle"
	if self.dt.PercentageComplete then
		Text = "Working..."
	end
	draw.DrawText(Text,"Trebuchet18",1,4,Color(255,255,255,255),ALIGN_LEFT)
	draw.DrawText("Completed : "..self.dt.PercentageComplete.."%","Trebuchet18",1,20,Color(255,255,255,255),ALIGN_LEFT)
end

function ENT:WTib_GetTooltip()
	local B = "No"
	if self.dt.IsBuilding then
		B = "Yes"
	end
	return self.PrintName.."\nBuilding : "..B.."\nPercentage Complete : "..self.dt.PercentageComplete.."%"
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

usermessage.Hook("wtib_dispenser_openmenu",function(um)
	local Dispenser = um:ReadEntity()
	local Selected
	local MainBox = vgui.Create("DFrame")
	MainBox:SetSize(400,350)
	MainBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
	MainBox:SetTitle("Dispenser Menu")
	MainBox:SetVisible(true)
	MainBox:SetDraggable(false)
	MainBox:ShowCloseButton(false)
	MainBox:MakePopup()
	
	local ExitButton = vgui.Create("DButton")
	ExitButton:SetParent(MainBox)
	ExitButton:SetPos(80,310)
	ExitButton:SetSize(100,30)
	ExitButton:SetText("Close")
	ExitButton.DoClick = function(self)
		RunConsoleCommand("wtib_factory_closemenu",Dispenser:EntIndex())
		MainBox:Remove()
	end

	local BuildButton = vgui.Create("DButton")
	BuildButton:SetParent(MainBox)
	BuildButton:SetPos(220,310)
	BuildButton:SetSize(100,30)
	BuildButton:SetText("Build")
	BuildButton:SetDisabled(true)
	BuildButton.DoClick = function(self)
		RunConsoleCommand("wtib_dispenser_buildobject",Dispenser:EntIndex(),Selected)
		RunConsoleCommand("wtib_dispenser_closemenu",Dispenser:EntIndex())
		MainBox:Remove()
	end
	
	local BuildList = vgui.Create("DListView")
	BuildList:SetParent(MainBox)
	BuildList:SetPos(25,40)
	BuildList:SetSize(350,260)
	BuildList:SetMultiSelect(false)
	local IDColum = BuildList:AddColumn("ID")
	IDColum:SetMinWidth(20)
	IDColum:SetMaxWidth(20)
	BuildList:AddColumn("Entity")
	local BColum = BuildList:AddColumn("Build Time")
	BColum:SetMinWidth(60)
	BColum:SetMaxWidth(60)
	BuildList.OnRowSelected = function(panel,line)
		Selected = BuildList:GetLine(line):GetValue(1)
		BuildButton:SetDisabled(false)
	end
	BuildList.DoDoubleClick = function(panel,line,list)
		Selected = BuildList:GetLine(line):GetValue(1)
		BuildButton.DoClick(BuildButton)
	end
	
	for k,v in pairs(WTib.Dispenser.GetObjects()) do
		BuildList:AddLine(k,v.Name,tostring(math.ceil(100*v.PercentDelay)).." Sec.")
	end
	
end)

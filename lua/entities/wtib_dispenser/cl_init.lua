include('shared.lua')

local Color_White = Color(255,255,255,255)
local ScreenVect = Vector(9,-15,24)
local ScreenAng = Angle(0,90,90)

local LastDispenser
local MainBox

function ENT:Draw()
	self:DrawModel()
	cam.Start3D2D(self:LocalToWorld(ScreenVect),self:LocalToWorldAngles(ScreenAng),0.15)
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
	draw.DrawText(Text,"Trebuchet18",1,4,Color_White,ALIGN_LEFT)
	draw.DrawText("Completed : "..self.dt.PercentageComplete.."%","Trebuchet18",1,20,Color_White,ALIGN_LEFT)
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

net.Receive("wtib_dispenser_openmenu", function( len )

	local Dispenser = net.ReadEntity()

	if Dispenser != LastDispenser and MainBox and MainBox != NULL then
		MainBox:Remove()
		MainBox = nil
		WTib.DebugPrint("New dispenser, new menu")
	end
	LastDispenser = Dispenser

	if !MainBox or MainBox == NULL then

		MainBox = vgui.Create("DFrame")
		MainBox:SetSize(400,350)
		MainBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
		MainBox:SetTitle("Dispenser Menu")
		MainBox:SetVisible(true)
		MainBox:SetDraggable(false)

		WTib.RemovePanelControls(MainBox)
		
		MainBox:MakePopup()
		
		local ExitButton = vgui.Create("DButton")
		ExitButton:SetParent(MainBox)
		ExitButton:SetPos(80,310)
		ExitButton:SetSize(100,30)
		ExitButton:SetText("Close")
		ExitButton.DoClick = function(self)
			MainBox:SetVisible(false)
		end

		local BuildButton = vgui.Create("DButton")
		BuildButton:SetParent(MainBox)
		BuildButton:SetPos(220,310)
		BuildButton:SetSize(100,30)
		BuildButton:SetText("Build")
		BuildButton:SetDisabled(true)
		BuildButton.DoClick = function(self)
			WTib_Dispenser_StartBuild(Dispenser, MainBox.BuildList:GetLine(MainBox.BuildList:GetSelectedLine()):GetValue(1))
			MainBox:SetVisible(false)
		end
		
		local BuildList = vgui.Create("DListView")
		BuildList:SetParent(MainBox)
		BuildList:SetPos(25,40)
		BuildList:SetSize(350,260)
		BuildList:SetMultiSelect(false)
		BuildList.WTib_SortingWay = false
		MainBox.BuildList = BuildList
		local IDColum = BuildList:AddColumn("ID")
		IDColum:SetMinWidth(20)
		IDColum:SetMaxWidth(20)
		BuildList:AddColumn("Entity")
		local BColum = BuildList:AddColumn("Build Time")
		BColum:SetMinWidth(60)
		BColum:SetMaxWidth(60)
		BColum.DoClick = function(panel) // Hate the way this is done, but its the only way AFAIK
		
			local TempList = BuildList:GetLines()
			table.sort(TempList, function(a,b)
				if BuildList.WTib_SortingWay then
					return tonumber(string.Replace(a:GetValue(3), " Sec.","")) < tonumber(string.Replace(b:GetValue(3), " Sec.",""))
				else
					return tonumber(string.Replace(a:GetValue(3), " Sec.","")) > tonumber(string.Replace(b:GetValue(3), " Sec.",""))
				end
			end)
			BuildList.WTib_SortingWay = !BuildList.WTib_SortingWay

			BuildList:Clear()
			for _,v in pairs(TempList) do
				BuildList:AddLine(v:GetValue(1), v:GetValue(2), v:GetValue(3))
			end
			
		end
		BuildList.OnRowSelected = function(panel,line)
			BuildButton:SetDisabled(false)
		end
		BuildList.DoDoubleClick = function(panel,line,list)
			WTib_Dispenser_StartBuild(Dispenser, MainBox.BuildList:GetLine(MainBox.BuildList:GetSelectedLine()):GetValue(1))
			MainBox:SetVisible(false)
		end
		
		for k,v in pairs(WTib.Dispenser.GetObjects()) do
			BuildList:AddLine(k,v.Name,tostring(math.ceil(100*v.PercentDelay)).." Sec.")
		end
		
	else
	
		MainBox.BuildList:Clear()
		for k,v in pairs(WTib.Dispenser.GetObjects()) do
			MainBox.BuildList:AddLine(k,v.Name,tostring(math.ceil(100*v.PercentDelay)).." Sec.")
		end
		
		MainBox:SetVisible(true)
		
	end
end)

function WTib_Dispenser_StartBuild(Dispenser, ProjectID)

	net.Start("wtib_dispenser_buildobject")
		net.WriteEntity(Dispenser)
		net.WriteFloat(ProjectID)
	net.SendToServer()
	
end

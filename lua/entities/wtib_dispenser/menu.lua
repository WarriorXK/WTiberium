
local LastDispenser
local MainBox

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
			local SelectedIndex = MainBox.BuildList:GetSelectedLine() or 1
			local SelectedLine = MainBox.BuildList:GetLine(SelectedIndex)
			local ColumnValue = SelectedLine:GetValue(1)
			WTib_Dispenser_StartBuild(Dispenser, ColumnValue)
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


local LastFactory
local MainBox

net.Receive("wtib_factory_openmenu", function( len )

	local Factory = net.ReadEntity()
	
	if Factory != LastFactory and MainBox and MainBox != NULL then
		MainBox:Remove()
		MainBox = nil
		WTib.DebugPrint("New factory, new menu")
	end
	LastFactory = Factory
	
	if !MainBox or MainBox == NULL or !MainBox.BuildList or MainBox.BuildList == NULL then
	
		MainBox = vgui.Create("DFrame")
		MainBox:SetSize(400,350)
		MainBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
		MainBox:SetTitle("Factory Menu")
		MainBox:SetVisible(true)
		MainBox:SetDraggable(false)
		
		WTib.RemovePanelControls(MainBox)
		
		MainBox:MakePopup()
		
		local ExitButton = vgui.Create("DButton")
		ExitButton:SetParent(MainBox)
		ExitButton:SetPos(40,310)
		ExitButton:SetSize(100,30)
		ExitButton:SetText("Close")
		ExitButton.DoClick = function(self)
			MainBox:SetVisible(false)
		end
		
		local InfoButton = vgui.Create("DButton")
		InfoButton:SetParent(MainBox)
		InfoButton:SetPos(150,310)
		InfoButton:SetSize(100,30)
		InfoButton:SetText("Info")
		InfoButton:SetDisabled(true)
		InfoButton.DoClick = function(self)
			if MainBox.BuildList:GetSelectedLine() then WTib_Factory_InfoMenu(MainBox.BuildList:GetLine(MainBox.BuildList:GetSelectedLine()):GetValue(1)) end
		end
		
		local BuildButton = vgui.Create("DButton")
		BuildButton:SetParent(MainBox)
		BuildButton:SetPos(260,310)
		BuildButton:SetSize(100,30)
		BuildButton:SetText("Build")
		BuildButton:SetDisabled(true)
		BuildButton.DoClick = function(self)
			local SelectedIndex = MainBox.BuildList:GetSelectedLine()
			local SelectedLine = MainBox.BuildList:GetLine(SelectedIndex)
			local ColumnValue = SelectedLine:GetValue(1)
			WTib_Factory_StartBuild(Factory, ColumnValue)
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
			InfoButton:SetDisabled(false)
			BuildButton:SetDisabled(false)
		end
		BuildList.DoDoubleClick = function(panel,line,list)
			WTib_Factory_StartBuild(Factory, MainBox.BuildList:GetLine(MainBox.BuildList:GetSelectedLine()):GetValue(1))
			MainBox:SetVisible(false)
		end
		
		for k,v in pairs(WTib.Factory.GetObjects()) do
			BuildList:AddLine(k,v.Name,tostring(math.ceil(1000*v.PercentDelay) / 10).." Sec.")
		end
		
	else // The menu still exists, refresh the items list and show it again
	
		MainBox.BuildList:Clear()
		for k,v in pairs(WTib.Factory.GetObjects()) do
			MainBox.BuildList:AddLine(k,v.Name,tostring(math.ceil(1000*v.PercentDelay) / 10).." Sec.")
		end
		
		MainBox:SetSize(400,350)
		MainBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
		MainBox:SetVisible(true)
		
	end
	
end)

function WTib_Factory_StartBuild(Factory, ProjectID)

	net.Start("wtib_factory_buildobject")
		net.WriteEntity(Factory)
		net.WriteFloat(ProjectID)
	net.SendToServer()
	
end

function WTib_Factory_InfoMenu(ProjectID)
	local Object = WTib.Factory.GetObjectByID(ProjectID)
	local InfoBox = vgui.Create("DFrame")
	InfoBox:SetSize(400,350)
	InfoBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
	InfoBox:SetTitle("Info "..Object.Name)
	InfoBox:SetVisible(true)
	InfoBox:SetDraggable(false)
	
	WTib.RemovePanelControls(InfoBox)
	
	InfoBox:MakePopup()

	local InfoField = vgui.Create("DTextEntry")
	InfoField:SetParent(InfoBox)
	InfoField:SetMultiline(true)
	InfoField:SetEditable(false)
	InfoField:SetPos(25,40)
	InfoField:SetSize(350,260)
	
	for _,v in pairs(Object.Information) do
		InfoField:SetValue(InfoField:GetValue() .. "\n" .. v)
	end
	
	local ExitButton = vgui.Create("DButton")
	ExitButton:SetParent(InfoBox)
	ExitButton:SetPos(150,310)
	ExitButton:SetSize(100,30)
	ExitButton:SetText("Close")
	ExitButton.DoClick = function(self)
		InfoBox:Remove()
	end
end

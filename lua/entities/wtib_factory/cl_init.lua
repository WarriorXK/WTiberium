include('shared.lua')

local EffectDelay = 0.1

ENT.NextEffect = 0

function ENT:Draw()
	self:DrawModel()
	WTib.Render(self)
end

function ENT:WTib_GetTooltip()
	local B = "No"
	if self.dt.IsBuilding then
		B = "Yes"
	end
	return self.PrintName.."\nBuilding : "..B.."\nPercentage Complete : "..self.dt.PercentageComplete.."%"
end

function ENT:Think()
	if self.NextEffect <= CurTime() and WTib.IsValid(self.dt.CurObject) then
		local Mins = self.dt.CurObject:OBBMins()
		local Maxs = self.dt.CurObject:OBBMaxs()
		local z = Mins.z+(((Maxs.z-Mins.z)/100)*self.dt.PercentageComplete)

		for i=1,4 do
			local Attach = self:GetAttachment(self:LookupAttachment("las"..tostring(i)))
			local ed = EffectData()
				ed:SetStart(self:WorldToLocal(Attach.Pos))
				ed:SetOrigin(Vector(math.random(Mins.z,Maxs.x),math.random(Mins.y,Maxs.y),z))
				ed:SetEntity(self)
				ed:SetMagnitude(EffectDelay)
			util.Effect("wtib_factorylaser",ed)
		end
		
		self.NextEffect = CurTime() + EffectDelay
	end
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)

usermessage.Hook("wtib_factory_openmenu",function(um)
	local Factory = um:ReadEntity()
	local Selected
	local MainBox = vgui.Create("DFrame")
	MainBox:SetSize(400,350)
	MainBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
	MainBox:SetTitle("Factory Menu")
	MainBox:SetVisible(true)
	MainBox:SetDraggable(false)
	MainBox:ShowCloseButton(false)
	MainBox:MakePopup()
	
	local ExitButton = vgui.Create("DButton")
	ExitButton:SetParent(MainBox)
	ExitButton:SetPos(40,310)
	ExitButton:SetSize(100,30)
	ExitButton:SetText("Close")
	ExitButton.DoClick = function(self)
		RunConsoleCommand("wtib_factory_closemenu",Factory:EntIndex())
		MainBox:Remove()
	end
	
	local InfoButton = vgui.Create("DButton")
	InfoButton:SetParent(MainBox)
	InfoButton:SetPos(150,310)
	InfoButton:SetSize(100,30)
	InfoButton:SetText("Info")
	InfoButton:SetDisabled(true)
	InfoButton.DoClick = function(self)
		WTib_Factory_InfoMenu(Selected)
	end
	
	local BuildButton = vgui.Create("DButton")
	BuildButton:SetParent(MainBox)
	BuildButton:SetPos(260,310)
	BuildButton:SetSize(100,30)
	BuildButton:SetText("Build")
	BuildButton:SetDisabled(true)
	BuildButton.DoClick = function(self)
		RunConsoleCommand("wtib_factory_buildobject",Factory:EntIndex(),Selected)
		RunConsoleCommand("wtib_factory_closemenu",Factory:EntIndex())
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
		InfoButton:SetDisabled(false)
		BuildButton:SetDisabled(false)
	end
	BuildList.DoDoubleClick = function(panel,line,list)
		Selected = BuildList:GetLine(line):GetValue(1)
		BuildButton.DoClick(BuildButton)
	end
	
	for k,v in pairs(WTib.Factory.GetObjects()) do
		BuildList:AddLine(k,v.Name,tostring(math.ceil(100*v.PercentDelay)).." Sec.")
	end
	
end)

function WTib_Factory_InfoMenu(id)
	local Object = WTib.Factory.GetObjectByID(id)
	local InfoBox = vgui.Create("DFrame")
	InfoBox:SetSize(400,350)
	InfoBox:SetPos((ScrW()/2)-200,(ScrH()/2)-175)
	InfoBox:SetTitle("Info "..Object.Name)
	InfoBox:SetVisible(true)
	InfoBox:SetDraggable(false)
	InfoBox:ShowCloseButton(false)
	InfoBox:MakePopup()
	
	local InfoList = vgui.Create("DPanelList")
	InfoList:SetParent(InfoBox)
	InfoList:SetPos(25,40)
	InfoList:SetSize(350,260)
	InfoList:SetSpacing(5)
	InfoList:SetPadding(5)
	InfoList:EnableHorizontal(false)
	InfoList:EnableVerticalScrollbar(true)
	for _,v in pairs(Object.Information) do
		local Lab = vgui.Create("DLabel")
		Lab:SetText(v)
		Lab:SizeToContents()
		InfoList:AddItem(Lab)
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

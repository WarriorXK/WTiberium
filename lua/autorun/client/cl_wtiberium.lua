
WTib = WTib or {}

WTib.DynamicLight = CreateClientConVar("wtib_dynamiclight", 1, true, false)
WTib.DynamicLightSize = CreateClientConVar("wtib_dynamiclightsize", 1, true, false)
WTib.CheapDynamicLight = CreateClientConVar("wtib_cheapdynamiclight", 1, true, false)
WTib.AntiAliasingLevel = CreateClientConVar("wtib_antialiasinglevel", 0, true, false)

WTib.UseToolTips = CreateClientConVar("wtib_usetooltips", 1, true, false)
WTib.ToolTipsRange = CreateClientConVar("wtib_tooltipsrange", 512, true, false)
WTib.UseOldToolTips = CreateClientConVar("wtib_useoldtooltips", 1, true, false)

function WTib.ToolTipDraw()

	if !WTib.UseToolTips:GetBool() then return end
	
	// For some reason this is required
	if !IsValid(LocalPlayer()) or !LocalPlayer():IsPlayer() then return end
	
	local tr = LocalPlayer():GetEyeTrace()
	
	if tr and tr.Hit and tr.Entity and IsValid(tr.Entity) and tr.Entity.WTib_GetTooltip and EyePos():Distance(tr.Entity:GetPos()) < WTib.ToolTipsRange:GetInt() then
		
		local p = tr.HitPos
		if WTib.UseOldToolTips:GetBool() then
			p = tr.Entity:GetPos()
		end
		
		local tip = ""
		local status, err = pcall(function() tip = tr.Entity:WTib_GetTooltip() end)
		if !status then tip = err end
		
		AddWorldTip(tr.Entity:EntIndex(), tip, 0.5, p, self)
		
	end
	
end
hook.Add("HUDPaint","WTib.ToolTipDraw",WTib.ToolTipDraw)

function WTib.RemovePanelControls(panel)

	// Bleg, don't like it
	panel.btnClose:SetVisible(false)
	panel.btnMaxim:SetVisible(false)
	panel.btnMinim:SetVisible(false)
	
end

function WTib.AddClientMenu()

	spawnmenu.AddToolCategory("Options", "WTiberium Options", "WTiberium Options")
	
	spawnmenu.AddToolMenuOption("Options", "WTiberium Options", "WTibAdminOptions", "Administrative Options", "", "", WTib.PopulateAdminOptions)
	spawnmenu.AddToolMenuOption("Options", "WTiberium Options", "WTibClientOptions", "Client Options", "", "", WTib.PopulateClientOptions)
	
end
hook.Add("AddToolMenuTabs", "WTib.AddClientMenu", WTib.AddClientMenu)

function WTib.PopulateAdminOptions(Panel)

	Panel:ClearControls()

	if LocalPlayer():IsAdmin() then

		Panel:Button("Remove all Tiberium", "wtib_removealltiberium")

		local DMFS = Panel:NumSlider("Max tiberium field size:", "wtib_defaultmaxfieldsize", 10, 300, 0)
			DMFS:SetToolTip("This option specifies how many crystals a field can have, Default : 50")
		
		local IC = Panel:NumSlider("Tiberium infection chance:", "wtib_infectionchance", 0, 50, 0)
			IC:SetToolTip("This option specifies how big the infection by Tiberium chance is, Default : 3")
		
		// Because the sliders set the values to 0 when they load
		timer.Simple(0.1, function()
		
			RunConsoleCommand("wtib_defaultmaxfieldsize", 50)
			RunConsoleCommand("wtib_infectionchance", 3)
			
		end)
	else
	
		Panel:AddControl("Label", {Text = "This panel is only available for admins"} )
		
	end
	
end

function WTib.PopulateClientOptions(Panel)

	Panel:ClearControls()

	Panel:CheckBox("Enable dynamic lights:", "wtib_dynamiclight")
	Panel:CheckBox("Enable this to disable prop lighting:", "wtib_cheapdynamiclight")
	Panel:NumSlider("Dynamic light size:", "wtib_dynamiclightsize", 1, 10, 0)
	
	//Panel:AddSpacer() // Non existant
	
	Panel:NumSlider("Anti Aliasing level :", "wtib_antialiasinglevel", 1, 4, 0)
	
	//Panel:AddSpacer() // Non existant
	
	Panel:CheckBox("Use tooltips on WTiberium entities:", "wtib_usetooltips")
	Panel:CheckBox("Use the old tooltips on WTiberium entities:", "wtib_useoldtooltips")
	Panel:NumSlider("Tooltips range:", "wtib_tooltipsrange", 128, 2048, 0)
	
end

local NotifySounds = {}
NotifySounds[NOTIFY_GENERIC] = function() return "ambient/water/drip" .. math.random(1, 4) .. ".wav" end
NotifySounds[NOTIFY_ERROR] = function() return "buttons/button10.wav" end

function WTib.Notify(txt, typ)
	
	notification.AddLegacy( txt, typ, 5 )
	
	if NotifySounds[typ] then surface.PlaySound(NotifySounds[typ]()) end
	
end

net.Receive("wtib_sendnotification", function( len )

	local err = net.ReadInt(4)
	local txt = net.ReadString()
	
	WTib.Notify(txt, err)

end)

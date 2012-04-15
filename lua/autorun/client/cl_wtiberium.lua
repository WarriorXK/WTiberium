
WTib = WTib or {}

WTib.DynamicLight = CreateClientConVar("wtib_dynamiclight",1,true,false)
WTib.DynamicLightSize = CreateClientConVar("wtib_dynamiclightsize",1,true,false)

WTib.UseToolTips = CreateClientConVar("wtib_usetooltips",1,true,false)
WTib.ToolTipsRange = CreateClientConVar("wtib_tooltipsrange",512,true,false)
WTib.UseOldToolTips = CreateClientConVar("wtib_useoldtooltips",1,true,false)

function WTib.ToolTipDraw()
	if !WTib.UseToolTips:GetBool() then return end
	local tr = LocalPlayer():GetEyeTrace()
	if tr.Hit and tr.Entity and tr.Entity.WTib_GetTooltip and EyePos():Distance(tr.Entity:GetPos()) < WTib.ToolTipsRange:GetInt() then
		
		local p = tr.HitPos
		if WTib.UseOldToolTips:GetBool() then
			p = tr.Entity:GetPos()
		end
		
		local tip = ""
		local status, err = pcall(function() tip = tr.Entity:WTib_GetTooltip() end)
		if !status then tip = err end
		
		AddWorldTip(tr.Entity:EntIndex(),tip,0.5,p,self)
	end
end
hook.Add("HUDPaint","WTib.ToolTipDraw",WTib.ToolTipDraw)

function WTib.RemovePanelControls(panel)
	// Bleg, don't like it
	panel.btnClose:SetVisible(false)
	panel.btnMaxim:SetVisible(false)
	panel.btnMinim:SetVisible(false)
end

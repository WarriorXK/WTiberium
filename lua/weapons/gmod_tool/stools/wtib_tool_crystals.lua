local ToolClass = "wtib_tool_crystals"

TOOL.Category		= "WTiberium"
TOOL.Name			= "#tool." .. ToolClass .. ".listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = ""

if ( CLIENT ) then
    language.Add( "tool." .. ToolClass .. ".name", "Crystal Spawner" )
    language.Add( "tool." .. ToolClass .. ".listname", "Crystal Spawner" )
    language.Add( "tool." .. ToolClass .. ".desc", "Spawns the selected Tiberium crystal." )
    language.Add( "tool." .. ToolClass .. ".0", "Primary: Spawn the selected entity" )
	
	net.Receive("wtib_crystalstool_error", function( len )
	
		local txt = net.ReadString()
		
		notification.AddLegacy( txt, NOTIFY_ERROR, 5 )
		surface.PlaySound( "buttons/button10.wav" )
	
	end)
	
elseif SERVER then

	util.AddNetworkString("wtib_crystalstool_error")
	
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	
	local Class = self:GetClientInfo( "type" )
	local ValidClass = false
	
	for k,v in pairs(list.Get("WTib_Tools_Crystals")) do
		
		if v.wtib_tool_crystals_type == Class then
		
			ValidClass = true
			break
		
		end
		
	end
	
	if !ValidClass then
	
		net.Start("wtib_crystalstool_error")
			net.WriteString("Invalid crystal, please select a crystal from the menu")
		net.Send(self:GetOwner())
		
		return false
	end

	if !WTib.CanTiberiumGrow(Class, tr.HitPos) then
	
		net.Start("wtib_crystalstool_error")
			net.WriteString("Invalid crystal location")
		net.Send(self:GetOwner())

		return false
	end
	
	local ent = WTib.CreateTiberium(nil , Class, tr, self:GetOwner())
	
	if IsValid(ent) then
		
		undo.Create(Class)
			undo.AddEntity(ent)
			undo.SetPlayer(self:GetOwner())
			undo.SetCustomUndoText("Undone " .. ent.PrintName)
		undo.Finish()
		
		return true
		
	else
		
		return false
		
	end
	
end

function TOOL:RightClick(tr) end

function TOOL.BuildCPanel(CPanel)

	CPanel:AddControl("Header", { Text = "#Tool." .. ToolClass .. ".name", Description = "Select a crystal to spawn" })

	CPanel:AddControl("ComboBox", {Label = "Crystal type", MenuButton = 0, Options=list.Get("WTib_Tools_Crystals")} )
	
end

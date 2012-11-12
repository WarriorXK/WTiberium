local ToolClass = "wtib_tool_crystals"

TOOL.Category		= "WTiberium"
TOOL.Name			= "#tool." .. ToolClass .. ".listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = "0"

if ( CLIENT ) then
    language.Add( "tool." .. ToolClass .. ".name", "Crystal Spawner" )
    language.Add( "tool." .. ToolClass .. ".listname", "Crystal Spawner" )
    language.Add( "tool." .. ToolClass .. ".desc", "Spawns the selected Tiberium crystal." )
    language.Add( "tool." .. ToolClass .. ".0", "Primary: Spawn the selected entity" )
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	
	local EntType = self:GetClientNumber( "type" )
	local Class = WTib.Stools.Crystals.GetClassOptions()[EntType]
	
	if !WTib.CanTiberiumGrow(Class, tr.HitPos) then
		self:GetOwner():SendLua([[notification.AddLegacy( "Invalid crystal location", NOTIFY_ERROR, 5 ); surface.PlaySound( "buttons/button10.wav" )]])
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

	CPanel:AddControl("ComboBox", {Label = "Crystal type", MenuButton = 0, Options=WTib.Stools.Crystals.GetOptions()} )
	
end

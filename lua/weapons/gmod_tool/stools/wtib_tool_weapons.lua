local ToolClass = "wtib_tool_weapons"

TOOL.Category		= "WTiberium"
TOOL.Name			= "#tool." .. ToolClass .. ".listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = ""

if ( CLIENT ) then
    language.Add( "tool." .. ToolClass .. ".name", "Weapons Spawner" )
    language.Add( "tool." .. ToolClass .. ".listname", "Weapons Spawner" )
    language.Add( "tool." .. ToolClass .. ".desc", "Spawns the selected weapon." )
    language.Add( "tool." .. ToolClass .. ".0", "Primary: Spawn the selected entity" )
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	
	local Class = self:GetClientInfo( "type" )
	if Class == "" then return false end

	local ent = WTib.SpawnFunction( self:GetOwner(), tr, Class )
	
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

	CPanel:AddControl("Header", { Text = "#Tool." .. ToolClass .. ".name", Description = "Select a weapon to spawn" })

	CPanel:AddControl("ComboBox", {Label = "Weapon type", MenuButton = 0, Options=list.Get("WTib_Tools_Weapons")} )
	
end

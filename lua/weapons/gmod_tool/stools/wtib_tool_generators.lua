local ToolClass = "wtib_tool_generators"

TOOL.Category		= "WTiberium"
TOOL.Name			= "#tool." .. ToolClass .. ".listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = "0"

if ( CLIENT ) then
    language.Add( "tool." .. ToolClass .. ".name", "Generator Spawner" )
    language.Add( "tool." .. ToolClass .. ".listname", "Generator Spawner" )
    language.Add( "tool." .. ToolClass .. ".desc", "Spawns the selected generator." )
    language.Add( "tool." .. ToolClass .. ".0", "Primary: Spawn the selected entity" )
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	
	local EntType = self:GetClientNumber( "type" )
	local Class = WTib.Stools.Generators.GetClassOptions()[EntType]

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

	CPanel:AddControl("Header", { Text = "#Tool." .. ToolClass .. ".name", Description = "Select a generator to spawn" })

	CPanel:AddControl("ComboBox", {Label = "Generator type", MenuButton = 0, Options=WTib.Stools.Generators.GetOptions()} )
	
end

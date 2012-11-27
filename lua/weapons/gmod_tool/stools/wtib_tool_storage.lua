local ToolClass = "wtib_tool_storage"

TOOL.Category		= "WTiberium"
TOOL.Name			= "#tool." .. ToolClass .. ".listname"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = ""

if CLIENT then
    language.Add( "tool." .. ToolClass .. ".name", "Storage tank Spawner" )
    language.Add( "tool." .. ToolClass .. ".listname", "Storage tank Spawner" )
    language.Add( "tool." .. ToolClass .. ".desc", "Spawns the selected storage device." )
    language.Add( "tool." .. ToolClass .. ".0", "Primary: Spawn the selected entity" )
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	
	local Class = self:GetClientInfo( "type" )
	local ValidClass = false
	
	for k,v in pairs(list.Get("WTib_Tools_Storage")) do
		
		if v.wtib_tool_storage_type == Class then
		
			ValidClass = true
			break
		
		end
		
	end
	
	if !ValidClass then
	
		WTib.SendNotification(self:GetOwner(), "Invalid storage unit, please select a storage unit from the menu", NOTIFY_ERROR)
		return false
		
	end

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

	CPanel:AddControl("Header", { Text = "#Tool." .. ToolClass .. ".name", Description = "Select a storage device to spawn" })

	CPanel:AddControl("ComboBox", {Label = "Storage tank type", MenuButton = 0, Options=list.Get("WTib_Tools_Storage")} )
	
end

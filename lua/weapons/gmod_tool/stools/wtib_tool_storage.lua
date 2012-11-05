TOOL.Category		= "WTiberium"
TOOL.Name			= "Storage tank Spawner"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "type" ] = "0"

local ToolClass = "wtib_tool_storage"

if ( CLIENT ) then
    language.Add( "Tool." .. ToolClass .. ".name", TOOL.Name )
    language.Add( "Tool." .. ToolClass .. ".desc", "Spawns the selected storage device." )
    language.Add( "Tool." .. ToolClass .. ".0", "Primary: Spawn the selected entity" )
end

local ToolOptions_Class = {}
local ToolOptions = {}

local ToolOptionsInc = 0

function WTib_StorageTool_AddCrystal(class, name)
	
	ToolOptions[name] = { wtib_tool_storage_type = ToolOptionsInc }
	ToolOptions_Class[ToolOptionsInc] = class
	
	ToolOptionsInc = ToolOptionsInc + 1
	
	return ToolOptionsInc - 1
	
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	
	local EntType = self:GetClientNumber( "type" )
	local Class = ToolOptions_Class[EntType]

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

	CPanel:AddControl("Header", { Text = "#Tool." .. ToolClass .. ".name", Description = "Select a storage device to spawn" })

	CPanel:AddControl("ComboBox", {Label = "Storage tank type", MenuButton = 0, Options=ToolOptions} )
	
end

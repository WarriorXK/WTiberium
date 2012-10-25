TOOL.Category		= "WTiberium"
TOOL.Name			= "Crystal Spawner"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Tools"

TOOL.ClientConVar[ "type" ] = "0"

local ToolClass = "wtib_crystaltool"

if ( CLIENT ) then
    language.Add( "Tool." .. ToolClass .. ".name", TOOL.Name )
    language.Add( "Tool." .. ToolClass .. ".desc", "Spawns the selected Tiberium crystal." )
    language.Add( "Tool." .. ToolClass .. ".0", "Primary: Spawn the selected entity" )
end

local ToolOptions_Class = {}
local ToolOptions = {}

local ToolOptionsInc = 0

function WTib_CrystalTool_AddCrystal(class, name)
	
	ToolOptions[name] = { wtib_crystaltool_type = ToolOptionsInc }
	ToolOptions_Class[ToolOptionsInc] = class
	
	ToolOptionsInc = ToolOptionsInc + 1
	
	return ToolOptionsInc - 1
	
end

function TOOL:LeftClick(tr)
	if !tr.Hit then return false end
	
	local TibType = self:GetClientNumber( "type" )
	local Class = ToolOptions_Class[TibType]

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

	CPanel:AddControl("ComboBox", {Label = "Crystal type", MenuButton = 0, Options=ToolOptions} )
	
end

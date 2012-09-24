
local LastWarheadFactory
local MainBox

net.Receive("wtib_warheadfactory_openmenu", function( len )
	
	local Factory = net.ReadEntity()
	
	if Factory != LastWarheadFactory and MainBox and MainBox != NULL then
		MainBox:Remove()
		MainBox = nil
		WTib.DebugPrint("New factory, new menu")
	end
	LastWarheadFactory = Factory
	
	if !MainBox or MainBox == NULL then
	
		MainBox = vgui.Create("DFrame")
		MainBox:SetSize( 400, 200 )
		MainBox:SetPos((ScrW() / 2) - 200, (ScrH() / 2) - 175 )
		MainBox:SetTitle("Warhead designer menu")
		MainBox:SetVisible(true)
		MainBox:SetDraggable(false)
		
		WTib.RemovePanelControls(MainBox)
		
		MainBox:MakePopup()
		
		local ExitButton = vgui.Create("DButton", MainBox)
		ExitButton:SetPos( 40, 160 )
		ExitButton:SetSize( 100, 30 )
		ExitButton:SetText("Close")
		ExitButton.DoClick = function(self)
			MainBox:SetVisible(false)
		end
		
		local function SliderValueChanged( Panel, Value )
			WTib_WarheadFactory_AdjustLabel()
		end
		
		local RawSlider = vgui.Create( "DNumSlider", MainBox )
		RawSlider:SetPos( 25, 45 )
		RawSlider:SetWide( 350 )
		RawSlider:SetValue( 25 )
		RawSlider:SetText( "Raw Tiberium" )
		RawSlider:SetMin( 0 )
		RawSlider:SetMax( 100 )
		RawSlider:SetDecimals( 1 )
		RawSlider.ValueChanged = SliderValueChanged
		MainBox.RawSlider = RawSlider
		
		local RefinedSlider = vgui.Create( "DNumSlider", MainBox )
		RefinedSlider:SetPos( 25, 65 )
		RefinedSlider:SetWide( 350 )
		RefinedSlider:SetValue( 25 )
		RefinedSlider:SetText( "Refined Tiberium" )
		RefinedSlider:SetMin( 0 )
		RefinedSlider:SetMax( 100 )
		RefinedSlider:SetDecimals( 1 )
		RefinedSlider.ValueChanged = SliderValueChanged
		MainBox.RefinedSlider = RefinedSlider
		
		local ChemicalSlider = vgui.Create( "DNumSlider", MainBox )
		ChemicalSlider:SetPos( 25, 85 )
		ChemicalSlider:SetWide( 350 )
		ChemicalSlider:SetValue( 25 )
		ChemicalSlider:SetText( "Tiberium Chemicals" )
		ChemicalSlider:SetMin( 0 )
		ChemicalSlider:SetMax( 100 )
		ChemicalSlider:SetDecimals( 1 )
		ChemicalSlider.ValueChanged = SliderValueChanged
		MainBox.ChemicalSlider = ChemicalSlider
		
		local LiquidSlider = vgui.Create( "DNumSlider", MainBox )
		LiquidSlider:SetPos( 25, 105 )
		LiquidSlider:SetWide( 350 )
		LiquidSlider:SetValue( 25 )
		LiquidSlider:SetText( "Liquid Tiberium" )
		LiquidSlider:SetMin( 0 )
		LiquidSlider:SetMax( 100 )
		LiquidSlider:SetDecimals( 1 )
		LiquidSlider.ValueChanged = SliderValueChanged
		MainBox.LiquidSlider = LiquidSlider
		
		local BuildButton = vgui.Create("DButton", MainBox)
		BuildButton:SetPos( 260, 160 )
		BuildButton:SetSize( 100, 30 )
		BuildButton:SetText("Build")
		BuildButton.DoClick = function(self)
			WTib_WarheadFactory_StartBuild(Factory, RawSlider:GetValue(), RefinedSlider:GetValue(), ChemicalSlider:GetValue(), LiquidSlider:GetValue())
			MainBox:SetVisible(false)
		end
		MainBox.BuildButton = BuildButton
		
		local ValueLabel = vgui.Create("DLabel", MainBox)
		ValueLabel:SetPos( 35, 135 )
		MainBox.ValueLabel = ValueLabel
		WTib_WarheadFactory_AdjustLabel()
	
	else // The menu still exists, refresh the items list and show it again

		MainBox:SetSize( 400, 200 )
		MainBox:SetPos( (ScrW() / 2) - 200, (ScrH() / 2) - 175)
		MainBox:SetVisible(true)
		
	end
	
end)

function WTib_WarheadFactory_AdjustLabel()

	local Total = MainBox.RawSlider:GetValue() + MainBox.RefinedSlider:GetValue() + MainBox.ChemicalSlider:GetValue() + MainBox.LiquidSlider:GetValue()

	if Total == 100 then
	
		MainBox.ValueLabel:SetText("Total value is " .. Total)
		MainBox.ValueLabel:SetColor(Color( 0, 200, 0, 255))
		MainBox.BuildButton:SetEnabled(true)
	
	else
	
		MainBox.ValueLabel:SetText("Total value is " .. Total)
		MainBox.ValueLabel:SetColor(Color( 200, 0, 0, 255))
		MainBox.BuildButton:SetEnabled(false)
	
	end
	
	MainBox.ValueLabel:SizeToContents()

end

function WTib_WarheadFactory_StartBuild(Factory, Raw, Refined, Chemical, Liquid)
	
	net.Start("wtib_warheadfactory_buildwarhead")
		net.WriteEntity(Factory)
		net.WriteFloat(Raw)
		net.WriteFloat(Refined)
		net.WriteFloat(Chemical)
		net.WriteFloat(Liquid)
	net.SendToServer()
	
end

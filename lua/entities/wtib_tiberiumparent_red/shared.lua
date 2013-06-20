ENT.Type			= "anim"
ENT.Base			= "wtib_tiberiumparent_base"
ENT.PrintName		= "Tiberium Parent Red"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true
ENT.IsTiberiumParent= true

ENT.Reproduce_TiberiumRequired	= 1400
ENT.Reproduce_TiberiumDrained	= 500
ENT.Reproduce_Delay				= 30

ENT.TiberiumStartAmount	= 400
ENT.MaxTiberiumAmount	= 5000
ENT.TiberiumColor		= Color(255,0,0,200)
ENT.ClassToSpawn		= "wtib_tiberium_red"
ENT.Models =	{
					"models/tiberium/tiberium_parent.mdl"
				}

ENT.Growth_Addition	= 25
ENT.Growth_Delay	= 12.5

ENT.DecalSize	= 1
ENT.Decal		= ""

ENT.RenderMode	= RENDERMODE_TRANSTEXTURE

list.Set("WTib_Tools_Crystals", ENT.PrintName, { wtib_tool_crystals_type = WTib.GetClass(ENT) })

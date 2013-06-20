ENT.Type			= "anim"
ENT.Base			= "wtib_tiberiumparent_base"
ENT.PrintName		= "Tiberium Parent Green"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true
ENT.IsTiberiumParent= true

ENT.Reproduce_TiberiumRequired	= 1000
ENT.Reproduce_TiberiumDrained	= 300
ENT.Reproduce_Delay				= 30

ENT.TiberiumStartAmount	= 400
ENT.MaxTiberiumAmount	= 2000
ENT.TiberiumColor		= Color(0,255,0,200)
ENT.ClassToSpawn		= "wtib_tiberium_green"
ENT.Models =	{
					"models/tiberium/tiberium_parent.mdl"
				}

ENT.Growth_Addition	= 30
ENT.Growth_Delay	= 7.5

ENT.DecalSize	= 1
ENT.Decal		= ""

ENT.RenderMode	= RENDERMODE_TRANSTEXTURE

list.Set("WTib_Tools_Crystals", ENT.PrintName, { wtib_tool_crystals_type = WTib.GetClass(ENT) })

ENT.Type			= "anim"
ENT.Base			= "wtib_tiberiumparent_base"
ENT.PrintName		= "Tiberium Parent Green"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true
ENT.IsTiberiumParent= true

ENT.ShouldCollide = true
ENT.RenderMode = RENDERMODE_TRANSTEXTURE

ENT.Reproduce_TiberiumRequired = 1000
ENT.Reproduce_TiberiumDrained = 300
ENT.Reproduce_Delay = 30

ENT.TiberiumStartAmount = 400
ENT.MaxTiberiumAmount = 2000
ENT.TiberiumColor = Color(0,255,0,200)
ENT.ClassToSpawn = "wtib_tiberium_green"
ENT.Models =	{
					"models/Tiberium/tiberium_parent.mdl"
				}

ENT.Growth_Addition = 30
ENT.Growth_Delay = 7.5

ENT.DecalSize = 1
ENT.Decal = ""

list.Set("WTib_Tools_Crystals", ENT.PrintName, { wtib_tool_crystals_type = WTib.GetClass(ENT) })

ENT.Type			= "anim"
ENT.Base			= "wtib_tiberiumparent_base"
ENT.PrintName		= "Tiberium Parent Blue"
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

ENT.Reproduce_TiberiumRequired = 1200
ENT.Reproduce_TiberiumDrained = 400
ENT.Reproduce_Delay = 30

ENT.TiberiumStartAmount = 400
ENT.MaxTiberiumAmount = 3500
ENT.TiberiumColor = Color(0,0,255,200)
ENT.ClassToSpawn = "wtib_tiberium_blue"
ENT.Models =	{
					"models/Tiberium/tiberium_parent.mdl"
				}

ENT.Growth_Addition = 27.5
ENT.Growth_Delay = 10

ENT.DecalSize = 1
ENT.Decal = ""

WTib_CrystalTool_AddCrystal( WTib.GetClass(ENT), ENT.PrintName )

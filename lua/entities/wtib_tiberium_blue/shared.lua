ENT.Type			= "anim"
ENT.Base			= "wtib_tiberium_base"
ENT.PrintName		= "Tiberium Blue"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true

ENT.Damage_Explode_RequiredDamage	= 40
ENT.Damage_ExplosionDelay			= 1.2
ENT.Damage_Explode_Damage			= 50
ENT.Damage_Explode_Size				= 100
ENT.Damage_Explosive				= true

ENT.Reproduce_TiberiumRequired	= 1200
ENT.Reproduce_TiberiumDrained	= 400
ENT.Reproduce_MaxProduces		= 5
ENT.Reproduce_Delay				= 30

ENT.TiberiumStartAmount	= 400
ENT.MaxTiberiumAmount	= 3500
ENT.TiberiumColor		= Color(0,0,255,0)
ENT.ClassToSpawn		= "wtib_tiberium_blue"
ENT.Models =	{
					"models/Tiberium/tiberium_crystal1.mdl",
					"models/Tiberium/tiberium_crystal3.mdl"
				}

ENT.Growth_Addition	= 27.5
ENT.Growth_Delay	= 10

ENT.DecalSize	= 1
ENT.Decal		= ""

list.Set("WTib_Tools_Crystals", ENT.PrintName, { wtib_tool_crystals_type = WTib.GetClass(ENT) })

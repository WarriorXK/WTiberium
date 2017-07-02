ENT.Type			= "anim"
ENT.Base			= "wtib_tiberium_base"
ENT.PrintName		= "Tiberium Red"
ENT.Author			= "kialtia/WarriorXK"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true

ENT.Damage_Explode_RequiredDamage	= 30
ENT.Damage_ExplosionDelay			= 0.7
ENT.Damage_Explode_Damage			= 120
ENT.Damage_Explode_Size				= 250
ENT.Damage_Explosive				= true

ENT.Reproduce_TiberiumRequired	= 1400
ENT.Reproduce_TiberiumDrained	= 500
ENT.Reproduce_MaxProduces		= 5
ENT.Reproduce_Delay				= 30

ENT.TiberiumStartAmount	= 400
ENT.MaxTiberiumAmount	= 5000
ENT.TiberiumColor		= Color(255,0,0,0)
ENT.ClassToSpawn		= "wtib_tiberium_red"
ENT.Models =	{
					"models/tiberium/tiberium_crystal1.mdl",
					"models/tiberium/tiberium_crystal3.mdl"
				}

ENT.Growth_Addition	= 25
ENT.Growth_Delay	= 12.5

ENT.DecalSize	= 1
ENT.Decal		= ""

list.Set("WTib_Tools_Crystals", ENT.PrintName, { wtib_tool_crystals_type = WTib.GetClass(ENT) })

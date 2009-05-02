ENT.Type			= "anim"
ENT.PrintName		= "Base Tiberium"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true
ENT.CanBeHarvested	= true

-- Take over the following variables when making your own tiberium ent.
ENT.TiberiumDraimOnReproduction	= 3000 -- The amount of tiberium drained when it replicates.
ENT.MinReprodutionTibRequired	= 3800 -- The minimum amount of tiberium required before it attempts to replicate.
ENT.RemoveOnNoTiberium			= true -- Remove the ent when the tiberium amount reaches 0?
ENT.IgnoreExpBurDamage			= false -- Should we not gain extra tiberium from explosion/burn damage?
ENT.DisableAntiPickup			= false -- Disable anti physgun on this ent?
ENT.ReproductionRate			= 30 -- Howmuch seconds are being added to the console command of the respawn rate for this ent.
ENT.MinTiberiumGain				= 15 -- The minimum amount of tiberium added per turn.
ENT.MaxTiberiumGain				= 50 -- The maximum amount of tiberium added per turn.
ENT.ShouldReproduce				= true -- Should this entity reproduce when ready?
ENT.ReproduceDelay				= 60 -- The delay between reproductions.
ENT.TiberiumAdd					= true -- Should tiberium be added every 3 seconds?
ENT.MaxTiberium					= 4000 -- The maximum amount of tiberium this entity can have.
ENT.DynLight					= true -- Should we make a dynamic light at our position?
ENT.Gas							= true -- Should this entity emit gas?
ENT.r							= 255 -- The red color.
ENT.g							= 0 -- The green color.
ENT.b							= 0 -- The blue color.
ENT.a							= 150 -- The alpha color.


if SERVER then
	AddCSLuaFile("sh_wtiberium.lua")
	AddCSLuaFile("client/cl_wtiberium.lua")
	AddCSLuaFile("client/cl_wtiberium_addons.lua")
end

WTib = WTib or {}

/*
	Factory functions
*/

WTib.Factory = {}
WTib.Factory.Objects = {}

function WTib.Factory.AddObject(tab)
	local id = table.Count(WTib.Factory.Objects)+1
	WTib.Factory.Objects[id] = tab
	table.sort(WTib.Factory.Objects, function(a,b) return a.Name < b.Name end)
	return id
end

function WTib.Factory.RemoveObject(id)
	WTib.Factory.Objects[id] = nil
end

function WTib.Factory.GetObjects()
	return WTib.Factory.Objects
end

function WTib.Factory.GetObjectByID(id)
	return WTib.Factory.Objects[id]
end

/*
	Dispenser functions
*/

WTib.Dispenser = {}
WTib.Dispenser.Objects = {}

function WTib.Dispenser.AddObject(tab)
	local id = table.Count(WTib.Dispenser.Objects)+1
	WTib.Dispenser.Objects[id] = tab
	table.sort(WTib.Dispenser.Objects, function(a,b) return a.Name < b.Name end)
	return id
end

function WTib.Dispenser.RemoveObject(id)
	WTib.Dispenser.Objects[id] = nil
end

function WTib.Dispenser.GetObjects()
	return WTib.Dispenser.Objects
end

function WTib.Dispenser.GetObjectByID(id)
	return WTib.Dispenser.Objects[id]
end

/*
	STool functions
*/

WTib.Stools = {}

/*
	Crystal spawner stool
*/

WTib.Stools.Crystals = {}
WTib.Stools.Crystals.Classes = {}
WTib.Stools.Crystals.Options = {}

WTib.Stools.Crystals.Inc = 0

function WTib.Stools.Crystals.AddCrystal(class, name)
	
	WTib.Stools.Crystals.Options[name] = { wtib_tool_crystals_type = WTib.Stools.Crystals.Inc }
	WTib.Stools.Crystals.Classes[WTib.Stools.Crystals.Inc] = class
	
	WTib.Stools.Crystals.Inc = WTib.Stools.Crystals.Inc + 1
	
	return WTib.Stools.Crystals.Inc - 1
	
end

function WTib.Stools.Crystals.GetOptions()
	return WTib.Stools.Crystals.Options
end

function WTib.Stools.Crystals.GetClassOptions()
	return WTib.Stools.Crystals.Classes
end

/*
	Generator STool
*/

WTib.Stools.Generators = {}
WTib.Stools.Generators.Classes = {}
WTib.Stools.Generators.Options = {}

WTib.Stools.Generators.Inc = 0

function WTib.Stools.Generators.AddGenerator(class, name)
	
	WTib.Stools.Generators.Options[name] = { wtib_tool_generators_type = WTib.Stools.Generators.Inc }
	WTib.Stools.Generators.Classes[WTib.Stools.Generators.Inc] = class
	
	WTib.Stools.Generators.Inc = WTib.Stools.Generators.Inc + 1
	
	return WTib.Stools.Generators.Inc - 1
	
end

function WTib.Stools.Generators.GetOptions()
	return WTib.Stools.Generators.Options
end

function WTib.Stools.Generators.GetClassOptions()
	return WTib.Stools.Generators.Classes
end

/*
	Storage STool
*/

WTib.Stools.Storage = {}
WTib.Stools.Storage.Classes = {}
WTib.Stools.Storage.Options = {}

WTib.Stools.Storage.Inc = 0

function WTib.Stools.Storage.AddStorage(class, name)
	
	WTib.Stools.Storage.Options[name] = { wtib_tool_storage_type = WTib.Stools.Storage.Inc }
	WTib.Stools.Storage.Classes[WTib.Stools.Storage.Inc] = class
	
	WTib.Stools.Storage.Inc = WTib.Stools.Storage.Inc + 1
	
	return WTib.Stools.Storage.Inc - 1
	
end

function WTib.Stools.Storage.GetOptions()
	return WTib.Stools.Storage.Options
end

function WTib.Stools.Storage.GetClassOptions()
	return WTib.Stools.Storage.Classes
end

/*
	Weapons STool
*/

WTib.Stools.Weapons = {}
WTib.Stools.Weapons.Classes = {}
WTib.Stools.Weapons.Options = {}

WTib.Stools.Weapons.Inc = 0

function WTib.Stools.Weapons.AddWeapon(class, name)
	
	WTib.Stools.Weapons.Options[name] = { wtib_tool_weapons_type = WTib.Stools.Weapons.Inc }
	WTib.Stools.Weapons.Classes[WTib.Stools.Weapons.Inc] = class
	
	WTib.Stools.Weapons.Inc = WTib.Stools.Weapons.Inc + 1
	
	return WTib.Stools.Weapons.Inc - 1
	
end

function WTib.Stools.Weapons.GetOptions()
	return WTib.Stools.Weapons.Options
end

function WTib.Stools.Weapons.GetClassOptions()
	return WTib.Stools.Weapons.Classes
end

/*
	Debug things
*/

WTib.Debug = false

function WTib.DebugEffect(...)
	if WTib.Debug then
		util.Effect(...)
	end
end

function WTib.DebugPrint(...)
	if WTib.Debug then
		print(...)
	end
end

function WTib.DebugPrintTable(...)
	if WTib.Debug then
		PrintTable(...)
	end
end

/*
	Hooks
*/

function WTib.PhysgunPickup(ply,ent)
	if ent.IsTiberium or ent.NoPhysicsPickup then
		return false
	end
end
hook.Add("PhysgunPickup","WTib.PhysgunPickup",WTib.PhysgunPickup)

function WTib.ShouldCollide(ent1,ent2)
	if (ent1.IsTiberium and !ent1.ShouldCollide) or (ent2.IsTiberium and !ent2.ShouldCollide) then
		return false
	end
end
hook.Add("ShouldCollide","WTib.ShouldCollide",WTib.ShouldCollide)


/*
	Misc things
*/

function WTib.Trace(...) // In case we'd ever need to replace it
	return util.QuickTrace(...)
end

function WTib.GetClass(ENT)
	local Class = ENT.ClassName
	if Class == nil or Class == "" then Class = string.Replace(string.Replace(ENT.Folder,"entities/",""),"weapons/","") end
	return Class
end

function WTib.IsValid(e)
	return e and e.IsValid and e:IsValid()
end

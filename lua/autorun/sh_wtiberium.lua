
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
	RD and Wire functions
*/

function WTib.HasResourceAPI()
	return type(RESOURCES) == "table"
end

function WTib.HasRD2()
	return RD2Version != nil
end

function WTib.HasRD3()
	if WTib.RD3 != nil then return true end
	if CAF then
		if CAF.Addons then
			if (CAF.Addons.Get("Resource Distribution")) then
				WTib.RD3 = CAF.Addons.Get("Resource Distribution")
				return true
			end
		else
			if CAF and CAF.GetAddon and CAF.GetAddon("Resource Distribution") then
				WTib.RD3 = CAF.GetAddon("Resource Distribution")
				return true
			end
		end
	end
	return false
end

/*
	Misc things
*/

function WTib.Trace(...) // In case we'd ever need to replace it
	return util.QuickTrace(...)
end

function WTib.GetClass(ENT)
	return string.Replace(string.Replace(ENT.Folder,"entities/",""),"weapons/","")
end

function WTib.IsValid(e)
	return e and e.IsValid and e:IsValid()
end

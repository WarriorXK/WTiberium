
if SERVER then
	AddCSLuaFile("sh_wtiberium.lua")
	AddCSLuaFile("client/cl_wtiberium.lua")
	AddCSLuaFile("client/cl_wtiberium_addons.lua")
end

WTib = WTib or {}

function WTib.CanTiberiumGrow(class, pos)
	local Call = hook.Call("WTib_TiberiumCanGrow",GAMEMODE,class,pos)
	if Call == false then return false end
	return true
end

function WTib.TiberiumCanGrow(class,pos)
	for _,v in pairs(ents.FindInSphere(pos,400)) do
		if v.IsTiberium then
			local EntTable = scripted_ents.GetStored(class)
			local Dist = v:GetPos():Distance(pos)
			
			WTib.DebugPrint("'" .. class .. "' - '" .. v:GetClass() .. "' - '" .. tostring(EntTable.t.ClassToSpawn) .. "'")
			
			if class == v:GetClass() or (type(EntTable) == "table" and (EntTable.t.ClassToSpawn == v:GetClass() or EntTable.t.ClassToSpawn == class)) then
				if Dist <= 80 then
					WTib.DebugPrint("false (Closer than 80)")
					return false
				end
			elseif Dist <= 400 then
				WTib.DebugPrint("false (Closer than 400)")
				return false
			end
			
		end
	end
end
hook.Add("WTib_TiberiumCanGrow","WTib.TiberiumCanGrow",WTib.TiberiumCanGrow)

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

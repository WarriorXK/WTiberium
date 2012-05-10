
WTib = WTib or {}
WTib.InfectedEntities			= {}
WTib.Config						= {}
WTib.Config.ResourceFile		= "WTib/resources.txt"
WTib.Config.ForceResources		= false
WTib.Config.MaximumFieldSize	= 70

/*
	Console Commands
*/

concommand.Add("WTib_RemoveAllTiberium",function(ply,com,args)
	if ply == NULL or ply:IsAdmin() then
		for _,v in pairs(WTib.GetAllTiberium()) do
			v:Remove()
		end
		for _,v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				v:ChatPrint("All Tiberium has been removed by \""..ply:Nick().."\".")
			else
				v:ChatPrint("All Tiberium has been removed.")
			end
		end
	else
		ply:ChatPrint("This command is admin only.")
	end
end)

concommand.Add("WTib_DefaultMaxFieldSize",function(ply,com,args)
	if ply == NULL or ply:IsAdmin() then
		local val = math.Clamp(tonumber(args[1]),10,300)
		WTib.Config.MaximumFieldSize = val
		for _,v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				v:ChatPrint("Max Tiberium per field has been set to "..val.." by \""..ply:Nick().."\".")
			else
				v:ChatPrint("Max Tiberium per field has been set to "..val)
			end
		end
	else
		ply:ChatPrint("This command is admin only.")
	end
end)

/*
	Misc stuff
*/

function WTib.GetAllTiberium(tFilter)
	tFilter = tFilter or {}
	local tData = {}
	for _,v in pairs(ents.GetAll()) do
		if !table.HasValue(tFilter,v) and v.IsTiberium then
			table.insert(tData,v)
		end
	end
	return tData
end

function WTib.AddResources()
	if WTib.Config.ForceResources then
		if file.Exists(WTib.Config.ResourceFile) then
			print("\nWTib - Adding resource files...")
			WTib.DebugPrint("***************************")
			for _,v in pairs(string.Explode("\n",file.Read(WTib.Config.ResourceFile))) do
				if string.find(v,"//") == 1 then
					WTib.DebugPrint(v)
				elseif v == "" then
					WTib.DebugPrint("\n")
				else
					resource.AddFile(v)
					WTib.DebugPrint(v)
				end
			end
			WTib.DebugPrint("***************************")
			print("Done\n")
		else
			print("WTib - Force resource enabled but \""..WTib.Config.ResourceFile.."\" does not exists, not adding resources.")
		end
	end
end

function WTib.CreateTiberium(creator,class,t,ply)
	if !WTib.CanTiberiumGrow(class, t.HitPos) then return end
	if !t.Hit or (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity.IsTiberium)) or t.HitSky then return end
	local e = ents.Create(class)
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos+ang:Up()*5)
	if WTib.IsValid(creator) and (creator:GetField() or 0) > 0 then
		e:SetField(creator:GetField())
	end
	e.WDSO = ply
	e:Spawn()
	e:Activate()
	if e.Decal and e.Decal != "" then
		local Col = e.TiberiumColor
		Col.a = 255
		util.DecalEx(e.Decal, t.HitEntity, t.HitPos, t.HitNormal, Col, e.DecalSize or 1, e.DecalSize or 1)
	end
	if WTib.IsValid(t.Entity) and !t.Entity:IsWorld() then
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetParent(t.Entity)
	end
	return e
end

function WTib.CanTiberiumGrow(class, pos)
	local Call = hook.Call("WTib_TiberiumCanGrow",GAMEMODE,class,pos)
	if Call == false then return false end
	return true
end

function WTib.SpawnFunction(p,t,ent,offset)
	if !t.Hit then return end
	local e = ents.Create(WTib.GetClass(ent))
	e.WDSO = p
	e:Spawn()
	e:Activate()
	if offset then
		e:SetPos(t.HitPos+t.HitNormal*offset)
	else
		e:SetPos(t.HitPos+t.HitNormal*-e:OBBMins().z)
	end
	return e
end

function WTib.Infect(ent)
	if !WTib.IsInfected(ent) then
		table.insert(WTib.InfectedEntities,ent)
	end
end

function WTib.IsInfected(ent)
	return table.HasValue(WTib.InfectedEntities,ent)
end

/*
	Misc hooks
*/

function WTib.Disenfect(ent)
	for k,v in pairs(WTib.InfectedEntities) do
		if v == ent then
			WTib.InfectedEntities[k] = nil
		end
	end
end
hook.Add("PlayerSpawn","WTib.Disenfect",WTib.Disenfect)

timer.Create("WTib.InfectedTimer",1,0,function()
	local dmginfo = DamageInfo()
	dmginfo:SetDamageType(DMG_ACID)
	for _,v in pairs(WTib.InfectedEntities) do
		if WTib.IsValid(v) and (v:IsPlayer() and v:Alive() or true) then
			dmginfo:SetAttacker(v)
			dmginfo:SetInflictor(v)
			dmginfo:SetDamage(math.random(1,3))
			v:TakeDamageInfo(dmginfo)
		end
	end
end)

function WTib.TiberiumCanGrow(class,pos)
	for _,v in pairs(ents.FindInSphere(pos,400)) do
		if v.IsTiberium then
			local EntTable = scripted_ents.GetStored(class)
			local Dist = v:GetPos():Distance(pos)
			
			WTib.DebugPrint("'" .. class .. "' - '" .. v:GetClass() .. "' - '" .. tostring(EntTable.t.ClassToSpawn) .. "'")
			
			if class == v:GetClass() or (type(EntTable) == "table" and (EntTable.t.ClassToSpawn == v:GetClass() or class == v:GetClass())) then
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
	Field management
*/

WTib.Fields	= {}

function WTib.CreateField(master,fmax)
	local Field = {
		Master = master,
		MaximumEntities = fmax or WTib.Config.MaximumFieldSize,
		Entities = {master},
		MostDistant = master
	}
	for k,v in pairs(WTib.Fields) do
		if !WTib.Fields[k] then
			WTib.Fields[k] = Field
			return k
		end
	end
	local Num = table.Count(WTib.Fields)+1
	WTib.Fields[Num] = Field
	return Num
end

function WTib.KillField(num)
	WTib.Fields[num] = nil
end

function WTib.GetFurthestCrystalFromField(num)
	if !WTib.IsValid(WTib.Fields[num].MostDistant) then
		WTib.SelectMostDistant(num)
	end
	return WTib.Fields[num].MostDistant
end

function WTib.AddFieldMember(num,ent)
	if WTib.IsValidField(num) then
		table.insert(WTib.Fields[num].Entities,ent)
		WTib.SelectMostDistant(num)
	end
end

function WTib.SelectMostDistant(num)
	local Ent
	local Dis = 0
	for _,v in pairs(WTib.Fields[num].Entities) do
		if WTib.IsValid(v) then
			local a = v:GetPos():Distance(WTib.GetFieldMaster(num):GetPos())
			if a > Dis then
				Ent = v
				Dis = a
			end
		end
	end
	WTib.Fields[num].MostDistant = Ent
end

function WTib.GetFieldCount(num)
	if !WTib.IsValidField(num) then return 0 end
	return table.Count(WTib.Fields[num].Entities)
end

function WTib.IsFieldFull(num)
	return WTib.GetFieldCount(num) >= WTib.GetFieldMax(num)
end

function WTib.GetFieldMaster(num)
	if !WTib.IsValidField(num) then return end
	if !WTib.IsValid(WTib.Fields[num].Master) then
		return WTib.SelectNewFieldMaster(num)
	end
	return WTib.Fields[num].Master
end

function WTib.GetFieldMax(num)
	if !WTib.IsValidField(num) then return 0 end
	return WTib.Fields[num].MaximumEntities or WTib.Config.MaximumFieldSize
end

function WTib.IsValidField(num)
	return WTib.Fields[num] != nil and type(WTib.Fields[num]) == "table"
end

function WTib.SelectNewFieldMaster(num)
	local Ent
	local LIndex = 10000
	for _,e in pairs(WTib.Fields[num].Entities) do
		if e:EntIndex() <= LIndex and WTib.IsValid(e) then
			Ent = e
		end
	end
	WTib.Fields[num].Master = Ent
	if !WTib.IsValid(Ent) then
		WTib.KillField(num)
		return
	end
	return Ent
end

timer.Create("WTib.FieldTimer",5,0,function()
	for num,field in pairs(WTib.Fields) do
		for k,v in pairs(field.Entities) do
			if !WTib.IsValid(v) then
				WTib.Fields[num].Entities[k] = nil
			end
		end
	end
end)

// Shamelessly stolen from Wiremod
local cvar = GetConVar("sv_tags")
timer.Create("WTib_Tags",1,0,function()
	local tags = cvar:GetString()
	if (!tags:find( "WTiberium" )) then
		local tag = "WTiberium"
		RunConsoleCommand( "sv_tags", tags .. "," .. tag )
	end	
end)

WTib.AddResources()

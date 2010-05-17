
WTib = WTib or {}
WTib.InfectedEntities			= {}
WTib.Config						= {}
WTib.Config.ResourceFile		= "WTib/resources.txt"
WTib.Config.MaximumFieldSize	= 70

/*
	Console Commands
*/

concommand.Add("WTib_RemoveAllTiberium",function(ply,com,args)
	if ply:IsAdmin() then
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
	if ply:IsAdmin() then
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
		print("WTib - \""..WTib.Config.ResourceFile.."\" does not exists, not adding resources.")
	end
end

function WTib.CreateTiberium(creator,class,t,ply)
	local Call = hook.Call("WTib_TiberiumCanGrow",GAMEMODE,class,t,creator)
	if Call != nil and !tobool(a) then return end
	if !t.Hit or (t.Entity and (t.Entity:IsPlayer() or t.Entity:IsNPC() or t.Entity.IsTiberium)) or t.HitSky then return end
	local e = ents.Create(class)
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	e:SetAngles(ang)
	e:SetPos(t.HitPos)
	if creator and creator.IsValid and creator:IsValid() then
		e:SetField(creator:GetField())
	end
	e.WDSO = p
	e:Spawn()
	e:Activate()
	util.Decal(e.Decal,t.HitPos-(t.HitNormal*(e.DecalSize or 1)),t.HitPos+(t.HitNormal*(e.DecalSize or 1)))
	if ValidEntity(t.Entity) and !t.Entity:IsWorld() then
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetParent(t.Entity)
	end
	return e
end

function WTib.SpawnFunction(p,t,offset,ent)
	if !t.Hit then return end
	offset = offset or 1
	local e = ents.Create(WTib.GetClass(ent))
	e:SetPos(t.HitPos+t.HitNormal*offset)
	e.WDSO = p
	e:Spawn()
	e:Activate()
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
		if ValidEntity(v) and (v:IsPlayer() and v:Alive() or true) then
			dmginfo:SetAttacker(v)
			dmginfo:SetInflictor(v)
			dmginfo:SetDamage(math.random(1,3))
			v:TakeDamageInfo(dmginfo)
		end
	end
end)

function WTib.TiberiumCanGrow(class,t,ent)
	// TODO: Prevent fields from extending from their max size here.
	for _,v in pairs(ents.FindInSphere(t.HitPos,600)) do
		local Dist = v:GetPos():Distance(t.HitPos)
		if v.IsTiberium then
			if v:GetClass() == class then
				if Dist <= 80 then
					return false
				end
			elseif Dist <= 500 then
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
	if !ValidEntity(WTib.Fields[num].MostDistant) then
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
		if ValidEntity(v) then
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
	return table.Count(WTib.Fields[num].Entities)
end

function WTib.IsFieldFull(num)
	return WTib.GetFieldCount(num) >= WTib.GetFieldMax(num)
end

function WTib.GetFieldMaster(num)
	if !ValidEntity(WTib.Fields[num].Master) then
		return WTib.SelectNewFieldMaster(num)
	end
	return WTib.Fields[num].Master
end

function WTib.GetFieldMax(num)
	return WTib.Fields[num].MaximumEntities or WTib.Config.MaximumFieldSize
end

function WTib.IsValidField(num)
	return WTib.Fields[num] != nil and type(WTib.Fields[num]) == "table"
end

function WTib.SelectNewFieldMaster(num)
	local Ent
	local LIndex = 10000
	for _,e in pairs(WTib.Fields[num].Entities) do
		if e:EntIndex() <= LIndex then
			Ent = e
		end
	end
	WTib.Fields[num].Master = Ent
	if !ValidEntity(Ent) then
		WTib.KillField(num)
		return
	end
	return Ent
end

timer.Create("WTib.FieldTimer",5,0,function()
	for num,field in pairs(WTib.Fields) do
		for k,v in pairs(field.Entities) do
			if !ValidEntity(v) then
				WTib.Fields[num].Entities[k] = nil
			end
		end
	end
end)

local Tags = GetConVarString("sv_tags") //Thanks PHX!
if Tags == nil then
	RunConsoleCommand("sv_tags","WTiberium")
elseif !string.find(Tags,"WTiberium") then
	RunConsoleCommand("sv_tags","WTiberium,"..Tags)
end

WTib.AddResources()

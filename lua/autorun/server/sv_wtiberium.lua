
WTib = WTib or {}
WTib.InfectedEntities			= {}
WTib.Config						= {}
WTib.ConfigMessages				= {}
WTib.ConCommandsIgnoredPlayers	= {}

WTib.Config.ResourceFile		= "WTib/resources.txt"
WTib.Config.ForceResources		= false
WTib.Config.InfectionChance		= 2
WTib.Config.MaximumFieldSize	= 70

/*
	Console Commands
*/

function WTib.SetConfigVar(var, val, mess)
	WTib.ConfigMessages[var] = {Message = mess, BroadcastOn = CurTime()+0.5}
	WTib.Config[var] = val
end

timer.Create("WTib.ConfigMessagesTimer", 0.1, 0, function()

	for k,v in pairs(WTib.ConfigMessages) do
	
		if v.BroadcastOn <= CurTime() then
			for _,ply in pairs(player.GetAll()) do
				ply:ChatPrint(v.Message)
			end
			WTib.ConfigMessages[k] = nil
		end
		
	end
	
end)

concommand.Add("wtib_removealltiberium", function(ply, com, args)

	if ply == NULL or ply:IsAdmin() then
	
		for _,v in pairs(WTib.GetAllTiberium()) do
			v:Remove()
		end
		
		local Text = "All Tiberium has been removed"
		
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint(Text)
		end
		
	else
	
		ply:ChatPrint("This command is admin only.")
		
	end
	
end)

concommand.Add("wtib_defaultmaxfieldsize", function(ply, com, args)

	if ply == NULL or ply:IsAdmin() then
	
		local Input = tonumber(args[1])
		
		if Input == nil then
		
			ply:ChatPrint("wtib_defaultmaxfieldsize = " .. WTib.Config.MaximumFieldSize)
		
		else
		
			local val = math.Clamp(Input, 10, 300)
			if WTib.Config.MaximumFieldSize != val then
				WTib.Config.MaximumFieldSize = val
				WTib.SetConfigVar("MaximumFieldSize", val, "Max Tiberium per field has been set to "..val)
			end
			
		end
		
	else
	
		ply:ChatPrint("This command is admin only.")
		
	end
	
end)

concommand.Add("wtib_infectionchance",function(ply,com,args)

	if ply == NULL or ply:IsAdmin() then
	
		local Input = tonumber(args[1])
		
		if Input == nil then
			
			ply:ChatPrint("wtib_infectionchance = " .. WTib.Config.InfectionChance)
			
		else
		
			local val = math.max(Input,-1)
			
			if WTib.Config.InfectionChance != val then
				WTib.Config.InfectionChance = val
				
				local Text = "The Tiberium infection chance has been set to 1 in "..val
				if val <= 0 then Text = "Tiberium infection has been disabled" end
				WTib.SetConfigVar("InfectionChance", val, Text)
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
	
	local ang = t.HitNormal:Angle()+Angle(90,0,0)
	ang:RotateAroundAxis(ang:Up(),math.random(0,360))
	
	local e = ents.Create(class)
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

function WTib.Infect(ent, att, inf, miDOT, maDOT, IgnoreSuit)

	if !WTib.IsInfected(ent) then
	
		if ent:IsNPC() or (ent:IsPlayer() and (IgnoreSuit or ent:Armor() <= 0)) then
		
			table.insert(WTib.InfectedEntities, {Ent = ent, Attacker = att, Inflictor = inf, DamageMin = miDOT, DamageMax = maDOT})
			
		end
		
	end
	
end

function WTib.IsInfected(ent)

	for _,v in pairs(WTib.InfectedEntities) do
		if v.Ent == ent then return true end
	end
	
	return false
	
end

/*
	Misc hooks
*/

function WTib.Disenfect(ent)
	for k,v in pairs(WTib.InfectedEntities) do
		if v.Ent == ent then
			WTib.InfectedEntities[k] = nil
		end
	end
end
hook.Add("PlayerSpawn","WTib.Disenfect",WTib.Disenfect)

timer.Create("WTib.InfectedTimer", 1, 0, function()

	local Crystal = ents.FindByClass("wtib_tiberiuminfection")[1]
	if !WTib.IsValid(Crystal) then
		Crystal = ents.Create("wtib_tiberiuminfection")
		Crystal:Spawn()
	end
	
	local dmginfo = DamageInfo()
	dmginfo:SetDamageType(DMG_ACID)
	
	for _,v in pairs(WTib.InfectedEntities) do
	
		dmginfo:SetAttacker(Crystal)
		dmginfo:SetInflictor(Crystal)
	
		if WTib.IsValid(v.Ent) and ((v.Ent:IsPlayer() and v.Ent:Alive()) or v.Ent:IsNPC()) then
		
			if IsValid(v.Attacker) then dmginfo:SetAttacker(v.Attacker) end
			if IsValid(v.Inflictor) then dmginfo:SetInflictor(v.Inflictor) end
			
			// The infection is already under the Armor, so only the health will be drained
			local Armor = v.Ent:IsPlayer() and v.Ent:Armor() or 0
			v.Ent:SetArmor(0)
			
			dmginfo:SetDamage(math.random(v.DamageMin or 1, v.DamageMax or 3))
			v.Ent:TakeDamageInfo(dmginfo)
			
			if Armor > 0 then v.Ent:SetArmor(Armor) end
			
		end

	end
	
end)

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
	WTib.SelectMostDistant(num)
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
	for k,v in pairs(WTib.Fields[num].Entities) do
		if WTib.IsValid(v) then
			local a = v:GetPos():Distance(WTib.GetFieldMaster(num):GetPos())
			if a > Dis then
				Ent = v
				Dis = a
			end
		else
			WTib.Fields[num].Entities[k] = nil
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

/*
timer.Create( "WTib_Tags", 10, 0, function()

	local TagToAdd = "WTiberium"
	local tags = GetConVarString("sv_tags")
	
	if (!tags:find( TagToAdd )) then
		RunConsoleCommand( "sv_tags", tags .. "," .. TagToAdd )
	end
	
end)
*/

WTib.AddResources()

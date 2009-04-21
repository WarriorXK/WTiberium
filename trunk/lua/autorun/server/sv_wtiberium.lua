
--Models
resource.AddFile("models/props_gammarays/tiberium.mdl")
resource.AddFile("models/props_gammarays/tiberium01.mdl")
resource.AddFile("models/props_gammarays/tiberium05.mdl")
resource.AddFile("models/props_gammarays/tiberiumtower5.mdl")
--Materials
resource.AddFile("materials/killicons/wtib_missile_killicon.vmt")
--Sounds
resource.AddFile("sound/wtiberium/refinery/ref.wav")
resource.AddFile("sound/wtiberium/sonicexplosion/explode.wav")

WTib_InfectedLifeForms = {}
WTib_MinProductionRate = 30
WTib_MaxProductionRate = 60
WTib_MaxFieldSize = 0
local TibFields = {}
local RD3
local RD

if WDS and WDS.AddProtectionFunction then -- This is for my own damage system.
	WDS.AddProtectionFunction(function(ent)
		if ent.IsTiberium then
			return false
		end
	end)
end

/*
	***************************************************
	*                     WTiberium console commands                          *
	*                                                                                                  *
	***************************************************
*/

function WTib_MaxFieldSizeConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MaxFieldSize = tonumber(args[1])
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum tiberium field size changed to "..WTib_MaxFieldSize)
	end
end
concommand.Add("WTib_MaxFieldSize",WTib_MaxFieldSizeConsole)

function WTib_MaxProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MaxProductionRate = math.Clamp(tonumber(args[1]),tonumber(WTib_MinProductionRate)+1,100000)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum tiberium production rate changed to "..WTib_MaxProductionRate)
	end
end
concommand.Add("WTiberium_MaxProductionRate",WTib_MaxProductionRateConsole)

function WTib_MinProductionRateConsole(ply,com,args)
	if !args[1] then return end
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	WTib_MinProductionRate = math.Clamp(tonumber(args[1]),1,tonumber(WTib_MaxProductionRate)-1)
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Maximum tiberium production rate changed to "..WTib_MinProductionRate)
	end
end
concommand.Add("WTiberium_MinProductionRate",WTib_MinProductionRateConsole)

function WTib_ClearAllTiberiumConsole(ply,com,args)
	if !ply:IsAdmin() then
		ply:ChatPrint("This command is admin only "..ply:Nick())
		return
	end
	local a = 0
	for _,v in pairs(WTib_GetAllTiberium()) do
		if v and v:IsValid() then
			v:Remove()
			a = a+1
		end
	end
	for _,v in pairs(player.GetAll()) do
		v:ChatPrint("Removed all "..tostring(a).." tiberium entities!")
	end
end
concommand.Add("WTiberium_ClearAllTiberium",WTib_ClearAllTiberiumConsole)

/*
	***************************************************
	*                               WTiberium Hooks                                     *
	*                                                                                                   *
	***************************************************
*/

function WTib_PlayerSpawn(ply)
	if WTib_IsInfected(ply) then
		WTib_CureInfection(ply)
	end
end
hook.Add("PlayerSpawn","WTib_PlayerSpawn",WTib_PlayerSpawn)

function WTib_Think()
	local e = WTib_GetAllTiberium()[1] or NULL
	for _,v in pairs(WTib_InfectedLifeForms) do
		if v and v:IsValid() and v:Alive() and (v.WTib_NextInfectedDamage or 0) <= CurTime() then
			v:TakeDamage(1,e,e)
			v.WTib_NextInfectedDamage = CurTime()+2
		end
	end
end
hook.Add("Think","WTib_Think",WTib_Think)

/*
	***************************************************
	*                       WTiberium field management                         *
	*                                                                                                   *
	***************************************************
*/

function WTib_CreateNewField(e)
	local num = (table.Count(TibFields) or 0)+1
	local a = {}
	a.Leader = e
	a.Ents = {}
	TibFields[num] = a
	return num
end

function WTib_AddToField(f,e)
	if !TibFields[f] then return WTib_CreateNewField(e) end
	WTib_CheckOnField(f)
	table.insert(TibFields[tonumber(f)].Ents,e)
	return f
end

function WTib_GetFieldEnts(f)
	if !TibFields[f] then return {} end
	return TibFields[f].Ents or {}
end

function WTib_GetFieldLeader(f)
	if !TibFields[f] then return end
	return TibFields[f].Leader
end

function WTib_CheckOnField(f)
	local tab = TibFields[f]
	if !TibFields[f] then return false end
	if !TibFields[f].Leader or !TibFields[f].Leader:IsValid() then
		for k,v in SortedPairs(TibFields[f].Ents) do
			if v and v:IsValid() then
				TibFields[f].Leader = v
				TibFields[f].Ents[k] = nil
				break
			end
		end
	end
	local a = {}
	for _,v in pairs(TibFields[f].Ents) do
		if v and v:IsValid() then
			table.insert(a,v)
		end
	end
	TibFields[f].Ents = a
	return true
end

/*
	***************************************************
	*                    WTiberium infection management                     *
	*                                                                                                   *
	***************************************************
*/

function WTib_InfectLiving(ply)
	if ply and ply:IsValid() and (ply:IsPlayer() or ply:IsNPC()) and !WTib_IsInfected(ply) then
		ply:SetColor(0,200,0,255)
		table.insert(WTib_InfectedLifeForms,ply)
	end
end

function WTib_CureInfection(ply)
	if ply and ply:IsValid() and (ply:IsPlayer() or ply:IsNPC()) then
		for k,v in pairs(WTib_InfectedLifeForms) do
			if v == ply then
				ply:SetColor(255,255,255,255)
				ply.WTib_LastTiberiumGasDamage = 0
				ply.WTib_InfectLevel = 0
				WTib_InfectedLifeForms[k] = nil
				return true
			end
		end
		return false
	end
	return false
end

function WTib_IsInfected(ply)
	return table.HasValue(WTib_InfectedLifeForms,ply)
end

/*
	***************************************************
	*                       WTiberium Misc functions                             *
	*                                                                                                   *
	***************************************************
*/

function WTib_GetAllTiberium()
	local a = {}
	for _,v in pairs(ents.GetAll()) do
		if v.IsTiberium then
			table.insert(a,v)
		end
	end
	return a
end

function WTib_PropToTiberium(v)
	if v:GetClass() == "prop_ragdoll" then
		return WTib_RagdollToTiberium(v)
	end
	local e = ents.Create("wtib_tiberiumprop")
	e:SetPos(v:GetPos())
	e:SetModel(v:GetModel())
	e:SetMaterial(v:GetMaterial())
	e:SetAngles(v:GetAngles())
	e:SetColor(Color(0,200,20,230))
	e:SetSkin(v:GetSkin())
	e:SetCollisionGroup(v:GetCollisionGroup())
	e.Class = e:GetClass()
	if v.ZatMode == 1 then -- Zat compatability
		e.ZatMode = 2
		e.LastZat = v.LastZat or CurTime()
	end
	e:Spawn()
	e:Activate()
	v:Remove()
	return e
end

function WTib_RagdollToTiberium(rag)
	if !rag or !rag:GetClass() == "prop_ragdoll" then return NULL end
	rag.WTib_OldCollisionGroup = rag:GetCollisionGroup()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	rag.IsTiberium = true
	rag.SetTiberiumAmount = function(self,am)
		self:SetNWInt("TiberiumAmount",math.Clamp(am,-10,self.MaxTiberium))
		if self:GetNWInt("TiberiumAmount") <= 0 then
			WTib_TiberiumRagdollToRagdoll(self)
			return
		end
	end
	rag.AddTiberiumAmount = function(self,am)
		self:SetTiberiumAmount(math.Clamp(self:GetTiberiumAmount()+am,-10,self.MaxTiberium))
	end
	rag.DrainTiberiumAmount = function(self,am)
		self:SetTiberiumAmount(math.Clamp(self:GetTiberiumAmount()-am,-10,self.MaxTiberium))
	end
	rag.GetTiberiumAmount = function(self)
		return self:GetNWInt("TiberiumAmount")
	end
	rag.FunctionToRunOnNormal		= func
	rag.TiberiumDraimOnReproduction	= 0
	rag.MinReprodutionTibRequired	= 0
	rag.RemoveOnNoTiberium			= false
	rag.DisableAntiPickup			= true
	rag.ReproductionRate			= 0
	rag.MinTiberiumGain				= 0
	rag.MaxTiberiumGain				= 0
	rag.ShouldReproduce				= false
	rag.ReproduceDelay				= 0
	rag.TiberiumAdd					= false
	rag.MaxTiberium					= 700
	rag.DynLight					= false
	rag.Gas							= false
	rag.r							= 0
	rag.g							= 255
	rag.b							= 0
	rag.a							= 150
	rag:SetTiberiumAmount(700)
	rag:SetColor(rag.r,rag.g,rag.b,rag.a)
	rag:GetTable().WTib_StatueInfo = {}
	rag:GetTable().WTib_StatueInfo.Welds = {}
	local bones = rag:GetPhysicsObjectCount()
	for bone=1, bones do
		local bone1 = bone-1
		local bone2 = bones-bone
		if (!rag:GetTable().WTib_StatueInfo.Welds[bone2]) then
			local weld1 = constraint.Weld(rag,rag,bone1,bone2,0)
			if (weld1) then
				rag:GetTable().WTib_StatueInfo.Welds[bone1] = weld1
			end
		end
		local weld2 = constraint.Weld(rag,rag,bone1,0,0)
		if (weld2) then
			rag:GetTable().WTib_StatueInfo.Welds[bone1+bones] = weld2
		end
		local ed = EffectData()
		ed:SetOrigin(rag:GetPhysicsObjectNum(bone1):GetPos())
		ed:SetScale(1)
		ed:SetMagnitude(1)
		util.Effect("GlassImpact",ed,true,true)
	end
	return rag
end

function WTib_TiberiumRagdollToRagdoll(rag,func)
	if !rag or !rag:GetClass() == "prop_ragdoll" or !rag.IsTiberium then return NULL end
	rag:SetCollisionGroup(rag.WTib_OldCollisionGroup)
	rag.TiberiumDraimOnReproduction	= nil
	rag.MinReprodutionTibRequired	= nil
	rag.WTib_OldCollisionGroup		= nil
	rag.DrainTiberiumAmount			= nil
	rag.RemoveOnNoTiberium			= nil
	rag.SetTiberiumAmount			= nil
	rag.AddTiberiumAmount			= nil
	rag.DisableAntiPickup			= nil
	rag.GetTiberiumAmount			= nil
	rag.ReproductionRate			= nil
	rag.MinTiberiumGain				= nil
	rag.MaxTiberiumGain				= nil
	rag.ShouldReproduce				= nil
	rag.ReproduceDelay				= nil
	rag.TiberiumAdd					= nil
	rag.MaxTiberium					= nil
	rag.IsTiberium					= nil
	rag.DynLight					= nil
	rag.Gas							= nil
	rag.r							= nil
	rag.g							= nil
	rag.b							= nil
	rag.a							= nil
	rag:SetColor(255,255,255,255)
	for _,v in pairs(rag:GetTable().WTib_StatueInfo.Welds) do
		if v and v:IsValid() then
			v:Remove()
		end
	end
	rag:GetTable().WTib_StatueInfo = nil
	if rag.FunctionToRunOnNormal and type(rag.FunctionToRunOnNormal) == "function" then
		rag.FunctionToRunOnNormal(rag)
	end
	return rag
end

/*
	***************************************************
	*  RD3 and RD2 shit down here, these are all placeholders   *
	*     so the check does not have to be done multiple times      *
	***************************************************
*/

function WTib_IsRD3()
	if(RD3 ~= nil) then return RD3 end
	if(CAF and CAF.GetAddon("Resource Distribution")) then
		RD3 = true
		RD = CAF.GetAddon("Resource Distribution")
		return true
	end
	RD3 = false
	return false
end

function WTib_HasRD()
	return (Dev_Link != nil or #file.FindInLua("weapons/gmod_tool/stools/dev_link.lua") == 1)
end

function WTib_IsRD2()
	if WTib_IsRD3() then return false end
	return (Dev_Unlink_All != nil)
end

function WTib_SupplyResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.SupplyResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_SupplyResource(a,b,c)
		end
	end
end

function WTib_ConsumeResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.ConsumeResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_ConsumeResource(a,b,c)
		end
	end
end

function WTib_AddResource(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.AddResource(a,b,c)
		elseif WTib_IsRD2 then
			return RD_AddResource(a,b,c)
		end
	end
end

function WTib_GetResourceAmount(a,b,c)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.GetResourceAmount(a,b,c)
		elseif WTib_IsRD2 then
			return RD_GetResourceAmount(a,b,c)
		end
	end
end

function WTib_RemoveRDEnt(a)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.RemoveRDEntity(a)
		elseif Dev_Unlink_All and a.resources2links then
			return Dev_Unlink_All(a)
		end
	end
end

function WTib_GetNetworkCapacity(a,b)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.GetNetworkCapacity(a,b)
		elseif WTib_IsRD2 then
			return RD_GetNetworkCapacity(a,b)
		end
	end
end

function WTib_BuildDupeInfo(a)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.BuildDupeInfo(a)
		elseif WTib_IsRD2 then
			return RD_BuildDupeInfo(a)
		end
	end
end

function WTib_ApplyDupeInfo(a,b)
	if WTib_HasRD() then
		if WTib_IsRD3() then
			return RD.ApplyDupeInfo(a,b)
		elseif WTib_IsRD2 then
			return RD_ApplyDupeInfo(a,b)
		end
	end
end

function WTib_RegisterEnt(a,b)
	if LS_RegisterEnt then
		return LS_RegisterEnt(a,b)
	end
end

/*
	***************************************************
	*         Wire shit down here, these are all placeholders          *
	*     so the check does not have to be done multiple times      *
	***************************************************
*/

function WTib_CreateInputs(a,b,c)
	if WireAddon then
		return Wire_CreateInputs(a,b,c)
	end
end

function WTib_CreateOutputs(a,b)
	if WireAddon then
		return Wire_CreateOutputs(a,b)
	end
end

function WTib_TriggerOutput(a,b,c)
	if WireAddon then
		return Wire_TriggerOutput(a,b,c)
	end
end

function WTib_Restored(a)
	return Wire_Restored(a)
end

function WTib_Remove(a)
	if WireAddon then
		return Wire_Remove(a)
	end
end

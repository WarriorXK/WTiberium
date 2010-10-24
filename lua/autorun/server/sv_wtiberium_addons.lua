
WTib = WTib or {}

function WTib.SupplyResource(a,b,c)
	if WTib.HasRD3() then
		return WTib.RD3.SupplyResource(a,b,c)
	elseif WTib.HasRD2() then
		return RD_SupplyResource(a,b,c)
	end
end

function WTib.ConsumeResource(a,b,c)
	if WTib.HasRD3() then
		return WTib.RD3.ConsumeResource(a,b,c)
	elseif WTib.HasRD2() then
		return RD_ConsumeResource(a,b,c)
	end
end

function WTib.AddResource(a,b,c)
	if WTib.HasRD3() then
		return WTib.RD3.AddResource(a,b,c)
	elseif WTib.HasRD2() then
		return RD_AddResource(a,b,c)
	end
end

function WTib.GetResourceAmount(a,b,c)
	if WTib.HasRD3() then
		return WTib.RD3.GetResourceAmount(a,b,c)
	elseif WTib.HasRD2() then
		return RD_GetResourceAmount(a,b,c)
	end
	return 0
end

function WTib.RemoveRDEnt(a)
	if WTib.HasRD3() then
		return WTib.RD3.RemoveRDEntity(a)
	elseif Dev_Unlink_All and a.resources2links then
		return Dev_Unlink_All(a)
	end
end

function WTib.GetNetworkCapacity(a,b)
	if WTib.HasRD3() then
		return WTib.RD3.GetNetworkCapacity(a,b)
	elseif WTib.HasRD2() then
		return RD_GetNetworkCapacity(a,b)
	end
	return 0
end

function WTib.BuildDupeInfo(a)
	if WTib.HasRD3() then
		return WTib.RD3.BuildDupeInfo(a)
	elseif WTib.HasRD2() then
		return RD_BuildDupeInfo(a)
	end
end

function WTib.ApplyDupeInfo(a,b)
	if WTib.HasRD3() then
		return WTib.RD3.ApplyDupeInfo(a,b)
	elseif WTib.HasRD2() then
		return RD_ApplyDupeInfo(a,b)
	end
end

function WTib.RegisterEnt(a,b)
	if LS_RegisterEnt then
		return LS_RegisterEnt(a,b)
	end
	if b != "Storage" and WTib.RD3 and WTib.RD3.RegisterNonStorageDevice then
		WTib.RD3.RegisterNonStorageDevice(a)
	end
end


/*
	Wiremod
*/

function WTib.CreateInputs(a,b,c)
	if WireAddon then
		return Wire_CreateInputs(a,b,c)
	end
end

function WTib.CreateOutputs(a,b)
	if WireAddon then
		return Wire_CreateOutputs(a,b)
	end
end

function WTib.TriggerOutput(a,b,c)
	if WireAddon then
		return Wire_TriggerOutput(a,b,math.Round(c))
	end
end

function WTib.Restored(a)
	if WireAddon then
		return Wire_Restored(a)
	end
end

function WTib.Remove(a)
	if WireAddon then
		return Wire_Remove(a)
	end
end

function WTib.ApplyDupeFunctions(ENT)
	function ENT:PreEntityCopy()
		WTib.BuildDupeInfo(self)
		if WireAddon then
			local DupeInfo = WireLib.BuildDupeInfo(self)
			if DupeInfo then
				duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
			end
		end
	end

	function ENT:PostEntityPaste(ply,Ent,CreatedEntities)
		WTib.ApplyDupeInfo(Ent,CreatedEntities)
		if WireAddon and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
			WireLib.ApplyDupeInfo(ply,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
		end
	end
end

/*
	WDS
*/

function WTib.WDSDamagePrevention(ent,dmg)
	if ent.IsTiberium then
		return false
	end
end
hook.Add("WDS_EntityTakeDamage","WTib.WDSDamagePrevention",WTib.WDSDamagePrevention)

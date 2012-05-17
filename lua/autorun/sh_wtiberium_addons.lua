
WTib = WTib or {}

/*
	Resource distribution
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

function WTib.RegisterEnt(a,b)
	if WTib.HasResourceAPI() then
		return a:InitResources()
	elseif LS_RegisterEnt then
		return LS_RegisterEnt(a,b)
	elseif WTib.RD3 and WTib.RD3.RegisterNonStorageDevice then
		if b != "Storage" then
			WTib.RD3.RegisterNonStorageDevice(a)
		end
	end
end

if SERVER then

	function WTib.SupplyResource(a,b,c)
		if WTib.HasResourceAPI() then
			return a:ResourcesSupply( b, c )
		elseif WTib.HasRD3() then
			return WTib.RD3.SupplyResource(a,b,c)
		elseif WTib.HasRD2() then
			return RD_SupplyResource(a,b,c)
		end
	end

	function WTib.ConsumeResource(a,b,c)
		if WTib.HasResourceAPI() then
			return a:ResourcesConsume( b, c )
		elseif WTib.HasRD3() then
			return WTib.RD3.ConsumeResource(a,b,c)
		elseif WTib.HasRD2() then
			return RD_ConsumeResource(a,b,c)
		end
	end

	function WTib.AddResource(a,b,c)
		if WTib.HasResourceAPI() then
			if c > 0 then
				return a:ResourcesSetDeviceCapacity( b, c )
			end
		elseif WTib.HasRD3() then
			return WTib.RD3.AddResource(a,b,c)
		elseif WTib.HasRD2() then
			return RD_AddResource(a,b,c)
		end
	end

	function WTib.GetResourceAmount(a,b,c)
		if WTib.HasResourceAPI() then
			return a:ResourcesGetAmount( b )
		elseif WTib.HasRD3() then
			return WTib.RD3.GetResourceAmount(a,b,c)
		elseif WTib.HasRD2() then
			return RD_GetResourceAmount(a,b,c)
		end
		return 0
	end

	function WTib.RemoveRDEnt(a)
		if WTib.HasResourceAPI() then
			// Not required
		elseif WTib.HasRD3() then
			return WTib.RD3.RemoveRDEntity(a)
		elseif Dev_Unlink_All and a.resources2links then
			return Dev_Unlink_All(a)
		end
	end

	function WTib.GetNetworkCapacity(a,b)
		if WTib.HasResourceAPI() then
			return a:ResourcesGetCapacity(b)
		elseif WTib.HasRD3() then
			return WTib.RD3.GetNetworkCapacity(a,b)
		elseif WTib.HasRD2() then
			return RD_GetNetworkCapacity(a,b)
		end
		return 0
	end

	function WTib.BuildDupeInfo(a)
		if WTib.HasResourceAPI() then
			// Todo : Get the API function for this
		elseif WTib.HasRD3() then
			return WTib.RD3.BuildDupeInfo(a)
		elseif WTib.HasRD2() then
			return RD_BuildDupeInfo(a)
		end
	end

	function WTib.ApplyDupeInfo(a,b)
		if WTib.HasResourceAPI() then
			// Todo : Get the API function for this
		elseif WTib.HasRD3() then
			return WTib.RD3.ApplyDupeInfo(a,b)
		elseif WTib.HasRD2() then
			return RD_ApplyDupeInfo(a,b)
		end
	end

end

/*
	Wiremod
*/

if SERVER then

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
	
end

/*
	WDS
*/

if SERVER then

	function WTib.WDSDamagePrevention(ent,dmg)
		if ent.IsTiberium then
			return false
		end
	end
	hook.Add("WDS_EntityTakeDamage","WTib.WDSDamagePrevention",WTib.WDSDamagePrevention)

end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function SWEP:Initialize()
	self:SetWeaponHoldType("physgun")
end
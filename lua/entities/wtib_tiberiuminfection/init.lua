AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

timer.Simple(0.1, function()
	if WDS2 then
		table.insert(WDS2.ProtectedClasses, ENT.ClassName)
	end
end)

function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:DrawShadow(false)
end
ENT.Type			= "anim"
ENT.PrintName		= "Tiberium Parent Base"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true
ENT.IsTiberiumParent= true

ENT.ShouldCollide = true
ENT.RenderMode = RENDERMODE_TRANSTEXTURE

ENT.Reproduce_TiberiumRequired = 1000
ENT.Reproduce_TiberiumDrained = 400
ENT.Reproduce_Delay = 30

ENT.TiberiumStartAmount = 400
ENT.MaxTiberiumAmount = 2000
ENT.TiberiumColor = Color(0,0,0,200)
ENT.ClassToSpawn = "wtib_tiberium_base"

ENT.Growth_Addition = 30
ENT.Growth_Delay = 10

ENT.DecalSize = 1
ENT.Decal = ""

function ENT:SetupDataTables()
	self:DTVar("Int",0,"TiberiumAmount")
	self:DTVar("Int",1,"ColorDevider")
	self:DTVar("Int",2,"TiberiumField")
end

function ENT:GetTiberiumAmount()
	return self.dt.TiberiumAmount
end

function ENT:GetMaxTiberiumAmount()
	return self.MaxTiberiumAmount
end

function ENT:GetColorDevider()
	return self.dt.ColorDevider
end

function ENT:GetField()
	return self.dt.TiberiumField
end

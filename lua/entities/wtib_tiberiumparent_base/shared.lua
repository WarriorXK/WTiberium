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

ENT.Reproduce_TiberiumRequired	= 1000
ENT.Reproduce_TiberiumDrained	= 400
ENT.Reproduce_Delay				= 30

ENT.TiberiumStartAmount	= 400
ENT.MaxTiberiumAmount	= 2000
ENT.TiberiumColor		= Color(0,0,0,200)
ENT.ClassToSpawn		= "wtib_tiberium_base"

ENT.Growth_Addition	= 30
ENT.Growth_Delay	= 10

ENT.DecalSize	= 1
ENT.Decal		= ""

ENT.RenderMode	= RENDERMODE_TRANSALPHA


function ENT:Initialize()

	if SERVER then self:SetRandomModel() end
	
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	if type(self.InitTiberium) == "function" then self:InitTiberium() end
	
end

function ENT:InitTiberium()

	if SERVER then
	
		self.NextReproduce = 0
		self.Produces = {}
		
		self.NextGrow = 0
		
		if self:GetField() <= 0 then self:SetField(WTib.CreateField(self)) end // If no field was set before we spawned create one
		
		self:SetTiberiumAmount(self.TiberiumStartAmount)
		
		for i=2,100 do // Efficiency at its best
			if (self:GetMaxTiberiumAmount()/i) == 250 then
				self.dt.ColorDevider = i
			end
		end
		
	end
	
	self:SetRenderMode(self.RenderMode)
	self:SetColor(self.TiberiumColor)
	
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"TiberiumAmount")
	self:NetworkVar("Int",1,"ColorDevider")
	self:NetworkVar("Int",2,"TiberiumField")
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

ENT.Type			= "anim"
ENT.PrintName		= "Tiberium Base"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Category		= "Tiberium"
ENT.IsTiberium		= true

ENT.Damage_Explode_RequiredDamage	= 0
ENT.Damage_ExplosionDelay			= 0
ENT.Damage_Explode_Damage			= 0
ENT.Damage_Explode_Size				= 0
ENT.Damage_Explosive				= false

ENT.Reproduce_TiberiumRequired	= 1000
ENT.Reproduce_TiberiumDrained	= 400
ENT.Reproduce_MaxProduces		= 5
ENT.Reproduce_Delay				= 30

ENT.TiberiumStartAmount	= 400
ENT.MaxTiberiumAmount	= 2000
ENT.TiberiumColor		= Color(0,0,0,0)
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
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
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
	self:SetColor(Color(self.TiberiumColor.r,
						self.TiberiumColor.g,
						self.TiberiumColor.b,
						((self:GetTiberiumAmount()/self:GetColorDevider())/2)+100))
	
end

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "TiberiumAmount")
	self:DTVar("Int", 1, "ColorDevider")
	self:DTVar("Int", 2, "TiberiumField")
	self:DTVar("Float", 0, "CrystalSize")
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

function ENT:GetCrystalSize()
	return self.dt.CrystalSize
end

function ENT:GetField()
	return self.dt.TiberiumField
end

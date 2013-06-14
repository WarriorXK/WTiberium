
SWEP.Base					= "wtib_swep_base"
SWEP.PrintName				= "WTib Sonic Pulse"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_physcannon.mdl"
SWEP.WorldModel				= "models/weapons/w_physics.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Sound			= Sound("")
SWEP.Primary.Recoil			= 1.8
SWEP.Primary.Damage			= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= 16
SWEP.Primary.Delay			= 0.05
SWEP.Primary.DefaultClip	= 21
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.LastWarning			= 0
SWEP.NextDamage				= 0
SWEP.NextFire				= 0

SWEP.ShootingSound			= Sound("")
SWEP.WarningSound			= Sound("")
SWEP.EndSound				= Sound("")

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Shooting")
	self:NetworkVar("Float", 0, "LastShootTime")
	self:NetworkVar("Float", 1, "Heat")
end

function SWEP:Initialize()
	self.dt.LastShootTime = 0
	self.dt.Shooting = false
	self.dt.Heat = 0
end

function SWEP:Reload() end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

function SWEP:Think()

	if !IsValid(self.Owner) then return end
	
	if self.Owner:KeyPressed(IN_ATTACK) then
	
		self.dt.Shooting = true
		local ed = EffectData()
			ed:SetEntity(self)
		util.Effect("wtib_sonicswep_pulse",ed)
		if CLIENT then
			self:EmitSound(self.ShootingSound)
		end
		
	elseif self.Owner:KeyDown(IN_ATTACK) then
	
		if SERVER then
			self:Shoot()
		end
		
	elseif self.Owner:KeyReleased(IN_ATTACK) then
	
		self.dt.Shooting = false
		if CLIENT then
		
			self:StopSound(self.ShootingSound)
			self:EmitSound(self.EndSound)

			if self.dt.Heat > 0 then
			
				local ed = EffectData()
					ed:SetEntity(self)
				util.Effect("wtib_sonicswep_heatrelease", ed)
				
			end
			
		end
		
	else
	
		if self.dt.Heat > 0 then
			self.dt.Heat = math.max(self.dt.Heat - 0.06, 0)
		end
		
	end
	if self.dt.Heat >= 50 and self.LastWarning <= CurTime() then
		self:EmitSound(self.WarningSound)
		self.LastWarning = CurTime() + 4
	end
	
	if SERVER and self.dt.Heat >= 75 and self.NextDamage <= CurTime() then
	
		local DmgInfo = DamageInfo()
			DmgInfo:SetDamageType( DMG_BURN )
			DmgInfo:SetInflictor( self )
			DmgInfo:SetAttacker( self.Owner )
			DmgInfo:SetDamage( ( self.dt.Heat - 50 ) / 4 )
		self.Owner:TakeDamageInfo( DmgInfo )
		
		self.NextDamage = CurTime() + 0.5
		
	end
	
end

function SWEP:Shoot()
	if self.NextFire <= CurTime() then
		local Origin = self.Owner:GetShootPos()
		local Target = self.Owner:GetAimVector()
		for _,v in pairs(ents.FindInCone(Origin, Target, 150, 10)) do
			if v.IsTiberium then
				v:TakeSonicDamage(math.Rand(0.5, 1.5) * 40)
			end
		end
		self.NextFire = CurTime()+0.2
	end
	self.dt.Heat = self.dt.Heat+0.1
end

WTib.Dispenser.AddObject({
	Name = SWEP.PrintName,
	Class = WTib.GetClass(SWEP),
	Model = SWEP.WorldModel,
	Angle = Angle(90,0,0),
	PercentDelay = 0.02,
	Information =	{
						SWEP.PrintName,
						"\nSonic weapon that destroys Tiberium, don't overheat it!"
					},
	CreateEnt = function(dispenser,angles,pos,id,ply)
		local Obj = WTib.Dispenser.GetObjectByID(id)
		local ent = ents.Create(Obj.Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Dispenser.GetObjectByID(id).Model)
		
		if ply then
			ent.WDSO = ply
			/*
			undo.Create(Obj.Class)
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
				undo.SetCustomUndoText("Undone "..Obj.Name)
			undo.Finish()
			*/
		end
		
		return ent
	end
})

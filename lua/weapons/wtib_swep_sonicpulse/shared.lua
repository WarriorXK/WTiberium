
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
	self:DTVar("Bool",0,"Shooting")
	self:DTVar("Float",0,"LastShootTime")
	self:DTVar("Float",1,"Heat")
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
		util.Effect("wtib_swep_sonicpulse",ed)
		if CLIENT then
			self:EmitSound(self.ShootingSound)
		end
	elseif self.Owner:KeyDown(IN_ATTACK) then
		if SERVER then
			if self.NextFire <= CurTime() then
				local Origin = self.Owner:GetShootPos()
				local Target = self.Owner:GetAimVector()
				//print("\n")
				for i=1,5 do
					timer.Simple(i/6,function()
						local Dist = 25*i
						for _,v in pairs(ents.FindInCone(Origin,Target,Dist,10)) do
							if v.IsTiberium then
								local Dam = Dist-Origin:Distance(v:GetPos())
								if Dam < 0 then Dam = -Dam end
								//print(Dam)
								v:TakeSonicDamage(Dam)
							end
						end
					end)
				end
				self.NextFire = CurTime()+0.2
			end
			self.dt.Heat = self.dt.Heat+0.2
		end
	elseif self.Owner:KeyReleased(IN_ATTACK) then
		self.dt.Shooting = false
		if CLIENT then
			self:StopSound(self.ShootingSound)
			self:EmitSound(self.EndSound)
		end
	else
		if self.dt.Heat > 0 then
			self.dt.Heat = self.dt.Heat-0.1
		end
	end
	if self.dt.Heat >= 50 and self.LastWarning <= CurTime() then
		self:EmitSound(self.WarningSound)
		self.LastWarning = CurTime()+4
	end
	if SERVER and self.dt.Heat >= 75 and self.NextDamage <= CurTime() then
		local DmgInfo = DamageInfo()
		DmgInfo:SetDamageType(DMG_BURN)
		DmgInfo:SetInflictor(self)
		DmgInfo:SetAttacker(self.Owner)
		DmgInfo:SetDamage((self.dt.Heat-50)/4)
		self.Owner:TakeDamageInfo(DmgInfo)
		self.NextDamage = CurTime()+0.5
	end
end

WTib.Dispenser.AddObject({
	Name = SWEP.PrintName,
	Class = WTib.GetClass(SWEP),
	Model = SWEP.WorldModel,
	PercentDelay = 0.02,
	Information =	{
						SWEP.PrintName,
						"\nSonic weapon that destroys Tiberium, don't overheat it!"
					},
	CreateEnt = function(dispenser,angles,pos,id)
		local ent = ents.Create(WTib.Dispenser.GetObjectByID(id).Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(WTib.Dispenser.GetObjectByID(id).Model)
		return ent
	end
})

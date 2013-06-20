
SWEP.Author					= "WarriorXK"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= ""

SWEP.Category				= "WTiberium"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IconLetter				= "c"

function SWEP:SetupDataTables()
	self:NetworkVar("Bool",0,"Ironsights")
	self:NetworkVar("Float",0,"LastShootTime")
end

function SWEP:Initialize()
	if SERVER then
		self:SetWeaponHoldType(self.HoldType)
		self:SetNPCMinBurst(30)
		self:SetNPCMaxBurst(30)
		self:SetNPCFireRate(0.01)
	end
	self:SetIronsights(false)
end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	self:SetIronsights(false)
end

function SWEP:Think()	
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime()+self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
	if self:CanPrimaryAttack() then
		self.Weapon:EmitSound(self.Primary.Sound)
		self:ShootBullet(self.Primary.Damage,self.Primary.Recoil,self.Primary.NumShots,self.Primary.Cone)
		self:TakePrimaryAmmo(1)
		if self.Owner:IsNPC() then return end
		self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1)*self.Primary.Recoil,math.Rand(-0.1,0.1)*self.Primary.Recoil,0))
		if (game.SinglePlayer() and SERVER) or CLIENT then
			self:SetLastShootTime(CurTime())
		end
	end
end

function SWEP:ShootBullet(dmg,recoil,numbul,cone)
	cone = cone or 0.01
	local bullet = {}
		bullet.Num 		= numbul or 1
		bullet.Src 		= self.Owner:GetShootPos()
		bullet.Dir 		= self.Owner:GetAimVector()
		bullet.Spread 	= Vector(cone,cone,0)
		bullet.Tracer	= 4
		bullet.Force	= 5
		bullet.Damage	= dmg
	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if self.Owner:IsNPC() then return end
	if (game.SinglePlayer() and SERVER) or (!game.SinglePlayer() and CLIENT and IsFirstTimePredicted()) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch-recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
	/*
	draw.SimpleText(self.IconLetter,"CSSelectIcons",x+wide/2,y+tall*0.2,Color(255,210,0,255),TEXT_ALIGN_CENTER)
	draw.SimpleText(self.IconLetter,"CSSelectIcons",x+wide/2+math.Rand(-4,4),y+tall*0.2+math.Rand(-14,14),Color(255,210,0,math.Rand(10,120)),TEXT_ALIGN_CENTER)
	draw.SimpleText(self.IconLetter,"CSSelectIcons",x+wide/2+math.Rand(-4,4),y+tall*0.2+math.Rand(-9,9),Color(255,210,0,math.Rand(10,120)),TEXT_ALIGN_CENTER)
	*/
end

local IRONSIGHT_TIME = 0.25

function SWEP:GetViewModelPosition(pos,ang)
	if !self.IronSightsPos then return pos, ang end
	if self:GetIronsights() != self.bLastIron then
		self.bLastIron = self:GetIronsights()
		self.fIronTime = CurTime()
		if self:GetIronsights() then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	end
	local fIronTime = self.fIronTime or 0
	if !self:GetIronsights() && fIronTime < CurTime() - IRONSIGHT_TIME then return pos, ang end
	local Mul = 1.0
	if fIronTime > CurTime() - IRONSIGHT_TIME then
		Mul = math.Clamp((CurTime()-fIronTime)/IRONSIGHT_TIME,0,1)
		if (!self:GetIronsights()) then Mul = 1-Mul end
	end
	local Offset = self.IronSightsPos
	if self.IronSightsAng then
		ang = ang*1
		ang:RotateAroundAxis(ang:Right(),self.IronSightsAng.x*Mul)
		ang:RotateAroundAxis(ang:Up(),self.IronSightsAng.y*Mul)
		ang:RotateAroundAxis(ang:Forward(),self.IronSightsAng.z*Mul)
	end
	local Right = ang:Right()
	local Up = ang:Up()
	local Forward = ang:Forward()
	pos = pos + Offset.x*Right*Mul
	pos = pos + Offset.y*Forward*Mul
	pos = pos + Offset.z*Up*Mul
	return pos, ang
end

function SWEP:SetIronsights(b)
	self:SetIronsights(b)
end

function SWEP:GetIronsights()
	return self:GetIronsights() or false
end

SWEP.NextSecondaryAttack = 0

function SWEP:SecondaryAttack()
	if !self.IronSightsPos then return end
	if self.NextSecondaryAttack > CurTime() then return end
	self:SetIronsights(!self:GetIronsights())
	self.NextSecondaryAttack = CurTime()+0.3
end

function SWEP:DrawHUD()
	if self:GetIronsights() then return end
	local x = ScrW()/2.0
	local y = ScrH()/2.0
	local scale = 10*self.Primary.Cone
	scale = scale*(2-math.Clamp((CurTime()-self:GetLastShootTime())*5,0.0,1.0))
	surface.SetDrawColor(0,255,0,255)
	local gap = 40*scale
	local length = gap+20*scale
	surface.DrawLine(x-length,y,x-gap,y)
	surface.DrawLine(x+length,y,x+gap,y)
	surface.DrawLine(x,y-length,x,y-gap)
	surface.DrawLine(x,y+length,x,y+gap)
end

function SWEP:OnRestore()
	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
end

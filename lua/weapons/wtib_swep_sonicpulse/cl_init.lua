include('shared.lua')
	
SWEP.Slot				= 0
SWEP.SlotPos			= 4
SWEP.DrawAmmo			= true
SWEP.ViewModelFOV		= 62
SWEP.ViewModelFlip		= false
SWEP.CSMuzzleFlashes	= true

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw			= true
	self.AmmoDisplay.PrimaryClip	= self:GetHeat()
	self.AmmoDisplay.PrimaryAmmo	= -1
	self.AmmoDisplay.SecondaryClip	= -1
	self.AmmoDisplay.SecondaryAmmo	= -1
	return self.AmmoDisplay
end

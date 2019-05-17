local att = {}
att.name = "bg_deagle_compensator"
att.displayName = "Compensator"
att.displayNameShort = "Comp."
att.isBG = true

att.statModifiers = {RecoilMult = -0.3,
AimSpreadMult = 0.15,
OverallMouseSensMult = -0.1,
DrawSpeedMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/deagle_compensator")
	att.description = {}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.compensator)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_deagle_extendedbarrel"
att.displayName = "Extended Barrel"
att.displayNameShort = "Ext.Barrel"
att.isBG = true

att.statModifiers = {RecoilMult = 0.15,
AimSpreadMult = -0.2,
OverallMouseSensMult = -0.1,
DrawSpeedMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/deagle_extendedbarrel")
	att.description = {}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.extended)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_deagle_double_barrel"
att.displayName = "Double Barrel"
att.displayNameShort = "Dbbl.Barrel"
att.isBG = true

att.statModifiers = {
OverallMouseSensMult = -0.15,
DrawSpeedMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/deagle_doublebarrel")
	att.description = {[1] = {t = "Chudnofsky?", c = CustomizableWeaponry.textColors.COSMETIC}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.double)
	self:setBodygroup(self.SlideBGs.main, self.SlideBGs.double)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self:setBodygroup(self.SlideBGs.main, self.SlideBGs.regular)
	self.AmmoPerShot = 1
end

CustomizableWeaponry:registerAttachment(att)


local att = {}
att.name = "bg_deagle_ext_mag"
att.displayName = "Extended Magazine"
att.displayNameShort = "Ext.Mag"
att.isBG = true

att.statModifiers = {
ReloadSpeedMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/bg_deagle_ext_mag")
	att.description = {}
end

function att:attachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.extended)
	self:unloadWeapon()
	self.Primary.ClipSize = 14
	self.Primary.ClipSize_Orig = 14
end

function att:detachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.regular)
	self:unloadWeapon()
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG_REAL
	self.Primary.ClipSize_Orig = self.Primary.ClipSize_ORIG_REAL
end

CustomizableWeaponry:registerAttachment(att)
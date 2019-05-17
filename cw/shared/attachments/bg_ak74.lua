local att = {}
att.name = "bg_ak74rpkmag"
att.displayName = "RPK Quad-Stacked Magazine"
att.displayNameShort = "RPK Mag"
att.isBG = true

att.statModifiers = {ReloadSpeedMult = -0.1,
OverallMouseSensMult = -0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/rpkmag")
	att.description = {[1] = {t = loc('cwc_att_info_magsize_45'), c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.rpk)
	self:unloadWeapon()
	self.Primary.ClipSize = 45
	self.Primary.ClipSize_Orig = 45
end

function att:detachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.regular)
	self:unloadWeapon()
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG_REAL
	self.Primary.ClipSize_Orig = self.Primary.ClipSize_ORIG_REAL
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ak74foldablestock"
att.displayName = "Foldable Stock"
att.displayNameShort = "Foldable"
att.isBG = true
att.SpeedDec = -5

att.statModifiers = {DrawSpeedMult = 0.15,
RecoilMult = 0.1,
OverallMouseSensMult = 0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74foldablestock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.foldable)
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ak74_rpkbarrel"
att.displayName = "RPK Conversion"
att.displayNameShort = "RPK"
att.isBG = true
att.categoryFactors = {cqc = -1, lmg = 3}
att.SpeedDec = 3

att.statModifiers = {DamageMult = 0.1,
RecoilMult = 0.1,
AimSpreadMult = -0.2,
OverallMouseSensMult = -0.15}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74_rpkbarrel")
	att.description = {[1] = {t = "Comes with an integrated bipod", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.rpk)
	self:setBodygroup(self.ReceiverBGs.main, self.ReceiverBGs.rpk)
	self:updateSoundTo("CW_AK74_RPK_FIRE", CustomizableWeaponry.sounds.UNSUPPRESSED)
	self:updateSoundTo("CW_AK74_RPK_FIRE_SUPPRESSED", CustomizableWeaponry.sounds.SUPPRESSED)
	self:setupCurrentIronsights(self.RPKPos, self.RPKAng)
	self.BipodInstalled = true
	
	if not self:isAttachmentActive("sights") then
		self:updateIronsights("RPK")
	end
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self:setBodygroup(self.ReceiverBGs.main, self.ReceiverBGs.regular)
	self.BipodInstalled = false
	
	self:restoreSound()
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ak74_ubarrel"
att.displayName = "-U Conversion"
att.displayNameShort = "AK-U"
att.isBG = true
att.categoryFactors = {cqc = 3}
att.SpeedDec = -3

att.statModifiers = {RecoilMult = -0.1,
AimSpreadMult = 1,
OverallMouseSensMult = 0.1,
DrawSpeedMult = 0.15,
DamageMult = -0.1,
FireDelayMult = -0.0714285}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74_ubarrel")
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.short)
	self:setupCurrentIronsights(self.ShortenedPos, self.ShortenedAng)
	
	if not self:isAttachmentActive("sights") then
		self:updateIronsights("Shortened")
	end
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self:restoreSound()
	self:revertToOriginalIronsights()
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ak74heavystock"
att.displayName = "Heavy Stock"
att.displayNameShort = "H. Stock"
att.isBG = true

att.statModifiers = {RecoilMult = -0.1,
OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74heavystock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.heavy)
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)
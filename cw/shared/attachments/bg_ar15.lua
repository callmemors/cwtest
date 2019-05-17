local att = {}
att.name = "bg_ar15heavystock"
att.displayName = "Heavy stock"
att.displayNameShort = "H. stock"
att.isBG = true
att.SpeedDec = 2

att.statModifiers = {RecoilMult = -0.1,
OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar15heavystock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.heavy)
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ar15sturdystock"
att.displayName = "Sturdy stock"
att.displayNameShort = "S. stock"
att.isBG = true

att.statModifiers = {RecoilMult = -0.05,
OverallMouseSensMult = -0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar15sturdystock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.sturdy)
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ar1560rndmag"
att.displayName = "Quad-stack mag"
att.displayNameShort = "Quad"
att.isBG = true

att.statModifiers = {ReloadSpeedMult = -0.15,
OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar1560rndmag")
	att.description = {[1] = {t = "Increases mag size to 60 rounds.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.round60)
	self:unloadWeapon()
	self.Primary.ClipSize = 60
	self.Primary.ClipSize_Orig = 60
end

function att:detachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.regular)
	self:unloadWeapon()
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG_REAL
	self.Primary.ClipSize_Orig = self.Primary.ClipSize_ORIG_REAL
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_magpulhandguard"
att.displayName = "Magpul handguard"
att.displayNameShort = "Magpul"
att.isBG = true

att.statModifiers = {RecoilMult = 0.05,
	OverallMouseSensMult = 0.1,
	DrawSpeedMult = 0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar15magpul")
	att.description = {[1] = {t = "A comfortable, lightweight handguard.", c = CustomizableWeaponry.textColors.REGULAR}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.magpul)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_longbarrel"
att.displayName = "Long barrel"
att.displayNameShort = "LNGRNG"
att.isBG = true
att.SpeedDec = 2

att.statModifiers = {DamageMult = 0.1,
AimSpreadMult = -0.1,
RecoilMult = 0.1,
OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar15longbarrel")
	att.description = {[1] = {t = "A barrel for long range engagements.", c = CustomizableWeaponry.textColors.REGULAR}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.long)
	self:updateSoundTo("CW_AR15_LONGBARREL_FIRE", CustomizableWeaponry.sounds.UNSUPPRESSED)
	self:updateSoundTo("CW_AR15_LONGBARREL_FIRE_SUPPRESSED", CustomizableWeaponry.sounds.SUPPRESSED)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self:restoreSound()
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_longris"
att.displayName = "Long barrel RIS"
att.displayNameShort = "EXT RIS"
att.isBG = true
att.SpeedDec = 3

att.statModifiers = {DamageMult = 0.1,
AimSpreadMult = -0.1,
RecoilMult = 0.15,
OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar15longris")
	att.description = {[1] = {t = "A rail interface for long barrels.", c = CustomizableWeaponry.textColors.REGULAR},
	[2] = {t = "Allows additional attachments.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.longris)
	self:updateSoundTo("CW_AR15_LONGBARREL_FIRE", CustomizableWeaponry.sounds.UNSUPPRESSED)
	self:updateSoundTo("CW_AR15_LONGBARREL_FIRE_SUPPRESSED", CustomizableWeaponry.sounds.SUPPRESSED)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self:restoreSound()
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ris"
att.displayName = "RIS"
att.displayNameShort = "RIS"
att.isBG = true

att.statModifiers = {RecoilMult = 0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar15ris")
	att.description = {[1] = {t = "A rail interface.", c = CustomizableWeaponry.textColors.REGULAR},
	[2] = {t = "Allows additional attachments.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.ris)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_foldsight"
att.displayName = "Folding sights"
att.displayNameShort = "Fold"
att.isBG = true
att.isSight = true
att.aimPos = {"FoldSightPos", "FoldSightAng"}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/foldsight")
	att.description = {[1] = {t = "A folding variant of regular ironsights.", c = CustomizableWeaponry.textColors.COSMETIC}}
	
	function att:attachFunc()
		self:setBodygroup(self.SightBGs.main, self.SightBGs.foldsight)
	end
end

CustomizableWeaponry:registerAttachment(att)
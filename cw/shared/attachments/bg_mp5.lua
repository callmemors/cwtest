local att = {}
att.name = "bg_retractablestock"
att.displayName = "Retractable stock"
att.displayNameShort = "R. stock"
att.isBG = true
att.SpeedDec = -3

att.statModifiers = {DrawSpeedMult = 0.1,
OverallMouseSensMult = 0.1,
RecoilMult = 0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/retractablestock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.retractable)
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_nostock"
att.displayName = "No stock"
att.displayNameShort = "None"
att.isBG = true
att.SpeedDec = -5

att.statModifiers = {DrawSpeedMult = 0.2,
OverallMouseSensMult = 0.2,
RecoilMult = 0.2}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/nostock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.none)
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_mp530rndmag"
att.displayName = "30 round magazine"
att.displayNameShort = "30 RND"
att.isBG = true

att.statModifiers = {ReloadSpeedMult = -0.1,
OverallMouseSensMult = -0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/mp530rnd")
	att.description = {[1] = {t = "Increases mag size to 30 rounds.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.round30)
	self:unloadWeapon()
	self.Primary.ClipSize = 30
	self.Primary.ClipSize_Orig = 30
end

function att:detachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.round15)
	self:unloadWeapon()
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG_REAL
	self.Primary.ClipSize_Orig = self.Primary.ClipSize_ORIG_REAL
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_mp5_sdbarrel"
att.displayName = "SD variant"
att.displayNameShort = "SD"
att.isBG = true

att.statModifiers = {RecoilMult = -0.25,
AimSpreadMult = 0.3,
OverallMouseSensMult = 0.15,
FireDelayMult = 0.14285714285714}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/mp5_sdbarrel")
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.sd)
	self:setupCurrentIronsights(self.SDPos, self.SDAng)
	self:updateSoundTo("CW_MP5_FIRE_SUPPRESSED", CustomizableWeaponry.sounds.SUPPRESSED)
	self.ForegripOverride = true
	self.ForegripParent = "bg_mp5_sdbarrel"
	self.dt.Suppressed = true
	
	if not self:isAttachmentActive("sights") then
		self:updateIronsights("SD")
	end
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self:restoreSound()
	self:revertToOriginalIronsights()
	self.ForegripOverride = false
	self.dt.Suppressed = false
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_mp5_kbarrel"
att.displayName = "K variant"
att.displayNameShort = "Short"
att.isBG = true
att.SpeedDec = -5

att.statModifiers = {RecoilMult = -0.2,
AimSpreadMult = 0.7,
OverallMouseSensMult = 0.15,
DrawSpeedMult = 0.2,
FireDelayMult = -0.11111111111111}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/mp5_kbarrel")
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.k)
	self:setupCurrentIronsights(self.SDPos, self.SDAng)
	self:updateSoundTo("CW_MP5K_FIRE", CustomizableWeaponry.sounds.UNSUPPRESSED)
	self.ForegripOverride = true
	self.ForegripParent = "bg_mp5_kbarrel"
	self.MuzzleEffect = "muzzleflash_smg"
	
	if not self:isAttachmentActive("sights") then
		self:updateIronsights("K")
	end
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self:restoreSound()
	self:revertToOriginalIronsights()
	self.ForegripOverride = false
	self.MuzzleEffect = "muzzleflash_smg"
end

CustomizableWeaponry:registerAttachment(att)
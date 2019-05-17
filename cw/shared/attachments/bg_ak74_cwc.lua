local att = {}
att.name = "bg_ak74_ubarrel_cwc"
att.displayName = "-U Conversion"
att.displayNameShort = "AK-U"
att.isBG = true
att.categoryFactors = {cqc = 3}
att.SpeedDec = -3

att.statModifiers = {RecoilMult = -0.15,
AimSpreadMult = 1,
OverallMouseSensMult = 0.1,
DrawSpeedMult = 0.2,
MaxSpreadIncMult = 0.2,
DamageMult = -0.15,
FireDelayMult = -0.08}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74_ubarrel")
	att.description = {}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.short)
	self:setupCurrentIronsights(self.ShortenedPos, self.ShortenedAng)
	self:updateSoundTo("CWC_AK74_U_FIRE", CustomizableWeaponry.sounds.UNSUPPRESSED)
	self:updateSoundTo("CWC_AK74_U_FIRE_SUPPRESSED", CustomizableWeaponry.sounds.SUPPRESSED)
	
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
att.name = "bg_ak74_cwc_handguard"
att.displayName = "Heavy Handguard"
att.displayNameShort = "H. Handguard"
att.isBG = true

att.statModifiers = {
SpreadPerShotMult = 0.15,
RecoilMult = -0.05,
SpreadCooldownMult = 0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74_heavyhandguard")
	att.description = {[1] = {t = "Add weight to the front", c = CustomizableWeaponry.textColors.INFO}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regularhg)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ak74_cwc_rpkhandguard"
att.displayName = "Heavy Handguard"
att.displayNameShort = "H. Handguard"
att.isBG = true

att.statModifiers = {
SpreadPerShotMult = 0.15,
RecoilMult = -0.05,
SpreadCooldownMult = 0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74_heavyhandguard")
	att.description = {[1] = {t = "Add weight to the front", c = CustomizableWeaponry.textColors.INFO}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.rpkhg)
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.rpk)
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ak74_rpkbarrel_cwc"
att.displayName = "RPK Conversion"
att.displayNameShort = "RPK"
att.isBG = true
att.categoryFactors = {cqc = -1, lmg = 3}
att.SpeedDec = 10

att.statModifiers = {DamageMult = 0.1,
ADSSpeedMult = 10,
RecoilMult = 0.1,
AimSpreadMult = -0.2,
OverallMouseSensMult = -0.15,
FireDelayMult = 0.2}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74_rpkbarrel")
	att.description = {[1] = {t = "Comes with an integrated bipod", c = CustomizableWeaponry.textColors.INFO}}
end

function att:attachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.rpk)
	self:updateSoundTo("CWC_AK74_RPK_FIRE", CustomizableWeaponry.sounds.UNSUPPRESSED)
	self:updateSoundTo("CWC_AK74_RPK_FIRE_SUPPRESSED", CustomizableWeaponry.sounds.SUPPRESSED)
	self:setupCurrentIronsights(self.RPKPos, self.RPKAng)
	self.BipodInstalled = true
	
	if not self:isAttachmentActive("sights") then
		self:updateIronsights("RPK")
	end
end

function att:detachFunc()
	self:setBodygroup(self.BarrelBGs.main, self.BarrelBGs.regular)
	self.BipodInstalled = false
	
	self:restoreSound()
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "bg_ak74_smoothreciever_cwc"
att.displayName = "Smooth Reciever"
att.displayNameShort = "Smooth"
att.isBG = true

att.statModifiers = {DamageMult = 0.025,
SpreadPerShotMult = 0.3,
RecoilMult = -0.15,
SpreadCooldownMult = -0.1,
MaxSpreadIncMult = 0.2}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ak74_smoothreciever")
	att.description = {}
end

function att:attachFunc()
	self:setBodygroup(self.ReceiverBGs.main, self.ReceiverBGs.rpk)
end

function att:detachFunc()
	self:setBodygroup(self.ReceiverBGs.main, self.ReceiverBGs.regular)

end

CustomizableWeaponry:registerAttachment(att)
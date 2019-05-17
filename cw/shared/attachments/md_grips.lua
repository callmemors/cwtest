local att = {}
att.name = "md_foregrip"
att.displayName = "Vertical Foregrip"
att.displayNameShort = "V.Grip"

att.statModifiers = {VelocitySensitivityMult = -0.3,
DrawSpeedMult = -0.1,
RecoilMult = -0.2}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/foregrip")
	att.description = {[1] = {t = "Decreases muzzle rise", c = CustomizableWeaponry.textColors.POSITIVE},}
end

CustomizableWeaponry:registerAttachment(att)
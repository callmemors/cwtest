local att = {}
att.name = "md_m203"
att.displayName = "M203 Grenade Launcher"
att.displayNameShort = "M203"
att.isGrenadeLauncher = true

att.statModifiers = {DrawSpeedMult = -0.2,
OverallMouseSensMult = -0.2,
RecoilMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/m203")
	att.description = {[1] = {t = "Hold the same category button to change grenade type", c = CustomizableWeaponry.textColors.INFO},
	[2] = {t = "Can fire 40mm shells", c = CustomizableWeaponry.textColors.POSITIVE}}
	
	function att:attachFunc()
		self:resetM203Anim()
	end
	
	function att:detachFunc()
		self:resetM203Anim()
		self.dt.M203Active = false
		self.M203AngDiff = Angle(0, 0, 0)
	end
end

CustomizableWeaponry:registerAttachment(att)

CustomizableWeaponry:addReloadSound("CWC_M203_OPEN", {"weapons/cwc_m203/open1.wav", "weapons/cwc_m203/open2.wav", "weapons/cwc_m203/open3.wav"})
CustomizableWeaponry:addReloadSound("CWC_M203_CLOSE", {"weapons/cwc_m203/close1.wav", "weapons/cwc_m203/close2.wav"})
CustomizableWeaponry:addReloadSound("CWC_M203_REMOVE", {"weapons/cwc_m203/remove.wav"})
CustomizableWeaponry:addReloadSound("CWC_M203_POSITION", "weapons/cwc_m203/position1.wav", "weapons/cwc_m203/position2.wav")
CustomizableWeaponry:addReloadSound("CWC_M203_INSERT", {"weapons/cwc_m203/insert.wav"})
CustomizableWeaponry:addFireSound("CW_M203_FIRE", "weapons/cwc_m203/fire.wav", 1, 90, CHAN_STATIC)
CustomizableWeaponry:addFireSound("CW_M203_FIRE_BUCK", "weapons/cwc_m203/fire_buck.wav", 1, 100, CHAN_STATIC)

local att = {}
att.name = "md_bipod"
att.displayName = "Standard Bipod"
att.displayNameShort = "Bipod"

att.statModifiers = {OverallMouseSensMult = -0.1,
DrawSpeedMult = -0.15}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/bipod")
	att.description = {{t = "When Deployed:", c = CustomizableWeaponry.textColors.AMINFO},
	{t = "Greatly increases hip fire accuracy", c = CustomizableWeaponry.textColors.POSITIVE},
	{t = "Drastically decreases recoil", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self.BipodInstalled = true
end

function att:detachFunc()
	self.BipodInstalled = false
end

function att:elementRender()
	local model = self.AttachmentModelsVM.md_bipod.ent
	
	if self.dt.BipodDeployed then
		model:SetBodygroup(1, 1)
	else
		model:SetBodygroup(1, 0)
	end
end

CustomizableWeaponry:registerAttachment(att)
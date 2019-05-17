local att = {}
att.name = "md_acog"
att.displayName = "Trijicon ACOG /w/ Reflex Sight"
att.displayNameShort = "ACOG"
att.aimPos = {"ACOGPos", "ACOGAng"}
att.FOVModifier = 15
att.isSight = true

att.statModifiers = {OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/acog")
	att.description = {[1] = {t = "Provides 4x magnification", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Double-tap USE to toggle your reflex sight.", c = CustomizableWeaponry.textColors.INFO},
	[3] = {t = "Narrow scope reduces awareness", c = CustomizableWeaponry.textColors.NEGATIVE},
	[4] = {t = "Can be disorienting at close range", c = CustomizableWeaponry.textColors.NEGATIVE}}

	local old, x, y, ang
	local reticle = surface.GetTextureID("cw2/reticles/reticle_chevron")
	
	att.zoomTextures = {[1] = {tex = reticle, offset = {0, 1}}}
	
	local lens = surface.GetTextureID("cw2/gui/lense")
	local lensMat = Material("cw2/gui/lense")
	local cd, alpha = {}, 0.5
	local Ini = true
	
	-- render target var setup
	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 4.5
	cd.drawviewmodel = false
	cd.drawhud = false
	cd.dopostprocess = false
	
	function att:drawRenderTarget()
		local complexTelescopics = self:canUseComplexTelescopics()
		
		if not complexTelescopics then
			self.TSGlass:SetTexture("$basetexture", lensMat:GetTexture("$basetexture"))
			return
		end
		
		if self:canSeeThroughTelescopics(att.aimPos[1]) then
			alpha = math.Approach(alpha, 0.0, FrameTime() * self.ADSSpeed * 3 )
		else
			alpha = math.Approach(alpha, 0.985, FrameTime() * self.ADSSpeed * 3 )
		end
		
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()
	
		ang = self:getTelescopeAngles()
		
		if self.ViewModelFlip then
			ang.r = -self.BlendAng.z
		else
			ang.r = self.BlendAng.z
		end
		
		if not self.freeAimOn then
			ang:RotateAroundAxis(ang:Right(), self.ACOGAxisAlign.right)
			ang:RotateAroundAxis(ang:Up(), self.ACOGAxisAlign.up)
			ang:RotateAroundAxis(ang:Forward(), self.ACOGAxisAlign.forward)
		end
		
		local size = self:getRenderTargetSize()
		
		cd.w = size
		cd.h = size
		cd.angles = ang
		cd.origin = self.Owner:GetShootPos()
		render.SetRenderTarget(self.ScopeRT)
		render.SetViewPort(0, 0, size, size)
			if alpha < 1 or Ini then
				render.RenderView(cd)
				Ini = false
			end
			
			ang = self.Owner:EyeAngles()
			ang.p = ang.p + self.BlendAng.x
			ang.y = ang.y + self.BlendAng.y
			ang.r = ang.r + self.BlendAng.z
			ang = -ang:Forward()
			
			local light = render.ComputeLighting(self.Owner:GetShootPos(), ang)
			
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetTexture(reticle)
				surface.DrawTexturedRect(0, 0, size, size)
				
				surface.SetDrawColor(150 * light[1], 150 * light[2], 150 * light[3], 255 * alpha)
				surface.SetTexture(lens)
				surface.DrawTexturedRectRotated(size * 0.5, size * 0.5, size, size, 90)
			cam.End2D()
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)
		
		if self.TSGlass then
			self.TSGlass:SetTexture("$basetexture", self.ScopeRT)
		end
	end
end

function att:attachFunc()
	self.OverrideAimMouseSens = 0.35
	self.SimpleTelescopicsFOV = 70
	self.AimViewModelFOV = 50
	self.BlurOnAim = true
	self.ZoomTextures = att.zoomTextures
end

function att:detachFunc()
	self.OverrideAimMouseSens = nil
	self.SimpleTelescopicsFOV = nil
	self.AimViewModelFOV = self.AimViewModelFOV_Orig
	self.BlurOnAim = false
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_aimpoint"
att.displayName = "Aimpoint Carbine Optic"
att.displayNameShort = "Aimpoint"
att.aimPos = {"AimpointPos", "AimpointAng"}
att.FOVModifier = 20
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {OverallMouseSensMult = -0.07}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/compm4")
	att.description = {[1] = {t = "Hold the same category button to change color.", c = CustomizableWeaponry.textColors.INFO},
	[2] = {t = "May reduce awareness", c = CustomizableWeaponry.textColors.POSITIVE},
	[3] = {t = "Slightly increases aim zoom", c = CustomizableWeaponry.textColors.POSITIVE},
	[4] = {t = "Narrow scope may decrease awareness", c = CustomizableWeaponry.textColors.NEGATIVE}}
	
	att.reticle = "cw2/reticles/aim_reticule"
	att._reticleSize = 0.4
	
	function att:drawReticle()
		if not self:isAiming() or not self:isReticleActive() then
			return
		end
		
		diff = self:getDifferenceToAimPos(self.AimpointPos, self.AimpointAng, 1)
		
		-- draw the reticle only when it's close to center of the aiming position
		if diff > 0.9 and diff < 1.1 then
			cam.IgnoreZ(true)
				render.SetMaterial(att._reticle)
				dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.13)
				
				local EA = self:getReticleAngles()
				
				local renderColor = self:getSightColor(att.name)
				renderColor.a = (0.13 - dist) / 0.13 * 255
				
				local pos = EyePos() + EA:Forward() * 100
				
				for i = 1, 2 do
					render.DrawSprite(pos, att._reticleSize, att._reticleSize, renderColor)
				end
			cam.IgnoreZ(false)
		end
	end
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_eotech"
att.displayName = "EOTech 552"
att.displayNameShort = "EOTech"
att.aimPos = {"EoTechPos", "EoTechAng"}
att.FOVModifier = 15
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {OverallMouseSensMult = -0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/eotech553")
	att.description = {[1] = {t = "Hold the same category button to change color.", c = CustomizableWeaponry.textColors.INFO},
	[2] = {t = "May reduce awareness", c = CustomizableWeaponry.textColors.POSITIVE}}
	
	att.reticle = "cw2/reticles/eotech_reddot"
	att._reticleSize = 3

	function att:drawReticle()
		if not self:isAiming() or not self:isReticleActive() then
			return
		end
		
		diff = self:getDifferenceToAimPos(self.EoTechPos, self.EoTechAng, att._reticleSize)
		
		if diff > 0.9 and diff < 1.1 then
			cam.IgnoreZ(true)
				render.SetMaterial(att._reticle)
				dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.13)
				
				local EA = self:getReticleAngles()
				
				local renderColor = self:getSightColor(att.name)
				renderColor.a = (0.13 - dist) / 0.13 * 255
				
				local pos = EyePos() + EA:Forward() * 100
				
				for i = 1, 2 do
					render.DrawSprite(pos, att._reticleSize, att._reticleSize, renderColor)
				end
			cam.IgnoreZ(false)
		end
	end
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_kobra"
att.displayName = "Kobra EKP"
att.displayNameShort = "Kobra"
att.aimPos = {"KobraPos", "KobraAng"}
att.FOVModifier = 15
att.isSight = true
att.withoutRail = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {OverallMouseSensMult = -0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/kobra")
	att.description = {[1] = {t = "Hold the same category button to change color.", c = CustomizableWeaponry.textColors.INFO},
	[2] = {t = "May reduce awareness", c = CustomizableWeaponry.textColors.POSITIVE}}
	
	att.reticle = "cw2/reticles/kobra_sight"
	att._reticleSize = 2.5

	function att:drawReticle()
		if not self:isAiming() or not self:isReticleActive() then
			return
		end
		
		diff = self:getDifferenceToAimPos(self.KobraPos, self.KobraAng, att._reticleSize)

		-- draw the reticle only when it's close to center of the aiming position
		if diff > 0.9 and diff < 1.1 then
			cam.IgnoreZ(true)
				render.SetMaterial(att._reticle)
				dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.13)
				
				local EA = self:getReticleAngles()
				
				local renderColor = self:getSightColor(att.name)
				renderColor.a = (0.13 - dist) / 0.13 * 255
				
				local pos = EyePos() + EA:Forward() * 100
				
				for i = 1, 2 do
					render.DrawSprite(pos, att._reticleSize, att._reticleSize, renderColor)
				end
			cam.IgnoreZ(false)
		end
	end
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_microt1"
att.displayName = "Aimpoint Micro-T1"
att.displayNameShort = "MT1"
att.aimPos = {"MicroT1Pos", "MicroT1Ang"}
att.FOVModifier = 9
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/microt1")
	att.description = {[1] = {t = "Hold the same category button to change color.", c = CustomizableWeaponry.textColors.INFO},
	[2] = {t = "Provides a bright reticle to ease aiming", c = CustomizableWeaponry.textColors.POSITIVE},
	[3] = {t = "May reduce awareness", c = CustomizableWeaponry.textColors.NEGATIVE}}
	
	att.reticle = "cw2/reticles/aim_reticule"
	att._reticleSize = 0.25
	
	function att:drawReticle()
		if not self:isAiming() or not self:isReticleActive() then
			return
		end
		
		diff = self:getDifferenceToAimPos(self.MicroT1Pos, self.MicroT1Ang, 1)
		
		-- draw the reticle only when it's close to center of the aiming position
		if diff > 0.9 and diff < 1.1 then
			cam.IgnoreZ(true)
				render.SetMaterial(att._reticle)
				dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.13)
				
				local EA = self:getReticleAngles()
				
				local renderColor = self:getSightColor(att.name)
				renderColor.a = (0.13 - dist) / 0.13 * 255
				
				local pos = EyePos() + EA:Forward() * 100
				
				for i = 1, 2 do
					render.DrawSprite(pos, att._reticleSize, att._reticleSize, renderColor)
				end
			cam.IgnoreZ(false)
		end
	end
	
	function att:attachFunc()
		self.AimViewModelFOV = 40
	end
	
	function att:detachFunc()
		self.AimViewModelFOV = self.AimViewModelFOV_Orig
	end
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_nightforce_nxs"
att.displayName = "Nightforce NXS"
att.displayNameShort = "NXS"
att.aimPos = {"NXSPos", "NXSAng"}
att.FOVModifier = 15
att.isSight = true

att.statModifiers = {OverallMouseSensMult = -0.15}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/nightforce_nxs")
	att.description = {[1] = {t = "Provides 8x magnification", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Narrow scope reduces awareness", c = CustomizableWeaponry.textColors.NEGATIVE},
	[3] = {t = "Is very disorienting at close range", c = CustomizableWeaponry.textColors.NEGATIVE}}

	local old, x, y, ang
	local reticle = surface.GetTextureID("sprites/scope_leo")
	
	att.zoomTextures = {{tex = surface.GetTextureID("sprites/scope_leo"), offset = {0, 1}}}

	local lens = surface.GetTextureID("cw2/gui/lense")
	local lensMat = Material("cw2/gui/lense")
	local cd, alpha = {}, 0.5
	local Ini = true

	-- render target var setup
	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 3
	cd.drawviewmodel = false
	cd.drawhud = false
	cd.dopostprocess = false

	function att:drawRenderTarget()
		local complexTelescopics = self:canUseComplexTelescopics()
		
		-- if we don't have complex telescopics enabled, don't do anything complex, and just set the texture of the lens to a fallback 'lens' texture
		if not complexTelescopics then
			self.TSGlass:SetTexture("$basetexture", lensMat:GetTexture("$basetexture"))
			return
		end
		
		if self.dt.State == CW_AIMING then
			alpha = math.Approach(alpha, 0.0, FrameTime() * self.ADSSpeed * 3 )
		else
			alpha = math.Approach(alpha, 0.985, FrameTime() * self.ADSSpeed * 3 )
		end
		
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()

		ang = self:getTelescopeAngles()
		
		if self.ViewModelFlip then
			ang.r = -self.BlendAng.z
		else
			ang.r = self.BlendAng.z
		end
		
		if not self.freeAimOn then
			ang:RotateAroundAxis(ang:Right(), self.NXSAlign.right)
			ang:RotateAroundAxis(ang:Up(), self.NXSAlign.up)
			ang:RotateAroundAxis(ang:Forward(), self.NXSAlign.forward)
		end
		
		local size = self:getRenderTargetSize()

		cd.w = size
		cd.h = size
		cd.angles = ang
		cd.origin = self.Owner:GetShootPos()
		render.SetRenderTarget(self.ScopeRT)
		render.SetViewPort(0, 0, size, size)
			if alpha < 1 or Ini then
				render.RenderView(cd)
				Ini = false
			end
			
			ang = self.Owner:EyeAngles()
			ang.p = ang.p + self.BlendAng.x
			ang.y = ang.y + self.BlendAng.y
			ang.r = ang.r + self.BlendAng.z
			ang = -ang:Forward()
			
			local light = render.ComputeLighting(self.Owner:GetShootPos(), ang)
			
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetTexture(reticle)
				surface.DrawTexturedRect(0, 0, size, size)
				
				surface.SetDrawColor(150 * light[1], 150 * light[2], 150 * light[3], 255 * alpha)
				surface.SetTexture(lens)
				surface.DrawTexturedRectRotated(size * 0.5, size * 0.5, size, size, 90)
			cam.End2D()
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)
		
		if self.TSGlass then
			self.TSGlass:SetTexture("$basetexture", self.ScopeRT)
		end
	end
end

function att:attachFunc()
	self.OverrideAimMouseSens = 0.3
	self.SimpleTelescopicsFOV = 75
	self.AimViewModelFOV = 50
	self.BlurOnAim = true
	self.ZoomTextures = att.zoomTextures
	self.AimBreathingEnabled = true
end

function att:detachFunc()
	self.OverrideAimMouseSens = nil
	self.SimpleTelescopicsFOV = nil
	self.AimViewModelFOV = self.AimViewModelFOV_Orig
	self.BlurOnAim = false
	self:resetAimBreathingState()
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_pso1"
att.displayName = "PSO-1"
att.displayNameShort = "PSO-1"
att.aimPos = {"PSOPos", "PSOAng"}
att.FOVModifier = 15
att.isSight = true
att.withoutRail = true

att.statModifiers = {OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/pso1")
	att.description = {[1] = {t = "Provides 4x magnification", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Narrow scope reduces awareness", c = CustomizableWeaponry.textColors.NEGATIVE},
	[3] = {t = "Can be disorienting at close range", c = CustomizableWeaponry.textColors.NEGATIVE}}

	local old, x, y, ang
	local sight = surface.GetTextureID("cw2/reticles/scope_pso")
	local sightIllum = surface.GetTextureID("cw2/reticles/scope_pso_illum")
	att.zoomTextures = {[1] = {tex = sight, offset = {0, 1}},
		[2] = {tex = sightIllum, offset = {0, 0}}}
	
	local lens = surface.GetTextureID("cw2/gui/lense")
	local lensMat = Material("cw2/gui/lense")
	local cd, alpha = {}, 0.5
	local Ini = true
	
	-- render target var setup
	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 4.5
	cd.drawviewmodel = false
	cd.drawhud = false
	cd.dopostprocess = false
	
	function att:drawRenderTarget()
		local complexTelescopics = self:canUseComplexTelescopics()
		
		-- if we don't have complex telescopics enabled, don't do anything complex, and just set the texture of the lens to a fallback 'lens' texture
		if not complexTelescopics then
			self.TSGlass:SetTexture("$basetexture", lensMat:GetTexture("$basetexture"))
			return
		end
		
		if self:canSeeThroughTelescopics(att.aimPos[1]) then
			alpha = math.Approach(alpha, 0.0, FrameTime() * self.ADSSpeed * 3 )
		else
			alpha = math.Approach(alpha, 0.985, FrameTime() * self.ADSSpeed * 3 )
		end
		
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()
	
		ang = self:getTelescopeAngles()
		
		if not self.freeAimOn then
			ang:RotateAroundAxis(ang:Right(), self.PSO1AxisAlign.right)
			ang:RotateAroundAxis(ang:Up(), self.PSO1AxisAlign.up)
			ang:RotateAroundAxis(ang:Forward(), self.PSO1AxisAlign.forward)
		else
			ang:RotateAroundAxis(ang:Forward(), 90)
		end
		
		local size = self:getRenderTargetSize()
		
		cd.w = size
		cd.h = size
		cd.angles = ang
		cd.origin = self.Owner:GetShootPos()
		render.SetRenderTarget(self.ScopeRT)
		render.SetViewPort(0, 0, size, size)
			if alpha < 1 or Ini then
				render.RenderView(cd)
				Ini = false
			end
			
			ang = self.Owner:EyeAngles()
			ang.p = ang.p + self.BlendAng.x
			ang.y = ang.y + self.BlendAng.y
			ang.r = ang.r + self.BlendAng.z
			ang = -ang:Forward()
			
			local light = render.ComputeLighting(self.Owner:GetShootPos(), ang)
			
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetTexture(sight)
				surface.DrawTexturedRectRotated(size * 0.5, size * 0.5, size * 0.8, size * 0.8, 90)
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetTexture(sightIllum)
				surface.DrawTexturedRectRotated(size * 0.5, size * 0.5, size * 0.8, size * 0.8, 90)
				
				surface.SetDrawColor(150 * light[1], 150 * light[2], 150 * light[3], 255 * alpha)
				surface.SetTexture(lens)
				surface.DrawTexturedRectRotated(size * 0.5, size * 0.5, size, size, 90)
			cam.End2D()
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)
		
		if self.TSGlass then
			self.TSGlass:SetTexture("$basetexture", self.ScopeRT)
		end
	end
end

function att:attachFunc()
	self.OverrideAimMouseSens = 0.3
	self.SimpleTelescopicsFOV = 70
	self.AimViewModelFOV = 50
	self.BlurOnAim = true
	self.ZoomTextures = att.zoomTextures
end

function att:detachFunc()
	self.OverrideAimMouseSens = nil
	self.SimpleTelescopicsFOV = nil
	self.AimViewModelFOV = self.AimViewModelFOV_Orig
	self.BlurOnAim = false
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_rmr"
att.displayName = "Trijicon RMR"
att.displayNameShort = "RMR"
att.aimPos = {"RMRPos", "RMRAng"}
att.FOVModifier = 15
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/rmr")
	att.description = {[1] = {t = "May reduce awareness", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Slightly increases aim zoom.", c = CustomizableWeaponry.textColors.POSITIVE},
	[3] = {t = "Narrow scope may decrease awareness.", c = CustomizableWeaponry.textColors.NEGATIVE}}
	
	att.reticle = "cw2/reticles/aim_reticule"
	att._reticleSize = 0.4
	
	function att:drawReticle()
		if not self:isAiming() or not self:isReticleActive() then
			return
		end
		
		diff = self:getDifferenceToAimPos(self.RMRPos, self.RMRAng, 1)
		
		-- draw the reticle only when it's close to center of the aiming position
		if diff > 0.9 and diff < 1.1 then
			cam.IgnoreZ(true)
				render.SetMaterial(att._reticle)
				dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.13)
				
				local EA = self:getReticleAngles()
				
				local renderColor = self:getSightColor(att.name)
				renderColor.a = (0.13 - dist) / 0.13 * 255
				
				local pos = EyePos() + EA:Forward() * 100
				
				for i = 1, 2 do
					render.DrawSprite(pos, att._reticleSize, att._reticleSize, renderColor)
				end
			cam.IgnoreZ(false)
		end
	end
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "cwc_rmr"
att.displayName = "Trijicon RMR"
att.displayNameShort = "RMR"
att.aimPos = {"RMRPos", "RMRAng"}
att.FOVModifier = 15
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/rmr")
	att.description = {[1] = {t = "Hold the same category button to change color.", c = CustomizableWeaponry.textColors.INFO},
	[2] = {t = "Provides a bright reticle to ease aiming", c = CustomizableWeaponry.textColors.POSITIVE},
	[3] = {t = "Narrow scope may decrease awareness", c = CustomizableWeaponry.textColors.NEGATIVE}}
	
	att.reticle = "cw2/reticles/aim_reticule"
	att._reticleSize = 0.34
	
	function att:drawReticle()
		if not self:isAiming() or not self:isReticleActive() then
			return
		end
		
		diff = self:getDifferenceToAimPos(self.RMRPos, self.RMRAng, 1)
		
		-- draw the reticle only when it's close to center of the aiming position
		if diff > 0.9 and diff < 1.1 then
			cam.IgnoreZ(true)
				render.SetMaterial(att._reticle)
				dist = math.Clamp(math.Distance(1, 1, diff, diff), 0, 0.13)
				
				local EA = self:getReticleAngles()
				
				local renderColor = self:getSightColor(att.name)
				renderColor.a = (0.13 - dist) / 0.13 * 255
				
				local pos = EyePos() + EA:Forward() * 100
				
				for i = 1, 2 do
					render.DrawSprite(pos, att._reticleSize, att._reticleSize, renderColor)
				end
			cam.IgnoreZ(false)
		end
	end
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "md_schmidt_shortdot"
att.displayName = "Schmidt Police Marksman ShortDot"
att.displayNameShort = "ShortDot"
att.aimPos = {"ShortDotPos", "ShortDotAng"}
att.FOVModifier = 15
att.isSight = true

att.statModifiers = {OverallMouseSensMult = -0.1}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/shortdot")
	att.description = {[1] = {t = "Provides 1.25x magnification", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Narrow scope reduces awareness", c = CustomizableWeaponry.textColors.NEGATIVE},
	[3] = {t = "Can be disorienting at close range", c = CustomizableWeaponry.textColors.NEGATIVE}}

	local old, x, y, ang
	local reticle = surface.GetTextureID("cw2/reticles/aim_reticule")
	
	att.zoomTextures = {{tex = reticle, offset = {0, 1}, size = {16, 16}, color = Color(255, 0, 0, 150)},
		{tex = reticle, offset = {0, 1}, size = {8, 8}, color = Color(255, 0, 0, 255)}}
	
	local lens = surface.GetTextureID("cw2/gui/lense")
	local lensMat = Material("cw2/gui/lense")
	local cd, alpha = {}, 0.5
	local Ini = true
	
	-- render target var setup
	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 9
	cd.drawviewmodel = false
	cd.drawhud = false
	cd.dopostprocess = false
	
	function att:drawRenderTarget()
		local complexTelescopics = self:canUseComplexTelescopics()
		
		-- if we don't have complex telescopics enabled, don't do anything complex, and just set the texture of the lens to a fallback 'lens' texture
		if not complexTelescopics then
			self.TSGlass:SetTexture("$basetexture", lensMat:GetTexture("$basetexture"))
			return
		end
		
		if self:canSeeThroughTelescopics(att.aimPos[1]) then
			alpha = math.Approach(alpha, 0.0, FrameTime() * self.ADSSpeed * 3 )
		else
			alpha = math.Approach(alpha, 0.985, FrameTime() * self.ADSSpeed * 3 )
		end
		
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()
	
		ang = self:getTelescopeAngles()
		
		if self.ViewModelFlip then
			ang.r = -self.BlendAng.z
		else
			ang.r = self.BlendAng.z
		end
		
		if not self.freeAimOn then
			ang:RotateAroundAxis(ang:Right(), self.SchmidtShortDotAxisAlign.right)
			ang:RotateAroundAxis(ang:Up(), self.SchmidtShortDotAxisAlign.up)
			ang:RotateAroundAxis(ang:Forward(), self.SchmidtShortDotAxisAlign.forward)
		end
		
		local size = self:getRenderTargetSize()
		
		cd.w = size
		cd.h = size
		cd.angles = ang
		cd.origin = self.Owner:GetShootPos()
		render.SetRenderTarget(self.ScopeRT)
		render.SetViewPort(0, 0, size, size)
			if alpha < 1 or Ini then
				render.RenderView(cd)
				Ini = false
			end
			
			ang = self.Owner:EyeAngles()
			ang.p = ang.p + self.BlendAng.x
			ang.y = ang.y + self.BlendAng.y
			ang.r = ang.r + self.BlendAng.z
			ang = -ang:Forward()
			
			local light = render.ComputeLighting(self.Owner:GetShootPos(), ang)
			
			cam.Start2D()
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(size * 0.5 - 1, 0, 2, size) -- middle top-bottom
				surface.DrawRect(0, size * 0.5 - 1, size, 2) -- middle left-right
				
				local retSize = size * 0.02
				
				surface.SetDrawColor(255, 0, 0, 255)
				surface.SetTexture(reticle)
				surface.DrawTexturedRect(size * 0.5 - retSize * 0.5, size * 0.5 - retSize * 0.5, retSize, retSize)
				
				surface.SetDrawColor(150 * light[1], 150 * light[2], 150 * light[3], 255 * alpha)
				surface.SetTexture(lens)
				surface.DrawTexturedRectRotated(size * 0.5, size * 0.5, size, size, 90)
			cam.End2D()
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)
		
		if self.TSGlass then
			self.TSGlass:SetTexture("$basetexture", self.ScopeRT)
		end
	end
end

function att:attachFunc()
	self.OverrideAimMouseSens = 0.4
	self.SimpleTelescopicsFOV = 55
	self.AimViewModelFOV = 50
	self.BlurOnAim = true
	self.ZoomTextures = att.zoomTextures
end

function att:detachFunc()
	self.OverrideAimMouseSens = nil
	self.SimpleTelescopicsFOV = nil
	self.AimViewModelFOV = self.AimViewModelFOV_Orig
	self.BlurOnAim = false
end

CustomizableWeaponry:registerAttachment(att)

local att = {}
att.name = "cwc_goa1sight"
att.displayName = "GOA1 Carry Handle"
att.displayNameShort = "GOA1"
att.aimPos = {"GOA1Pos", "GOA1Ang"}
att.isSight = true

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/cwc_goa1sight")
	att.description = {[1] = {t = "An optional change to your ironsight", c = CustomizableWeaponry.textColors.COSMETIC},}
	
	function att:attachFunc()
	end
	
	function att:detachFunc()
	end
end

CustomizableWeaponry:registerAttachment(att)
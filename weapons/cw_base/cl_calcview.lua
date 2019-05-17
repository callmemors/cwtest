local FT, CT, cos1, cos2, ws, vel, att, ang
local Ang0, curang, curviewbob = Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0)
local reg = debug.getregistry()
local GetVelocity = reg.Entity.GetVelocity
local Length = reg.Vector.Length
local Right = reg.Angle.Right
local Up = reg.Angle.Up
local Forward = reg.Angle.Forward
local RotateAroundAxis = reg.Angle.RotateAroundAxis

SWEP.LerpBackSpeed = 10
SWEP.CurM203Angles = Angle(0, 0, 0)
SWEP.M203AngDiff = Angle(0, 0, 0)
SWEP.BreathFOVModifier = 0

-- free aim related vars start here
SWEP.lastEyeAngle = Angle(0, 0, 0)
SWEP.lastViewRoll = 0
SWEP.lastViewRollTime = 0
SWEP.forceFreeAimOffTime = false
SWEP.lastShotTime = 0
SWEP.curFOV = 100

SWEP.mouseX = 0
SWEP.mouseY = 0
SWEP.lastMouseActivity = 0

SWEP.autoCenterExclusions = {[CW_RUNNING] = true,
[CW_ACTION] = true,
[CW_HOLSTER_START] = true,
[CW_HOLSTER_END] = true} -- if the weapon's state is any of this, then we will force-auto-center if it is enabled
-- end here


local Ang0 = Angle(0, 0, 0)

function SWEP:getFreeAimToCenter()
	local ang = self.Owner:EyeAngles()
	
	return math.AngleDifference(self.lastEyeAngle.y, ang.y) + math.AngleDifference(self.lastEyeAngle.p, ang.p)
end

function SWEP:getFreeAimDotToCenter()
	local dist = self:getFreeAimToCenter()
	
	return dist / (GetConVarNumber("cw_freeaim_yawlimit") + GetConVarNumber("cw_freeaim_pitchlimit"))
end

function SWEP:CalcView(ply, pos, ang, fov)

	if GetConVarNumber("cwc_reload_bob") > 0 then
	self.ReloadViewBobEnabled = true
	else
	self.ReloadViewBobEnabled = false
	end

	self.freeAimOn = GetConVarNumber("cw_freeaim") > 0
	self.autoCenterFreeAim = GetConVarNumber("cw_freeaim_autocenter") > 0
	
	if self.dt.BipodDeployed then
		if not self.forceFreeAimOffTime then
			self.forceFreeAimOffTime = CurTime() + 0.5
		end
	else
		self.forceFreeAimOffTime = false
	end
	
	if self.freeAimOn then
		fov = 100 -- force FOV to 90 when in free aim mode, unfortunately, due to angles getting fucked up when FOV is not 90
		RunConsoleCommand("fov_desired", 100)
	end
	
	-- if we have free aim on, and we are not using a bipod, or we're using a bipod and we have not run out of "free aim time", then we should simulate free aim
	if self.freeAimOn and (not self.forceFreeAimOffTime or CurTime() < self.forceFreeAimOffTime) then
		if self.shouldUpdateAngles then
			self.lastEyeAngle = self.Owner:EyeAngles()
			self.shouldUpdateAngles = false
		else
			local dot = math.Clamp(math.abs(self:getFreeAimDotToCenter()) + 0.3, 0.3, 1)
			
			local lazyAim = GetConVarNumber("cw_freeaim_lazyaim")
			self.lastEyeAngle.y = math.NormalizeAngle(self.lastEyeAngle.y - self.mouseX * lazyAim * dot)
			local aiming = self.dt.State == CW_AIMING
			
			if not aiming and CurTime() > self.lastShotTime then -- we only want to modify pitch if we haven't shot lately
				self.lastEyeAngle.p = math.Clamp(self.lastEyeAngle.p + self.mouseY * lazyAim * dot, -89, 89)
			end
		end
		
		if self.autoCenterFreeAim then
			if self.mouseActive then
				self.lastMouseActivity = CurTime() + GetConVarNumber("cw_freeaim_autocenter_time")
			end
			
			local canAutoCenter = CurTime() > self.lastMouseActivity 
			local shouldAutoCenter = false
			local aimAutoCenter = GetConVarNumber("cw_freeaim_autocenter_aim") > 0
			
			if self.dt.State == CW_AIMING then
				if aimAutoCenter then 
					canAutoCenter = true
				else
					canAutoCenter = false
				end
			end
		
			if self.autoCenterExclusions[self.dt.State] then
				canAutoCenter = true
				shouldAutoCenter = true
			end
			
			if self.forceFreeAimOffTime then -- if we're being forced to turn free-aim off, do so
				canAutoCenter = true
				shouldAutoCenter = true
			end
		
			if canAutoCenter then
				local centerSpeed = FrameTime() * 16
				
				if self.autoCenterExclusions[self.dt.State] then
					shouldAutoCenter = true
				else
					if CurTime() > self.lastMouseActivity then
						shouldAutoCenter = true
						centerSpeed = FrameTime() * 6
					end
				end
					
				if shouldAutoCenter then
					self.lastEyeAngle = LerpAngle(centerSpeed, self.lastEyeAngle, self.Owner:EyeAngles())
				end
			end
		end
		
		local yawDiff = math.AngleDifference(self.lastEyeAngle.y, ang.y)
		local pitchDiff = math.AngleDifference(self.lastEyeAngle.p, ang.p)
		
		local yawLimit = GetConVarNumber("cw_freeaim_yawlimit")
		local pitchLimit = GetConVarNumber("cw_freeaim_pitchlimit")
		
		if yawDiff >= yawLimit then
			self.lastEyeAngle.y = math.NormalizeAngle(ang.y + yawLimit)
		elseif yawDiff <= -yawLimit then
			self.lastEyeAngle.y = math.NormalizeAngle(ang.y - yawLimit)
		end
		
		if pitchDiff >= pitchLimit then
			self.lastEyeAngle.p = math.NormalizeAngle(ang.p + pitchLimit)
		elseif pitchDiff <= -pitchLimit then
			self.lastEyeAngle.p = math.NormalizeAngle(ang.p - pitchLimit)
		end
		
		ang.y = self.lastEyeAngle.y
		ang.p = self.lastEyeAngle.p
		
		ang = ang
	else
		self.shouldUpdateAngles = true
	end
	
	FT, CT = FrameTime(), CurTime()
	
	local resetM203Angles = false
	
	self.M203CameraActive = false
	
	if self.AttachmentModelsVM then
		local m203 = self.AttachmentModelsVM.md_m203
		
		if m203 then
			if self.dt.State ~= CW_CUSTOMIZE then
				local CAMERA = m203.ent:GetAttachment(m203.ent:LookupAttachment("Camera")).Ang
				local modelAng = m203.ent:GetAngles()
				
				RotateAroundAxis(CAMERA, Right(CAMERA), self.M203CameraRotation.p)
				RotateAroundAxis(CAMERA, Up(CAMERA), self.M203CameraRotation.y)
				RotateAroundAxis(CAMERA, Forward(CAMERA), self.M203CameraRotation.r)

				local factor = math.abs(ang.p)
				local intensity = 1
				
				if factor >= 60 then
					factor = factor - 60
					intensity = math.Clamp(1 - math.abs(factor / 15), 0, 1)
				end
				
				self.M203AngDiff = math.NormalizeAngles((modelAng - CAMERA)) * 0.5 * intensity
			end
		end
	end
	
	ang = ang - self.M203AngDiff
	ang = ang - self.CurM203Angles * 0.5
	ang.r = ang.r + self.lastViewRoll
	
	if UnPredictedCurTime() > self.lastViewRollTime then
		self.lastViewRoll = Lerp(FrameTime() * 10, self.lastViewRoll, 0)
	end
	
	if UnPredictedCurTime() > self.FOVHoldTime or freeAimOn then
		self.FOVTarget = Lerp(FT * 10, self.FOVTarget, 0)
	end	
	
	if self.ReloadViewBobEnabled then
		if self.IsReloading and self.Cycle <= 0.9 then
			att = self.Owner:GetAttachment(1)
			
			if att then
				ang = ang * 1
				
				self.LerpBackSpeed = 1
				curang = LerpAngle(FT * 10, curang, (ang - att.Ang) * 0.1)
			else
				self.LerpBackSpeed = math.Approach(self.LerpBackSpeed, 10, FT * 50)
				curang = LerpAngle(FT * self.LerpBackSpeed, curang, Ang0)
			end
		else
			self.LerpBackSpeed = math.Approach(self.LerpBackSpeed, 10, FT * 50)
			curang = LerpAngle(FT * self.LerpBackSpeed, curang, Ang0)
		end

		RotateAroundAxis(ang, Right(ang), curang.p * self.RVBPitchMod)
		RotateAroundAxis(ang, Up(ang), curang.r * self.RVBYawMod)
		RotateAroundAxis(ang, Forward(ang), (curang.p + curang.r) * 0.15 * self.RVBRollMod)
	end
	
	if self.dt.State == CW_AIMING then
		if self.dt.M203Active and self.M203Chamber and not CustomizableWeaponry.grenadeTypes:canUseProperSights(self.Grenade40MM) then
			self.CurFOVMod = Lerp(FT * 10, self.CurFOVMod, 5)
		else
			local zoomAmount = self.ZoomAmount
			local simpleTelescopics = GetConVarNumber("cw_simple_telescopics")
			local shouldDelay = false
			
			if simpleTelescopics >= 1 then
				if self.SimpleTelescopicsFOV then
					zoomAmount = self.SimpleTelescopicsFOV
					shouldDelay = true
				end
			end
			
			if self.DelayedZoom or shouldDelay then
				if CT > self.AimTime then
					if self.SnapZoom or (self.SimpleTelescopicsFOV and simpleTelescopics >= 1) then
						self.CurFOVMod = zoomAmount
					else
						self.CurFOVMod = Lerp(FT * 10, self.CurFOVMod, zoomAmount)
					end
				else
					self.CurFOVMod = Lerp(FT * 10, self.CurFOVMod, 0)
				end
			else
				if self.SnapZoom or (self.SimpleTelescopicsFOV and simpleTelescopics >= 1) then
					self.CurFOVMod = zoomAmount
				else
					self.CurFOVMod = Lerp(FT * 10, self.CurFOVMod, zoomAmount)
				end
			end
		end
	else
		if GetConVarNumber("cwc_sprint_fov") > 0 then
			if self.dt.State == CW_RUNNING then
				self.CurFOVMod = math.Approach(self.CurFOVMod, 0, FT * 5)
				else
				self.CurFOVMod = Lerp(FT * 5, self.CurFOVMod, 0)
			end
		else
			if self.dt.State == CW_HOLSTER_START then
		self.CurFOVMod = self.CurFOVMod
		else
		self.CurFOVMod = Lerp(FT * 500, self.CurFOVMod, 0)
		end
		end
		
	end
	
	if self.holdingBreath then
		self.OverallMouseSens = 0.7
		self.BreathFOVModifier = math.Approach(self.BreathFOVModifier, 7, FT * 40)
	else
		self.OverallMouseSens = 1
		self.BreathFOVModifier = math.Approach(self.BreathFOVModifier, 0, FT * 50)
	end
	
	fov = math.Clamp(fov - self.CurFOVMod - self.BreathFOVModifier, 5, 110)
	
	if self.Owner then
		if self.ViewbobEnabled then
			ws = self.Owner:GetWalkSpeed()
			vel = Length(GetVelocity(self.Owner))
			
			if self.Owner:OnGround() and vel > ws * 0.25 then
				if vel < ws * 1.2 then
				
					
					if vel < ws * 0.7 then
						if self.Owner:Crouching() then
							mod = 0.5 + ws / 100
							cos1 = math.sin(CT ^ -mod * 2 + 1) * 0.5
							cos2 = math.cos(CT * -mod + 4.7) * 3
							cos3 = math.cos(cos1 * 1, 1 * 5) * 0.5 * -1
						else
							mod = 6
							cos1 = math.sin(CT ^ -mod * 2 + 1) * 0.5
							cos2 = math.cos(CT * -mod + 4.7) * 1
							cos3 = math.cos(cos1 * 1, 1 * 5) * 0.5 * -1
						end
					else
						mod = 8.55
					cos1 = math.sin(CT * -mod * 2 - 10) * 0.5
					cos2 = math.cos(CT * -mod + 5) * 3
					cos3 = math.cos(cos1 * 1, 1 * 1) * 0.5 * -1
					end
				
				
					-- cos1 = math.cos(CT * 16)
					-- cos2 = math.cos(CT * 4)
					-- cos3 = math.cos(CT * 8)
					curviewbob.p = cos1 * -0.2
					curviewbob.y = cos2 * 0.1
					curviewbob.z = cos3 * 0.05
				else
					cos1 = math.cos(CT * 20)
					cos2 = math.cos(CT * 10)
					cos3 = math.sin(CT * 10)
					curviewbob.p = cos1 * 0.4
					curviewbob.y = cos2 * 0.5
					curviewbob.z = cos3 * -0.7
				end
			else
				curviewbob = LerpAngle(FT * 10, curviewbob, Ang0)
			end
		end
	end
	
	fov = fov - self.FOVTarget
	self.curFOV = fov
	
	return pos, ang + curviewbob * self.ViewbobIntensity, fov
end

function SWEP:reduceBreathAmount(recoilMod, regenTime)
	-- recoilMod = recoilMod or 0.2
	-- regenTime = regenTime or self.BreathRegenDelay
	
	-- self.breathRegenWait = CurTime() + regenTime
	-- self.BreathLeft = math.Clamp(self.BreathLeft - self.Recoil * recoilMod * 0.25, 0, 1)
end

function SWEP:stopHoldingBreath(time, regenTime, recoilMod)
	if self.holdingBreath then
		time = time or self.BreathDelay
		regenTime = regenTime or self.BreathRegenDelay
		
		self.holdingBreath = false
		self.breathWait = CurTime() + time * 0.05
		self:reduceBreathAmount(recoilMod) -- if we're aiming, reduce it by using the recoilMod variable passed on to us
		self:EmitSound("CWC_UNFOCUS")
	else
		self.breathRegenWait = CurTime() + 0.1
	end
end

function SWEP.CreateMove(move)
	ply = LocalPlayer()
	wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.CW20Weapon then
		local FT = FrameTime()
		local CT = CurTime()
		
		local shouldFreeze = false
		
		local mouseSensitivityMod = wep:AdjustMouseSensitivity() -- we should ignore mouse sensitivity into account when adjusting via mouse movement
		
		-- make sure we're: 1) customizing; 2) are in the adjustment tab; 3) have an active attachment
		if wep.dt.State == CW_CUSTOMIZE then
			shouldFreeze = CustomizableWeaponry.callbacks.processCategory(wep, "shouldFreezeView", move:GetMouseX() / mouseSensitivityMod)
			local canAdjustAttachment = false
			
			if type(shouldFreeze) == "bool" then
				canAdjustAttachment = not shouldFreeze
			else
				canAdjustAttachment = true
			end
			
			if canAdjustAttachment then
				canAdjustAttachment = wep.CustomizationTab == CustomizableWeaponry.interactionMenu.TAB_ATTACHMENT_ADJUSTMENT and CustomizableWeaponry.sightAdjustment:getCurrentAttachment() and ply:KeyDown(IN_ATTACK)
			end
			
			--if wep.CustomizationTab == CustomizableWeaponry.interactionMenu.TAB_ATTACHMENT_ADJUSTMENT and CustomizableWeaponry.sightAdjustment:getCurrentAttachment() then
			--	if ply:KeyDown(IN_ATTACK) then
			
			if canAdjustAttachment then
				ply._holdAngles = ply._holdAngles or ply:EyeAngles()
					
				move:SetViewAngles(ply._holdAngles) -- prevent moving of the view area while adjusting attachment position
				CustomizableWeaponry.sightAdjustment:adjust(wep, move:GetMouseX() * 0.001 / mouseSensitivityMod)
				return
			end
		end
		
		if shouldFreeze == false then
			ply._holdAngles = nil
		elseif shouldFreeze == true then
			ply._holdAngles = ply._holdAngles or ply:EyeAngles()
				
			move:SetViewAngles(ply._holdAngles) -- prevent moving of the view area while adjusting attachment position
			return
		end
		
		if wep.freeAimOn then
			wep.mouseX = move:GetMouseX()
			wep.mouseY = move:GetMouseY()
			
			wep.mouseActive = wep.mouseX ~= 0 or wep.mouseY ~= 0
		end
		
		local vel = ply:GetVelocity():Length()
		
		-- if wep.AimBreathingEnabled then
			-- if wep.holdingBreath then
				-- if vel > wep.BreathHoldVelocityMinimum and CT > wep.breathReleaseWait then
					-- wep:stopHoldingBreath(nil, nil, 0)
					-- wep.noBreathHoldingUntilKeyRelease = true
				-- else
					-- wep.CurBreatheIntensity = math.Approach(wep.CurBreatheIntensity, 0.07, FT * wep.BreathIntensityDrainRate)
					
					-- if CT > wep.breathReleaseWait then
						-- wep.BreathLeft = math.Approach(wep.BreathLeft, 0, FT * wep.BreathDrainRate)
					-- end
					
					-- if wep.BreathLeft <= 0 then
						-- wep:stopHoldingBreath(nil, nil, 0)
						-- wep.noBreathHoldingUntilKeyRelease = true
					-- end
				-- end
			-- else
				-- if CT > wep.breathRegenWait then
					-- wep.BreathLeft = math.Approach(wep.BreathLeft, 1, FT * wep.BreathRegenRate)
				-- end
				
				-- wep.CurBreatheIntensity = math.Approach(wep.CurBreatheIntensity, 1, FT * wep.BreathIntensityRegenRate)
			-- end
		-- end
		
		if wep.dt and wep.dt.State == CW_AIMING then
			-- if wep.AimBreathingEnabled then
				if wep.dt.State == CW_AIMING then
					if wep.Owner:KeyDown(IN_SPEED) then
						if CT > wep.breathWait then
							if not wep.noBreathHoldingUntilKeyRelease and vel < wep.BreathHoldVelocityMinimum then
								-- can only start holding breath if we have at least 50% of our breath
								if not wep.holdingBreath and wep.BreathLeft >= wep.MinimumBreathPercentage then
									wep.holdingBreath = true
									wep.breathReleaseWait = CT + 0.1
									wep:EmitSound("CWC_UNFOCUS")
								end
							end
						end
					else
						if CT > wep.breathReleaseWait then
							if wep.holdingBreath then
								wep:stopHoldingBreath(nil, nil, 0)
							end
							
							wep.noBreathHoldingUntilKeyRelease = false
						end
					end
				end
			-- end
		
			ang = move:GetViewAngles()
					
			-- ang.p = ang.p - math.cos(CT * 0.2) * math.tan(-0.005, 0.005) * math.sin(1/50000)
			-- ang.y = ang.y + math.sin(CT * 2.8 * math.cos(-0.2, 1000)) * 0.001 * wep.AimBreathingIntensity * wep.CurBreatheIntensity * 2
			ang.p = ang.p - math.cos(CT * 2.25) * math.tan(-0.02, 0.02) * math.sin(1/2) * wep.CurBreatheIntensity * 0.5
			ang.y = ang.y + math.sin(CT * 2.8 * math.cos(-0.2, 1000)) * 0.001 * wep.AimBreathingIntensity * wep.CurBreatheIntensity * 2
			
			move:SetViewAngles(ang)
		end
		
		if wep.dt.BipodDeployed and wep.DeployAngle then
			ang = move:GetViewAngles()
			
			local EA = ply:EyeAngles()
			dif = math.AngleDifference(EA.y, wep.DeployAngle.y)
			
			if dif >= wep.BipodAngleLimitYaw then
				ang.y = wep.DeployAngle.y + wep.BipodAngleLimitYaw
			elseif dif <= -wep.BipodAngleLimitYaw then
				ang.y = wep.DeployAngle.y - wep.BipodAngleLimitYaw
			end
			
			dif = math.AngleDifference(EA.p, wep.DeployAngle.p)
			
			if dif >= wep.BipodAngleLimitPitch then
				ang.p = wep.DeployAngle.p + wep.BipodAngleLimitPitch
			elseif dif <= -wep.BipodAngleLimitPitch then
				ang.p = wep.DeployAngle.p - wep.BipodAngleLimitPitch
			end

			move:SetViewAngles(ang)
		end
	end
end

hook.Add("CreateMove", "SWEP.CreateMove (SWB)", SWEP.CreateMove)

function SWEP:AdjustMouseSensitivity()
	local sensitivity = 1
	local mod = math.Clamp(self.OverallMouseSens, 0.1, 1) -- not lower than 10% and not higher than 100% (in case someone uses atts that increase handling)
	local freeAimMod = 1
	
	if self.freeAimOn and not self.dt.BipodDeployed then
		local dist = math.abs(self:getFreeAimDotToCenter())
		
		local mouseImpendance = GetConVarNumber("cw_freeaim_center_mouse_impendance")
		freeAimMod = 1 - (mouseImpendance - mouseImpendance * dist)
	end
	
	if self.dt.State == CW_RUNNING then
			if GetConVarNumber("cwc_sprint_fov") > 0 then
				self.CurFOVMod = math.Approach(self.CurFOVMod, -10, FT * 15)
			end
		if self.RunMouseSensMod then
			return self.RunMouseSensMod * mod
		end
	end
	
	if self.dt.State == CW_AIMING then
		-- if we're aiming and our aiming position is that of the sight we have installed - decrease our mouse sensitivity
		if (self.OverrideAimMouseSens and self.AimPos == self.ActualSightPos) and (self.dt.M203Active and CustomizableWeaponry.grenadeTypes:canUseProperSights(self.Grenade40MM) or not self.dt.M203Active) then
			--return self.OverrideAimMouseSens * mod
			sensitivity = self.OverrideAimMouseSens
		end
		
		--return math.Clamp(1 - self.ZoomAmount / 100, 0.1, 1) * mod 
		sensitivity = math.Clamp(sensitivity - self.ZoomAmount / 100, 0.1, 1) 
	end
	
	sensitivity = sensitivity * mod
	sensitivity = sensitivity * freeAimMod
	
	return sensitivity --1 * self.OverallMouseSens
end
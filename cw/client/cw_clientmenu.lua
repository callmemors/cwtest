local function CW2_GetLaserQualityText(level)
	if level <= 1 then
		return " Normal"
	end
	
	return " High"
end

CustomizableWeaponry.renderTargetSizes = {[1] = {size = 256, text = "Low"},
	[2] = {size = 512, text = "Medium"},
	[3] = {size = 768, text = "High"},
	[4] = {size = 1024, text = "Ultra"}}
	
function CustomizableWeaponry:clampRenderTargetLevel(level)
	return math.Clamp(level, 1, #self.renderTargetSizes)
end

function CustomizableWeaponry:getRenderTargetData(level)
	return self.renderTargetSizes[self:clampRenderTargetLevel(level)]
end

function CustomizableWeaponry:getRenderTargetText(level)
	return self.renderTargetSizes[self:clampRenderTargetLevel(level)].text
end

function CustomizableWeaponry:getRenderTargetSize(level)
	return self.renderTargetSizes[self:clampRenderTargetLevel(level)].size
end

local function CW2_ClientsidePanel(panel)
	panel:ClearControls()
	
	panel:AddControl("Label", {Text = "HUD Settings"})
	
	panel:AddControl("CheckBox", {Label = "Custom HUD", Command = "cw_customhud"})
	panel:AddControl("CheckBox", {Label = "Dynamic HUD", Command = "cw_customhud_ammo"})
	panel:AddControl("CheckBox", {Label = "Crosshair", Command = "cw_crosshair"})
	
	panel:AddControl("Label", {Text = "Visual Settings"})
	
	panel:AddControl("CheckBox", {Label = "Blur on RELOADING", Command = "cw_blur_reload"})
	panel:AddControl("CheckBox", {Label = "Blur on CUSTOMIZE", Command = "cw_blur_customize"})
	panel:AddControl("CheckBox", {Label = "Blur on RT AIMING", Command = "cw_blur_aim_telescopic"})
	panel:AddControl("CheckBox", {Label = "Disable RT Scopes", Command = "cw_simple_telescopics"})
	
	panel:AddControl("CheckBox", {Label = "Free Aim", Command = "cw_freeaim"})
	panel:AddControl("CheckBox", {Label = "Automatic center", Command = "cw_freeaim_autocenter"})
	panel:AddControl("CheckBox", {Label = "Auto center on aim", Command = "cw_freeaim_autocenter_aim"})
	
		-- local slider = vgui.Create("DNumSlider", panel)
	-- slider:SetDecimals(0)
	-- slider:SetMin(0)
	-- slider:SetMax(2)
	-- slider:SetConVar("cwc_shell_audio")
	-- slider:SetValue(GetConVarNumber("cwc_shell_audio"))
	-- slider:SetText("Shell Audio")
	-- slider:SetText("(0: Mute, 1: Default, 2: Minimal")
	
	-- panel:AddItem(slider)
	
	-- autocenter time slider
	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(2)
	slider:SetMin(0.1)
	slider:SetMax(2)
	slider:SetConVar("cw_freeaim_autocenter_time")
	slider:SetValue(GetConVarNumber("cw_freeaim_autocenter_time"))
	slider:SetText("Auto center timer")
	
	panel:AddItem(slider)
	
	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(2)
	slider:SetMin(0)
	slider:SetMax(0.9)
	slider:SetConVar("cw_freeaim_center_mouse_impendance")
	slider:SetValue(GetConVarNumber("cw_freeaim_center_mouse_impendance"))
	slider:SetText("Mouse Impendance")
	
	panel:AddItem(slider)
	
	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(3)
	slider:SetMin(0)
	slider:SetMax(0.05)
	slider:SetConVar("cw_freeaim_lazyaim")
	slider:SetValue(GetConVarNumber("cw_freeaim_lazyaim"))
	slider:SetText("Lazy Aim")
	
	panel:AddItem(slider)
	
	-- pitch limit
	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(1)
	slider:SetMin(5)
	slider:SetMax(15)
	slider:SetConVar("cw_freeaim_pitchlimit")
	slider:SetValue(GetConVarNumber("cw_freeaim_pitchlimit"))
	slider:SetText("Pitch Limit")
	
	panel:AddItem(slider)
	
	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(1)
	slider:SetMin(5)
	slider:SetMax(30)
	slider:SetConVar("cw_freeaim_yawlimit")
	slider:SetValue(GetConVarNumber("cw_freeaim_yawlimit"))
	slider:SetText("Yaw Limit")
	
	panel:AddItem(slider)
	
	local laserQ = vgui.Create("DComboBox", panel)
	laserQ:SetText("Laser quality:" .. CW2_GetLaserQualityText(GetConVarNumber("cw_laser_quality")))
	laserQ.ConVar = "cw_laser_quality"
	
	laserQ:AddChoice("Normal")
	laserQ:AddChoice("High")
	
	laserQ.OnSelect = function(panel, index, value, data)
		laserQ:SetText("Laser Quality:" .. CW2_GetLaserQualityText(tonumber(index)))
		RunConsoleCommand(laserQ.ConVar, tonumber(index))
	end
	
	panel:AddItem(laserQ)
	
	local rtScope = vgui.Create("DComboBox", panel)
	rtScope:SetText("RT Scope Quality".. " " .. CustomizableWeaponry:getRenderTargetText(GetConVarNumber("cw_rt_scope_quality")))
	rtScope.ConVar = "cw_rt_scope_quality"
	
	for key, data in ipairs(CustomizableWeaponry.renderTargetSizes) do
		rtScope:AddChoice(data.text)
	end
	
	rtScope.OnSelect = function(panel, index, value, data)
		index = tonumber(index)
		
		rtScope:SetText("RT Quality:" .. " " .. CustomizableWeaponry:getRenderTargetText(index))
		local prevQuality = GetConVarNumber(rtScope.ConVar)
		
		RunConsoleCommand(rtScope.ConVar, index)
		local wepBase = weapons.GetStored("cw_base")
		
		if prevQuality ~= tonumber(index) then -- only re-create the render target in case we changed the quality
			wepBase:initRenderTarget(CustomizableWeaponry:getRenderTargetSize(index))
		end
	end
	
	panel:AddItem(rtScope)
	
	panel:AddControl("Label", {Text = "Misc"})
	
	panel:AddControl("CheckBox", {Label = "Alternative Viewmodel Position", Command = "cw_alternative_vm_pos"})
	
	panel:AddControl("Button", {Label = "Drop CW2.0 SWEP, Command", Command = "cw_dropweapon"})
end

local function CW2_AdminPanel(panel)
	if not LocalPlayer():IsAdmin() then
		panel:AddControl("Label", {Text = "Not an admin - don't look here."})
		return
	end
	
	panel:AddControl("CheckBox", {Label = "Physical Bullets (will require a map reload", Command = "cw_physical_bullets"})
	panel:AddControl("Label", {Text = ""})
	
	
	local checkBox = "CheckBox"
	local baseText = "ON SPAWN: Give '"
	local questionMark = "'?"
	
	panel:AddControl(checkBox, {Label = "Keep attachments on Death?", Command = "cw_keep_attachments_post_death"})
	
	for k, v in ipairs(CustomizableWeaponry.registeredAttachments) do
		if v.displayName and v.clcvar then
			panel:AddControl(checkBox, {Label = baseText .. v.displayName .. questionMark, Command = v.clcvar})
		end
	end
	
	panel:AddControl("Button", {Label = "Apply Changes", Command = "cw_applychanges"})
end

local function CWC_CWCPanel(panel)
	panel:AddControl("Label", {Text = "Exclusive settings for the Cturiselection Base."})
	panel:AddControl("Label", {Text = ""})
	panel:AddControl("Label", {Text = ""})

	panel:AddControl("CheckBox", {Label = "Change FOV when sprinting?", Command = "cwc_sprint_fov"})
	panel:AddControl("CheckBox", {Label = "Camera wobble when reloading?", Command = "cwc_reload_bob"})
	panel:AddControl("CheckBox", {Label = "FOV Punch when firing?", Command = "cwc_fovpunch"})
	panel:AddControl("CheckBox", {Label = "Spawn weapon with SAFETY mode?", Command = "cwc_spawnwithsafemode"})
	
	panel:AddControl("Label", {Text = "Advanced Audio Control"})
	panel:AddControl("Label", {Text = ""})
	panel:AddControl("Label", {Text = ""})
	
	panel:AddControl("CheckBox", {Label = "Enable 'Lowcount' Subsound?", Command = "cwc_subsound_lowcount"})
	panel:AddControl("Label", {Text = "The click when mag is near empty"})
	panel:AddControl("Label", {Text = ""})
	
	panel:AddControl("CheckBox", {Label = "Enable 'POV' Subsound?", Command = "cwc_subsound_pov"})
	panel:AddControl("Label", {Text = "The ammo-specific sounds and suppressor pews"})
	panel:AddControl("Label", {Text = ""})
	
	panel:AddControl("CheckBox", {Label = "Enable 'Empty' Subsound?", Command = "cwc_subsound_empty"})
	panel:AddControl("Label", {Text = "The empty click when mag is empty"})
	panel:AddControl("Label", {Text = ""})
	
	-- panel:AddControl("CheckBox", {Label = loc('cwc_clientmenu_audio_echo'), Command = "cw_subsound_echo"})
	-- panel:AddControl("CheckBox", {Label = loc('cwc_clientmenu_audio_distant'), Command = "cw_subsound_distant"})
end

local function CW2_PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "CW 2.0 SWEPs", "CW 2.0 Client", "Client", "", "", CW2_ClientsidePanel)
	spawnmenu.AddToolMenuOption("Utilities", "CW 2.0 SWEPs", "CW 2.0 Admin", "Admin", "", "", CW2_AdminPanel)
	spawnmenu.AddToolMenuOption("Utilities", "CW 2.0 SWEPs", "CWC Client", "CWC Client", "", "", CWC_CWCPanel)
end

hook.Add("PopulateToolMenu", "CW2_PopulateToolMenu", CW2_PopulateToolMenu)
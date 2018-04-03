function gearsOff()
	enable = false
	toggleGtaSounds(enable)
	outputChatBox("Vehicle gears disabled. Original GTA handling enabled. To enable gears, use /gearson. For help, use /helpgears")
	if engineSound then
		stopSound(engineSound)
		stopSound(turboSound)
	end
	saveSettings()
end
addCommandHandler("gearsoff", gearsOff)

function gearsOn()
	enable = true
	toggleGtaSounds(enable)
	startEngineSound(getLocalPlayer(),0)
	outputChatBox("Vehicle gears enabled. To disable them, use /gearsoff. For help, use /helpgears")
	saveSettings()
end
addCommandHandler("gearson", gearsOn)

function gearsAuto()
	autogearbox = true
	outputChatBox("Automatic transmission enabled. To change to manual transmission, use /gearsmanual. For help, use /helpgears")
	saveSettings()
end
addCommandHandler("gearsauto", gearsAuto)

function gearsManual()
	autogearbox = false
	outputChatBox("Manual transmission enabled. To change to automatic transmission, use /gearsauto. For help, use /helpgears")
	saveSettings()
end
addCommandHandler("gearsmanual", gearsManual)

function checkControls()
	local binds
	binds = getBoundKeys("shiftup")
	if not binds then
		bindKey(",","down","shiftup")
		outputChatBox("Use , (comma) to Shift Up the gears in your car.")
	end
	binds = getBoundKeys("shiftdown")
	if not binds then
		bindKey(".","down","shiftdown")
		outputChatBox("Use . (period) to Shift Down the gears in your car.")
	end
	outputChatBox("You can use manual or automatic transmission in your car. For help, use /helpgears.")
end

function helpGears(commandName)
	local bindsUp
	local bindsDown
	bindsUp = getBoundKeys("shiftup")
	bindsDown = getBoundKeys("shiftdown")
	local upString = ""
	local downString = ""
	for keyName,state in pairs(bindsUp) do
		upString = upString .. keyName .. "   "
	end
	for keyName,state in pairs(bindsDown) do
		downString = downString .. keyName .. "   "
	end
	outputChatBox("You can use manual or automatic transmission in your car.")
	outputChatBox("To enable manual transmission, use /gearsmanual. To enable automatic transmission, use /gearsauto.")
	outputChatBox("Keys to Shift Up:    " .. upString)
	outputChatBox("Keys to Shift Down:     " .. downString)
	outputChatBox("You can redefine these binds in your Settings (Binds > Multiplayer Controls), on \"shiftup\" and \"shiftdown\", including setting them to gamepad buttons.")
	outputChatBox("You can go back to the normal MTA/GTA handling by disabling the gears with /gearsoff.")
	if enable and autogearbox then outputChatBox("Transmission is currently automatic.") end
	if enable and not autogearbox then outputChatBox("Transmission is currently manual.") end
end
addCommandHandler("helpgears", helpGears)
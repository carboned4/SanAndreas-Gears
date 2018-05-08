enable=true
autogearbox=true
local enableForVehicle=false
local xmlRoot = nil
local vehicleId = false
local currentVehicle = false

local spoolUpdateCounter = 0
local spoolUpdateFrequency = 0.25

allNodes = {}
local counterNonPlayerUpdateInterval = 0.02
local counterNonPlayerUpdate = counterNonPlayerUpdateInterval

-- GENERAL VARIABLES (speed, turbo, controls)
local currentGear = 1
local vel
local velratio
local spool = 0.0
local currentAccelerateState = 0.0
local previousAccelerateState = 0.0
local currentBrakeState = 0.0
local limiterCounter = 0
local spoolBegin = 0.3

local offGear = false
local offGearCounter = 0
local offGearTime = 4
local offGearIncrement = false

-- SOUND ELEMENTS
local soundspeed
engineSound = false
turboSound = false
local blowOffSound
local backfireSound
local starterSound
local echoOn = false

-- CAR DEPENDENT
--local revLimit = 8000 -- v12lambo, v10carrera, v12nfs, i6straight, v8ferrari, i6skyline
--local revLimit = 13000 -- v12f1
--local revLimit = 6000 -- v10viper, f6porsche, i4slow, i6bmw, v6slow, v8slow
--local revLimit = 7000 -- v8audi, v8u2
--local revLimit = 3000 -- truck
--local revLimit = 5000 -- v8old
--local revLimit = 9000 -- rotary
local revLimit = 8000 -- test

--local soundBase = 7200 -- v12f1 (13000)
--local soundBase = 5000 -- v8audi (7000)
--4500 - v8amg (7000)
--local soundBase = 4250 -- v10viper (6000), i6straight (8000), v8u2 (7000), v8ferrari (8000), i6skyline(8000)
--local soundBase = 3750 -- 10carrera (8000)
--local soundBase = 3500 -- v12lambo (8000), v12nfs (8000), f6porsche (6000), i4slow (6000), i6bmw (6000), v6slow (6000)
--local soundBase = 750 -- truck (3000)
--local soundBase = 2500 -- v8old (5000), v8slow (6000)
--local soundBase = 4500 -- rotary (9000)
local soundBase = 3500 -- test

local soundName = "v12lambo.wav"
local soundVolume
local numberGears = 5
local hasTurbo = 1
local hasBackfire = 1
local turboBoostFactor = 2
local exhaustNumber = 2
local vehicleType


local speeds = {1000, 80, 120, 180, 250, 300}
local accelerations = {0, 60, 35, 25, 17, 15}
local inertias = {5, 150, 160, 180, 210, 250}

-- TACHOMETER (RPMs) -- depends on CAR DEPENDENT (so far)
local neutralRevs = 0.1
local limiterRevs = 1.0
local absoluteMaxRev = 13500
local firstRedline = revLimit-500
local revExtreme = revLimit+1000
local anglePerThousand = 20


function changeGear ( commandName, gearNumber )
    --outputChatBox ( gearNumber)
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if vehicle then
		if getLocalPlayer() == getVehicleOccupant(vehicle, 0) then
			triggerServerEvent ( "onGearChange", resourceRoot, vehicle, gearNumber, speeds[gearNumber], accelerations[gearNumber], inertias[gearNumber] )
			if hasTurbo == 1 then
				blowOffSound = playSound("BlowOff1.wav", false, false)
				setSoundVolume(blowOffSound, spool)
			end
			spool = 0.0
			
		end
	end
    --outputChatBox ( speeds[gearNumber] .. accelerations[gearNumber] .. inertias[gearNumber] )
end
addCommandHandler ( "changegear", changeGear )

function shiftUp(commandName)
	if not enable or not enableForVehicle then return end
	if getLocalPlayer() ~= getVehicleOccupant(getPedOccupiedVehicle(getLocalPlayer()), 0) then return
	end
	if currentGear == numberGears then return
	end
	currentGear = math.min(currentGear+1,numberGears)
	changeGear ( "changegear", currentGear )
	offGear = true
	offGearCounter = 1
	if (velratio > 0.1 and currentGear >= 1) then
		offGearIncrement = (velratio - velratio*speeds[currentGear-1]/speeds[currentGear])
		if currentGear == 1 then
			offGearIncrement = (0 + neutralRevs)
		end
	else
		offGearIncrement = 0
	end
end
addCommandHandler ( "shiftup", shiftUp )

function shiftDown(commandName)
	if not enable or not enableForVehicle then return end
	if getLocalPlayer() ~= getVehicleOccupant(getPedOccupiedVehicle(getLocalPlayer()), 0) then return
	end
	if currentGear == 0 then return
	end
	currentGear = math.max(currentGear-1,0)
	changeGear ( "changegear", currentGear )
	offGear = true
	if (velratio > 0.1) then
		offGearIncrement = (velratio - velratio*speeds[currentGear+1]/speeds[currentGear])
	else
		offGearIncrement = 0
	end
	offGearCounter = 1
end
addCommandHandler ( "shiftdown", shiftDown )

function getCarVelocity(car)
	local speedx, speedy, speedz = getElementVelocity ( car )
	local actualspeed = ((speedx^2 + speedy^2 + speedz^2)^(0.5))*180
	return actualspeed
end
	

function startEngineSound (player, seat)
	if not enable then return
	end
	if player ~= getLocalPlayer() then return
	end
	currentVehicle = getPedOccupiedVehicle(player)
	if not currentVehicle then return
	end
	
	vehicleId = getVehicleModelFromName(getVehicleName(currentVehicle))
	vehicleType, soundName, revLimit, soundBase, soundVolume, numberGears, hasTurbo, hasBackfire, turboBoostFactor, exhaustNumber, speeds, accelerations, inertias = getHandlingValues(xmlRoot,vehicleId)
	--outputChatBox(soundName)
	if vehicleType ~= "car" and vehicleType ~= "bike" and vehicleType ~= "boat" and vehicleType ~= "quad" and vehicleType ~= "mtruck" then
		enableForVehicle = false
		return
	else
		enableForVehicle = true
	end
	starterSound = playSound("starter.ogg",false,false)
	setSoundVolume(starterSound, 0.3)
	currentGear=1
	changeGear ( "changegear", currentGear )
	engineSound = playSound(soundName, true, false)
	setSoundVolume(engineSound, 0.1)
	
	turboSound = playSound("turboSpool.wav", true, false)
	setSoundVolume(turboSound, 0.0)
	
	vel = getCarVelocity(currentVehicle)
	velratio = vel/(speeds[currentGear])
	velratio = math.max(velratio,0.1)
	soundspeed = velratio*8
	offGear = false
	offGearCounter = 0
	setSoundSpeed (engineSound, soundspeed)
	--outputChatBox("started")
end
--addEventHandler("onClientVehicleEnter",  getRootElement(), startEngineSound)

function endEngineSound (player, seat)
	if player ~= getLocalPlayer() then return
	end
	if engineSound then
		stopSound(engineSound)
		stopSound(turboSound)
	end
	currentVehicle = false
	engineSound = false
	vehicleId = false
	offGear = false
	offGearCounter = 0
	toggleControl ( "accelerate", true )
	--outputChatBox("stopped")
end
--addEventHandler("onClientVehicleExit",  root, endEngineSound)
--addEventHandler("onClientVehicleExplode",  root, endEngineSound)


g_player = getLocalPlayer()
g_root = getRootElement()
function makeRevsGui( )
	local sx,sy = guiGetScreenSize()
	local wx = 350
	local wy = 50
	gearLabel = guiCreateLabel(((sx-wx)/2),(sy-wy),wx,wy,"",false)
end

function updateStuff(delta)
	delta = delta/1000
	--outputChatBox(tostring(delta))
	checkVehicleChanges()
	
	local shouldUpdateNonPlayer = false
	counterNonPlayerUpdate = counterNonPlayerUpdate-delta
	if counterNonPlayerUpdate < 0 then
		shouldUpdateNonPlayer = true
		counterNonPlayerUpdate = counterNonPlayerUpdateInterval
	end
	if shouldUpdateNonPlayer then
		updateLists()
		updateSounds()
	end
	
	if not enable or not enableForVehicle then return end
	--local g_vehicle = getPedOccupiedVehicle(g_player)
	if currentVehicle then
		
		currentAccelerateState = getAnalogControlState("accelerate")
		currentBrakeState = getAnalogControlState("brake_reverse")
		
		
		
		if g_player ~= getVehicleOccupant(currentVehicle, 0) then
			currentAccelerateState = 0
			currentBrakeState = 0
			currentGear = getElementData(currentVehicle,"upmCurrentGear")
			if not currentGear then currentGear = 1 end
		end
		
		-- ackx, acky, ackz = getVehicleComponentRotation(currentVehicle, "wheel_rb_dummy")
		-- outputChatBox(tostring(math.floor(ackx+0.5)))
		
		vel = getCarVelocity(currentVehicle)
		velratio = math.min(vel/(speeds[currentGear]),1.05)
		velratio = math.max(velratio,0.1)
		
		if offGear == true then
			--outputChatBox(tostring(offGearCounter))
			offGearCounter = offGearCounter - offGearTime*delta
			if currentGear ~= 1 then toggleControl ( "accelerate", false ) end
			if offGearCounter <= 0 then
				offGearCounter = 0
				offGear = false
				toggleControl ( "accelerate", true )
			end
			if currentGear ~= 0 then currentAccelerateState = offGearCounter end
			velratio = math.min(velratio + offGearIncrement*offGearCounter, 1.0)
			--outputChatBox(tostring(offGearIncrement) .. " " .. tostring(offGearIncrement*delta))
		end
		
		if offGear == false then checkBestGear(velratio, currentGear, vel) end
		
		local fex,fey,fez = getMatrixForward(getElementMatrix(currentVehicle))
		local vvx, vvy, vvz = getElementVelocity(currentVehicle)
		local movcos
		if vel == 0 then
			movcos = 0
		else
			movcos = (vvx*fex + vvy*fey + vvz*fez)/(vvx^2 + vvy^2 + vvz^2)^(0.5)
		end
		local seemsToDrift = (movcos > 0) and (movcos < 0.92) and (vel > 20)
		--outputChatBox(tostring(seemsToDrift))
		--outputChatBox(tostring(movcos))
		
		if currentAccelerateState > velratio*0.7 then
			if (currentGear ~= 0) and (seemsToDrift or (not isVehicleOnGround(currentVehicle) and vehicleType ~= "mtruck")) then
				neutralRevs = math.min(neutralRevs + currentAccelerateState*1.8*delta/(math.sqrt(currentGear+1)), 1.0) --0.03
				velratio = math.max(neutralRevs,0.1)
			elseif currentGear == 0 then
				if currentAccelerateState > neutralRevs*0.5 then
					neutralRevs = math.min(neutralRevs + currentAccelerateState*1.8*delta/(math.sqrt(currentGear+1)), 1.0) --0.03
					velratio = math.max(neutralRevs,0.1)
				else
					neutralRevs = math.max(0.1,neutralRevs-(0.5-currentAccelerateState)*0.6*delta) --0.01
					velratio = math.max(neutralRevs,0.1)
				end
			else
				neutralRevs=velratio
			end
			spool = math.min(1.0,spool + math.max(0,(velratio-spoolBegin)*2.4*delta*math.sqrt(currentAccelerateState))) --0.04
			if velratio < spoolBegin then spool = 0 end
		else
			if previousAccelerateState > 0.0 then
				if hasTurbo == 1 then
					blowOffSound = playSound("BlowOff1.wav", false, false)
					setSoundVolume(blowOffSound, spool*0.7)
				end
				if hasBackfire == 1 and spool > 0.6 then
					local ex,ey,ez = getVehicleModelExhaustFumesPosition(getElementModel(currentVehicle))
					local oex,oey,oez = getPositionFromElementOffset(currentVehicle, ex,ey,ez)
					local oex2,oey2,oez2 = 0,0,0
					fxAddTankFire(oex, oey, oez, -fex, -fey, -fez)
					if exhaustNumber == 2 then
						oex2,oey2,oez2 = getPositionFromElementOffset(currentVehicle, -ex,ey,ez)
						fxAddTankFire(oex2, oey2, oez2, -fex, -fey, -fez)
					end
					oexs,oeys,oezs = getPositionFromElementOffset(currentVehicle, 0,ey,ez)
					backfireSound = playSound3D("backfire.wav", oexs,oeys,oezs, false, false)
					setSoundVolume(backfireSound, 40)
					setSoundMaxDistance(backfireSound, 50)
					setSoundMinDistance(backfireSound, 10)
					
					triggerServerEvent("onClientBackfire",resourceRoot,getLocalPlayer(),currentVehicle,exhaustNumber,oex,oey,oez,-fex,-fey,-fez,oexs,oeys,oezs,oex2, oey2, oez2)
				end
			end
			if currentGear == 0 or (not isVehicleOnGround(currentVehicle) and vehicleType ~= "mtruck") then
				neutralRevs = math.max(0.1,neutralRevs-0.6*delta) --0.01
				velratio = math.max(neutralRevs,0.1)
			else
				neutralRevs = velratio
			end
			spool = 0.0
		end
		if velratio >= 0.98 then
			limiterCounter = limiterCounter+9*delta --0.15
			if limiterCounter >= 1 then limiterCounter = limiterCounter - 1 end
			local limiterSin = math.sin(limiterCounter*math.pi*2)
			velratio = velratio + 0.02*limiterSin
			if currentGear == 0 and hasBackfire == 1 and hasTurbo == 1 and spool >= 0.9 and limiterSin < -0.935 then
				local ex,ey,ez = getVehicleModelExhaustFumesPosition(getElementModel(currentVehicle))
				local oex,oey,oez = getPositionFromElementOffset(currentVehicle, ex,ey,ez)
				fxAddTankFire(oex, oey, oez, -fex, -fey, -fez)
				if exhaustNumber == 2 then
					oex,oey,oez = getPositionFromElementOffset(currentVehicle, -ex,ey,ez)
					fxAddTankFire(oex, oey, oez, -fex, -fey, -fez)
				end
				oex,oey,oez = getPositionFromElementOffset(currentVehicle, 0,ey,ez)
				backfireSound = playSound3D("backfire.wav", oex,oey,oez, false, false)
				setSoundVolume(backfireSound, 40)
				setSoundMaxDistance(backfireSound, 50)
				setSoundMinDistance(backfireSound, 10)
			end
		end
		
		if shouldUpdateNonPlayer then
			setElementData(currentVehicle,"gearsSoundRatio",velratio)
		end
		previousAccelerateState = currentAccelerateState
		soundspeed = velratio*revLimit
		if engineSound then
			setSoundSpeed (engineSound, soundspeed/soundBase) -- test
			
			setSoundVolume(engineSound, soundVolume+math.sqrt(currentAccelerateState)*soundVolume)
			
			-- if checkTunnel(currentVehicle) then
				-- if not echoOn then
					-- setSoundEffectEnabled(engineSound,"reverb",true)
					-- echoOn = true
					-- outputChatBox("ceil")
				-- end
				-- setSoundVolume(engineSound, soundVolume+2*math.sqrt(currentAccelerateState)*soundVolume)
			-- else
				-- if echoOn then
					-- setSoundEffectEnabled(engineSound,"reverb",false)
					-- echoOn = false
					-- outputChatBox("no ceil")
				-- end
			-- end
			
			--setSoundVolume(turboSound, (velratio-0.6)*4)
			if hasTurbo == 1 then
				setSoundVolume(turboSound, spool*0.4)
			else
				setSoundVolume(turboSound, 0)
			end
		end
		--guiSetText(gearLabel,currentGear .. "  "..tostring(math.floor(soundspeed)) .. " rpm   " .. tostring(vel) .. " km/h" .. "   spool: " .. tostring(spool) .. "   acs: " .. tostring(getAnalogControlState("accelerate")))
		
		spoolUpdateCounter = spoolUpdateCounter + spoolUpdateFrequency*delta
		if hasTurbo == 1 and (g_player == getVehicleOccupant(currentVehicle, 0)) and (spoolUpdateCounter > spoolUpdateFrequency) then
			local newAcceleration = accelerations[currentGear]*(turboBoostFactor*spool+1)
			--local newInertia = inertias[currentGear]/(turboBoostFactor*spool+1)
			triggerServerEvent("onSpoolChange",resourceRoot,currentVehicle,spool,newAcceleration) --newInertia
			spoolUpdateCounter = spoolUpdateCounter-spoolUpdateFrequency
			--outputChatBox(tostring(hasTurbo) .. " spool " .. tostring(newAcceleration) .. " " .. tostring(newInertia))
		end
		
		local sx,sy = guiGetScreenSize()
		local barwidth = 40
		local barmaxheight = 100
		local barXoffset = 400
		local barYoffset = 50
		local barbgcolor = tocolor(0,0,0,100)
		local baracceleratecolor = tocolor(0,100,250,100)
		local barbrakecolor = tocolor(250,0,0,100)
		
		dxDrawRectangle(sx-barXoffset-barwidth-2,sy-barYoffset-barmaxheight-2,barwidth+4,barmaxheight+4,barbgcolor)
		dxDrawRectangle(sx-barXoffset-barwidth-10-barwidth-2,sy-barYoffset-barmaxheight-2,barwidth+4,barmaxheight+4,barbgcolor)
		
		dxDrawRectangle(sx-barXoffset-barwidth,sy-barYoffset-currentAccelerateState*barmaxheight,barwidth,currentAccelerateState*barmaxheight,baracceleratecolor)
		dxDrawRectangle(sx-barXoffset-barwidth-10-barwidth,sy-barYoffset-currentBrakeState*barmaxheight,barwidth,currentBrakeState*barmaxheight,barbrakecolor)
		
		local revRange = revLimit/absoluteMaxRev
		local tachoDiameter = 256
		local tachoCenterX = sx-tachoDiameter/2-50
		local tachoCenterY = sy-barYoffset-tachoDiameter/2
		local circleBG = tocolor(200,200,200,200)
		local needleInnerRadius = 20
		local needleOuterRadius = 100
		local needleWidth = 4
		local needleStartAngle = 225
		local needleEndAngle = -45
		local needleAmplitude = needleEndAngle-needleStartAngle
		local needleBG = tocolor(255,0,0,200)
		
		local redlinefullW=256
		local redlinefullH=88
		local redlinefullResize=0.45
		local redlinehalfW=256
		local redlinehalfH=44
		local redlinehalfResize=0.45
		local redlinefullBG = tocolor(255,0,0,100)
		local redlinehalfBG = tocolor(255,0,0,100)
		local redlineStartAngle = 225
		local redlineAngle = 0
		
		local labelRadius = 85
		local labelBG = tocolor(0,0,0,200)
		local labelFont = "default"
		local labelSize = 1.25
		
		local blipInnerRadius = 100
		local blipOuterRadius = 115
		local blipHalfInnerRadius = 103
		local blipHalfOuterRadius = 112
		local blipStartAngle = 225
		local blipWidth = 2
		local blipAngle = 0
		local blipBG = tocolor(0,0,0,200)
		
		dxDrawImage(sx-tachoDiameter-50,sy-barYoffset-tachoDiameter,tachoDiameter,tachoDiameter,"speedobg.png",0,0,0,circleBG)
		
		--dxDrawImage(tachoCenterX,tachoCenterY,redlinehalfW*redlinehalfResize,redlinehalfH*redlinehalfResize,"redlinehalf.png",0,-redlinehalfW*redlinehalfResize*0.5,-redlinehalfH*redlinehalfResize*0.5,redlinehalfBG)
		
		--dxDrawImage(tachoCenterX,tachoCenterY,redlinefullW*redlinefullResize,redlinefullH*redlinefullResize,"redlinefull.png",-20,-redlinefullW*redlinefullResize*0.5,-redlinefullH*redlinefullResize*0.5,redlinefullBG)
		
		for i=0,math.ceil(absoluteMaxRev/1000),1 do
			local labelAngle = needleStartAngle - i*anglePerThousand
			local labelY = tachoCenterY + -labelRadius*math.sin(math.rad(labelAngle))
			local labelX = tachoCenterX + labelRadius*math.cos(math.rad(labelAngle))
			dxDrawText(tostring(i),labelX,labelY,labelX,labelY,labelBG,labelSize,labelFont,"center","center",false,false)
		end
		
		for i=0,math.ceil(absoluteMaxRev/1000-1),0.5 do
			redlineAngle = redlineStartAngle - i*anglePerThousand
			if i>= math.floor(revLimit/1000)-0.5 then
				dxDrawImage(tachoCenterX,tachoCenterY,redlinefullW*redlinefullResize,redlinefullH*redlinefullResize,"redlinefull.png",-redlineAngle,-redlinefullW*redlinefullResize*0.5,-redlinefullH*redlinefullResize*0.5,redlinefullBG)
			end
		end
		redlineAngle = redlineStartAngle - 13.5*anglePerThousand
		dxDrawImage(tachoCenterX,tachoCenterY,redlinehalfW*redlinehalfResize,redlinehalfH*redlinehalfResize,"redlinehalf.png",-redlineAngle,-redlinehalfW*redlinehalfResize*0.5,-redlinehalfH*redlinehalfResize*0.5,redlinehalfBG)
		
		for i=0,math.ceil(absoluteMaxRev/1000),0.5 do
			blipAngle = math.rad(blipStartAngle - i*anglePerThousand)
			if i%1==0 then
				dxDrawLine(tachoCenterX+blipInnerRadius*math.cos(blipAngle),tachoCenterY-blipInnerRadius*math.sin(blipAngle),tachoCenterX+blipOuterRadius*math.cos(blipAngle),tachoCenterY-blipOuterRadius*math.sin(blipAngle),blipBG,blipWidth)
			else
				dxDrawLine(tachoCenterX+blipHalfInnerRadius*math.cos(blipAngle),tachoCenterY-blipHalfInnerRadius*math.sin(blipAngle),tachoCenterX+blipHalfOuterRadius*math.cos(blipAngle),tachoCenterY-blipHalfOuterRadius*math.sin(blipAngle),blipBG,blipWidth)
			end
		end
		
		local gearToShow = tostring(currentGear)
		if (currentGear == 0) then gearToShow = "N" end
		dxDrawText(gearToShow,tachoCenterX,tachoCenterY,tachoCenterX,tachoCenterY,labelBG,labelSize*2,labelFont,"center","center",false,false)
		
		local tachoAngle = (needleStartAngle+velratio*revRange*needleAmplitude)*math.pi/180
		dxDrawLine(tachoCenterX+needleInnerRadius*math.cos(tachoAngle),tachoCenterY-needleInnerRadius*math.sin(tachoAngle),tachoCenterX+needleOuterRadius*math.cos(tachoAngle),tachoCenterY-needleOuterRadius*math.sin(tachoAngle),needleBG,needleWidth)
		
		-- TURBO BAROMETER
		
		local baroDiameter = 100
		local baroCenterX = sx-baroDiameter/2-tachoDiameter-30
		local baroCenterY = sy-barYoffset-baroDiameter/4
		local baroNeedleInnerRadius = 10
		local baroNeedleOuterRadius = 50
		local baroNeedleWidth = 3
		local baroNeedleStartAngle = 90
		local baroNeedleEndAngle = 60
		local baroNeedleAmplitude = baroNeedleEndAngle-baroNeedleStartAngle
		local baroNeedleBG = tocolor(255,0,0,200)
		local baroLabelRadius = 85
		local baroLabelBG = tocolor(0,0,0,200)
		local baroLabelFont = "default"
		local baroLabelSize = 1.25
		local baroBlipInnerRadius = 50
		local baroBlipOuterRadius = 60
		local baroBlipHalfInnerRadius = 52
		local baroBlipHalfOuterRadius = 58
		local baroBlipStartAngle = 90
		local baroBlipWidth = 2
		local baroBlipAngle = 0
		local baroBlipBG = tocolor(0,0,0,200)
		local baroLabelInnerRadius = 45
		
		if hasTurbo == 1 then
			dxDrawImage(sx-baroDiameter-tachoDiameter-30,sy-barYoffset-baroDiameter,baroDiameter,baroDiameter,"barobg.png",0,0,0,circleBG)
			local baroAngle = (baroNeedleStartAngle+spool*baroNeedleAmplitude)*math.pi/180
			for i=-1,1,0.5 do
				baroBlipAngle = math.rad(baroBlipStartAngle - i*baroNeedleAmplitude)
				if i%1==0 then
					dxDrawLine(baroCenterX+baroBlipInnerRadius*math.cos(baroBlipAngle),baroCenterY-baroBlipInnerRadius*math.sin(baroBlipAngle),baroCenterX+baroBlipOuterRadius*math.cos(baroBlipAngle),baroCenterY-baroBlipOuterRadius*math.sin(baroBlipAngle),baroBlipBG,baroBlipWidth)
				else
					dxDrawLine(baroCenterX+baroBlipHalfInnerRadius*math.cos(baroBlipAngle),baroCenterY-baroBlipHalfInnerRadius*math.sin(baroBlipAngle),baroCenterX+baroBlipHalfOuterRadius*math.cos(baroBlipAngle),baroCenterY-baroBlipHalfOuterRadius*math.sin(baroBlipAngle),baroBlipBG,baroBlipWidth)
				end
			end
			
			dxDrawText("-",baroCenterX+baroLabelInnerRadius*math.cos(baroBlipAngle),baroCenterY-baroLabelInnerRadius*math.sin(baroBlipAngle),baroCenterX+baroLabelInnerRadius*math.cos(baroBlipAngle),baroCenterY-baroLabelInnerRadius*math.sin(baroBlipAngle),labelBG,labelSize,labelFont,"center","center",false,false)
			dxDrawText("+",baroCenterX-baroLabelInnerRadius*math.cos(baroBlipAngle),baroCenterY-baroLabelInnerRadius*math.sin(baroBlipAngle),baroCenterX-baroLabelInnerRadius*math.cos(baroBlipAngle),baroCenterY-baroLabelInnerRadius*math.sin(baroBlipAngle),labelBG,labelSize,labelFont,"center","center",false,false)
			dxDrawLine(baroCenterX+needleInnerRadius*math.cos(baroAngle),baroCenterY-needleInnerRadius*math.sin(baroAngle),baroCenterX+baroNeedleOuterRadius*math.cos(baroAngle),baroCenterY-baroNeedleOuterRadius*math.sin(baroAngle),needleBG,baroNeedleWidth)
		end
	else
		
		--guiSetText(gearLabel,"")
	end
end
makeRevsGui()
addEventHandler("onClientPreRender", root, updateStuff)

function checkVehicleChanges()
	if currentVehicle and not getPedOccupiedVehicle(getLocalPlayer()) then
		setElementData(currentVehicle,"gearsSoundRatio",0.1)
		currentVehicle = false
		--outputChatBox("cv and not get")
	end
	if not currentVehicle and getPedOccupiedVehicle(getLocalPlayer()) then
		currentVehicle = getPedOccupiedVehicle(getLocalPlayer())
		--outputChatBox("not cv and get")
	end
	--outputChatBox("check")
	--outputChatBox(tostring(currentVehicle) .. " " .. tostring(engineSound))
	if not currentVehicle and engineSound then
		endEngineSound(getLocalPlayer(),0)
		--outputChatBox("didnt detect destroy")
		--outputChatBox(tostring(engineSound))
		
	end
	if currentVehicle and not engineSound then
		startEngineSound(getLocalPlayer(),getPedOccupiedVehicleSeat(getLocalPlayer()))
		--outputChatBox("didnt detect create")
	end
	--outputChatBox(tostring(engineSound) .. " " .. tostring(currentVehicle) .. " " .. tostring(getPedOccupiedVehicle(getLocalPlayer())))
	--outputChatBox(tostring(vehicleId).. " " .. tostring(getVehicleModelFromName(getVehicleName(currentVehicle))) .. " " .. tostring(getVehicleModelFromName(getVehicleName(getPedOccupiedVehicle(getLocalPlayer())))))
	if currentVehicle and getPedOccupiedVehicle(getLocalPlayer()) and vehicleId ~= getVehicleModelFromName(getVehicleName(getPedOccupiedVehicle(getLocalPlayer()))) then
		endEngineSound(getLocalPlayer(),0)
		currentVehicle = getPedOccupiedVehicle(getLocalPlayer())
		startEngineSound(getLocalPlayer(),getPedOccupiedVehicleSeat(getLocalPlayer()))
		--outputChatBox("didnt detect change")
		
	end
	--outputChatBox(tostring(not nil))
end

function checkBestGear(currVR, currG, currV)
	if not autogearbox then return end
	-- if (currG < numberGears) and (currVR > 0.9) then
		-- shiftUp("shiftup");
	-- elseif (currG > 1) and (currV < 0.8*speeds[currG - 1]) then
		-- shiftDown("shiftdown");
	-- end
	auxg, auxbool = checkBestGearUp(currG, currV)
	--outputChatBox("main: " .. tostring(auxg) .. " " .. tostring(auxbool))
	if (auxbool == true) and (auxg ~= currG) then
		--outputChatBox("change" .. tostring(auxg))
		currentGear = math.min(auxg,numberGears)
		offGear = true
		offGearCounter = 1
		if (velratio > 0.1 and currentGear >= 1) then
			offGearIncrement = (velratio - velratio*speeds[currentGear-1]/speeds[currentGear])
		else
			offGearIncrement = 0
		end
		changeGear ( "changegear", currentGear )
		return
	end
	auxg, auxbool = checkBestGearDown(currG, currV)
	--outputChatBox("main: " .. tostring(auxg) .. " " .. tostring(auxbool))
	if (auxbool == true) and (auxg ~= currG) then
		--outputChatBox("change" .. tostring(auxg))
		currentGear = math.max(auxg,0)
		offGear = true
		offGearCounter = 1
		if (velratio > 0.1) then
			offGearIncrement = (velratio - velratio*speeds[currentGear-1]/speeds[currentGear])
		else
			offGearIncrement = 0
		end
		changeGear ( "changegear", currentGear )
		return
	end
	return
end

function checkBestGearUp(geartest, veltest)
	if (geartest <= numberGears) then
	--outputChatBox("first: " ..tostring(geartest) .. " " .. tostring(veltest/speeds[geartest]))
		if (veltest/speeds[geartest] > 0.9) then
			auxg, auxbool = checkBestGearUp(geartest+1,veltest)
			--outputChatBox("second: " .. tostring(geartest) .. " " .. tostring(veltest/speeds[geartest]) .. " > 0.9 " .. tostring(auxg) .. " " .. tostring(auxbool))
			if not auxbool then
				return geartest, true
			else
				return auxg, true
			end
		else
			return geartest, true;
		end
	else
		return geartest, false;
	end
end

function checkBestGearDown(geartest, veltest)
	if (geartest > 0) then
	--outputChatBox("first: " ..tostring(geartest) .. " " .. tostring(veltest/speeds[geartest]))
		if (veltest < 0.4*speeds[geartest]) then
			auxg, auxbool = checkBestGearDown(geartest-1,veltest)
			--outputChatBox("second: " ..tostring(veltest) .. "kmh " .. tostring(geartest) .. " " .. tostring(veltest/speeds[geartest]) .. " > 0.9 " .. tostring(auxg) .. " " .. tostring(auxbool))
			if not auxbool then
				return geartest, true
			else
				return auxg, true
			end
		else
			return geartest, true;
		end
	else
		return geartest, false;
	end
end

function startThingsUp(rsc)
	if rsc ~= getThisResource() then return
	end
	
	xmlRoot = xmlLoadFile("vehicles.xml")
	createIdIndex()
	checkControls()
	loadAll(xmlRoot,IdIndex,allNodes)
	
	loadSettings();
	--outputChatBox("startup: " ..tostring(enable) .. " " .. tostring(autogearbox))
	if enable then gearsOn() else gearsOff() end
	if autogearbox then gearsAuto() else gearsManual() end
	
	--toggleGtaSounds(enable)
	--startEngineSound(getLocalPlayer(),0)
	
end
addEventHandler("onClientResourceStart",getRootElement(),startThingsUp)

function addBackfireFromOthers(fireNumber, x1, y1, z1, dx1, dy1, dz1, s1, s2, s3, x2, y2, z2)
	--outputChatBox(tostring(fireNumber))
	--local ex,ey,ez = getVehicleModelExhaustFumesPosition(getElementModel(currentVehicle))
	--local oex,oey,oez = getPositionFromElementOffset(currentVehicle, ex,ey,ez)
	--local oex2,oey2,oez2 = 0,0,0
	fxAddTankFire(x1, y1, z1, dx1, dy1, dz1)
	if fireNumber == 2 then
		--oex2,oey2,oez2 = getPositionFromElementOffset(currentVehicle, -ex,ey,ez)
		fxAddTankFire(x2, y2, z2, dx1, dy1, dz1)
	end
	--oexs,oeys,oezs = getPositionFromElementOffset(currentVehicle, 0,ey,ez)
	local tempBackfireSound = playSound3D("backfire.wav", s1, s2, s3, false, false)
	setSoundVolume(tempBackfireSound, 20)
	setSoundMaxDistance(tempBackfireSound, 50)
	setSoundMinDistance(tempBackfireSound, 10)
	
end
addEvent("onServerBackfireSpread", true)
addEventHandler("onServerBackfireSpread",resourceRoot,addBackfireFromOthers)

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function getMatrixForward(m)
    return m[2][1], m[2][2], m[2][3]
end

function checkTunnel(vehToCheck)
	local vtcX, vtcY, vtcZ = getElementPosition(vehToCheck)
	--																			 build vehs   peds   objs   dumms  seeth  ignore
	local hitCeiling = isLineOfSightClear(vtcX, vtcY, vtcZ+1, vtcX, vtcY, vtcZ+10, true, false, false, false, false, false, false)
	return not hitCeiling
end
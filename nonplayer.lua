listCurrent = {} --being rendered
listAdd = {} --frame-current
listRemove = {} --current-frame
listFrame = {} --from the current frame

listSounds = {} --vehicle->sound

function doRemove()
	for i,v in ipairs(listRemove) do
		--outputChatBox("remove")
		local soundToStop = listSounds[v]
		detachElements(soundToStop)
		stopSound(soundToStop)
		listSounds[v] = nil
	end
	
end

function doAdd()
	--outputChatBox("add")
	for i,v in ipairs(listAdd) do
		--outputChatBox("addveh")
		local whichModel = getElementModel(v)
		local whereToPlayX,whereToPlayY,whereToPlayZ = getElementPosition(v)
		local whichFile = allNodes[whichModel]["soundName"]
		local newSound = playSound3D(whichFile, whereToPlayX,whereToPlayY,whereToPlayZ, true) --last argument is to loop sound
		setSoundMaxDistance(newSound,50)
		setSoundMinDistance(newSound,15)
		setSoundVolume(newSound,1.5*allNodes[whichModel]["soundVolume"])
		attachElements(newSound,v)
		listSounds[v] = newSound
	end
	
end

function addAndRemoveFromCurrent()
	for i,v in ipairs(listRemove) do
		local indexToRemove = indexOf(listCurrent,v)
		table.remove(listCurrent,indexToRemove)
	end
	for i,v in ipairs(listAdd) do
		table.insert(listCurrent,v)
	end
end

function updateLists()
	--outputChatBox("updateLists")
	local playerX,playerY,playerZ = getElementPosition(getLocalPlayer())
	--outputChatBox(tostring(playerX) .. " " .. tostring(playerY) .. " " .. tostring(playerZ))
	--local colSphere = createColSphere(playerX,playerY,playerZ,50)
	listAdd = {}
	listRemove = {}
	--listFrame = getElementsWithinColShape(colSphere,"vehicle")
	listFrame = getElementsByType("vehicle",getRootElement(),true)
	for k,v in pairs(listFrame) do
		local vtype = getVehicleType(v)
		local vehx,vehy,vehz = getElementPosition(v)
		if v == getPedOccupiedVehicle(getLocalPlayer()) then
			listFrame[k] = nil
		elseif getVehicleEngineState(v) == false then
			listFrame[k] = nil
		elseif getDistanceBetweenPoints3D(playerX,playerY,playerZ, vehx,vehy,vehz) >= 50 then
			listFrame[k] = nil
		elseif (vtype ~= "Automobile") and (vtype ~= "Bike") and (vtype ~= "Boat") and (vtype ~= "Quad") and (vtype ~= "Monster Truck") then
			--outputChatBox(vtype)
			listFrame[k] = nil
		end 
	end
	--setsDifference(a, b) = what is in A that is not in B
	listAdd = setsDifference(listFrame,listCurrent)
	listRemove = setsDifference(listCurrent,listFrame)
	doAdd()
	doRemove()
	addAndRemoveFromCurrent()
end

function updateSounds()
	--outputChatBox("updateSounds")
	for k,v in pairs(listSounds) do
		--outputChatBox("sound")
		local whichModel = getElementModel(k)
		local vehicleRPMs = getElementData(k,"gearsSoundRatio")
		if not vehicleRPMs then vehicleRPMs = 0.1 end
		local speedToChangeTo = vehicleRPMs*(allNodes[whichModel]["revLimit"])/(allNodes[whichModel]["soundBase"])
		setSoundSpeed(v,speedToChangeTo)
	end
end


indexOf = function( thelist, object )
	local result = false

	for i=1,#thelist do
		if object == thelist[i] then
			result = i
			break
		end
	end
	return result
	
end
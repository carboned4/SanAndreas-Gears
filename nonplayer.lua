listCurrent = {} --being rendered
listAdd = {} --frame-current
listRemove = {} --current-frame
listFrame = {} --from the current frame

listSounds = {} --vehicle->sound

function doRemove()
	for i,v in ipairs(listRemove) do
		local soundToStop = listSounds[v]
		detachElements(soundToStop)
		stopSound(soundToStop)
		listSounds[v] = nil
	end
	
end

function doAdd()
	for i,v in ipairs(listAdd) do
		local whichModel = getElementModel(v)
		local whereToPlayX,whereToPlayY,whereToPlayZ = getElementPosition(v)
		local whichFile = 
		local newSound = playSound(whichFile, whereToPlayX,whereToPlayY,whereToPlayZ, true) --last argument is to loop sound
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
	local playerX,playerY,playerZ = getElementPosition(getLocalPlayer())
	local colSphere = createColSphere(playerX,playerY,playerZ,50)
	listAdd = {}
	listRemove = {}
	listFrame = getElementsWithinColShape(colSphere,"vehicle")
	for k,v in ipairs(listFrame) do
		if v = getPedOccupiedVehicle(getLocalPlayer()) then
			listFrame[k] = nil
		end
		if getVehicleEngineState(v) == false then
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
	for k,v in pairs(listSounds) do
		local whichModel = getElementModel(v)
		local vehicleRPMs = getElementData(k,"gearsSoundRatio")
		local
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
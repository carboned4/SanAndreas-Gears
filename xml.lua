function getHandlingValues(xmlnode,vehicleid)
	local vehicleNode = xmlFindChild(xmlnode,"vehicle",IdIndex[vehicleid]-1)
	if not vehicleNode then
		outputChatBox("no node")
		return false
	end
	local vehicleNodeCheckId = tonumber(xmlNodeGetAttribute(vehicleNode,"id"))
	if vehicleNodeCheckId ~= vehicleid then
		outputChatBox("mismatch between " .. tostring(vehicleNodeCheckId) .. " and " .. tostring(vehicleid))
	end
	
	local NvehicleType = xmlNodeGetAttribute(vehicleNode,"type")
	--if NvehicleType ~= "car" then return false end
	--Continue
	local NsoundName = xmlNodeGetAttribute(vehicleNode,"soundname")
	local NrevLimit =  tonumber(xmlNodeGetAttribute(vehicleNode,"revlimit"))
	local NsoundBase = tonumber(xmlNodeGetAttribute(vehicleNode,"soundbase"))
	local NsoundVolume = tonumber(xmlNodeGetAttribute(vehicleNode,"soundvolume"))
	local NnumberGears = tonumber(xmlNodeGetAttribute(vehicleNode,"numbergears"))
	local NhasTurbo = tonumber(xmlNodeGetAttribute(vehicleNode,"hasturbo"))
	local NhasBackfire = tonumber(xmlNodeGetAttribute(vehicleNode,"hasbackfire"))
	local NturboBoostFactor = tonumber(xmlNodeGetAttribute(vehicleNode,"turboboostfactor"))
	local NexhaustNumber = tonumber(xmlNodeGetAttribute(vehicleNode,"exhaustnumber"))
	local NturboLevel = tonumber(xmlNodeGetAttribute(vehicleNode,"turbolevel"))
	--outputChatBox(NsoundName)
	
	local speedNodes = xmlNodeGetChildren(xmlFindChild(vehicleNode,"speeds",0))
	local Nspeeds = {}
	-- outputChatBox(tostring(table.getn(speedNodes)) .. " speeds")
	for k,sn in pairs(speedNodes) do
		Nspeeds[tonumber(xmlNodeGetAttribute(sn,"gear"))] = tonumber(xmlNodeGetAttribute(sn,"value"))
		--outputChatBox(xmlNodeGetAttribute(sn,"gear") .. " gear : speed " .. xmlNodeGetAttribute(sn,"value"))
	end
	
	local accelerationNodes = xmlNodeGetChildren(xmlFindChild(vehicleNode,"accelerations",0))
	local Naccelerations = {}
	-- outputChatBox(tostring(table.getn(accelerationNodes)) .. " accelerations")
	for k,sn in pairs(accelerationNodes) do
		Naccelerations[tonumber(xmlNodeGetAttribute(sn,"gear"))] = tonumber(xmlNodeGetAttribute(sn,"value"))
		--outputChatBox(xmlNodeGetAttribute(sn,"gear") .. " gear : acceleration " .. xmlNodeGetAttribute(sn,"value"))
	end
	
	local inertiaNodes = xmlNodeGetChildren(xmlFindChild(vehicleNode,"inertias",0))
	local Ninertias = {}
	-- outputChatBox(tostring(table.getn(inertiaNodes)) .. " inertias")
	for k,sn in pairs(inertiaNodes) do
		Ninertias[tonumber(xmlNodeGetAttribute(sn,"gear"))] = tonumber(xmlNodeGetAttribute(sn,"value"))
		--outputChatBox(xmlNodeGetAttribute(sn,"gear") .. " gear : inertia " .. xmlNodeGetAttribute(sn,"value"))
	end
	
	return NvehicleType, NsoundName, NrevLimit, NsoundBase, NsoundVolume, NnumberGears, NhasTurbo, NhasBackfire, NturboBoostFactor, NexhaustNumber, Nspeeds, Naccelerations, Ninertias, NturboLevel
end


function loadAll(xmlnode,idlist,destdict)
	for k,v in pairs(idlist) do
		local ivehicleType, isoundName, irevLimit, isoundBase, isoundVolume, inumberGears, ihasTurbo, ihasBackfire, iturboBoostFactor, iexhaustNumber, ispeeds, iaccelerations, iinertias = getHandlingValues(xmlnode,k)
		destdict[k] = {
			["vehicleType"] = ivehicleType,
			["soundName"] = isoundName,
			["revLimit"] = irevLimit,
			["soundBase"] = isoundBase,
			["soundVolume"] = isoundVolume,
			["numberGears"] = inumberGears,
			["hasTurbo"] = ihasTurbo,
			["hasBackfire"] = ihasBackfire,
			["turboBoostFactor"] = iturboBoostFactor,
			["exhaustNumber"] = iexhaustNumber,
			["speeds"] = ispeeds,
			["accelerations"] = iaccelerations,
			["inertias"] = iinertias,
		}
		
	end
	return destdict
end
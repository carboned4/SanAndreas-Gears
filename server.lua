function gearChangeHandler ( vehicle, newnumbergear, newspeed, newaccel, newinertia )
	-- the predefined variable 'client' points to the player who triggered the event and should be used due to security issues   
	--outputChatBox ( "New gear: " .. newspeed)
	--local vehicle = getPedOccupiedVehicle(source)
	local driver = getVehicleOccupant ( vehicle)
	if vehicle then
		--outputChatBox ( "New gear: ")
	end
	setVehicleHandling(vehicle, "numberOfGears", 1)
	setVehicleHandling(vehicle, "maxVelocity", newspeed)
	setVehicleHandling(vehicle, "engineAcceleration", newaccel )
	setVehicleHandling(vehicle, "engineInertia", newinertia)
	setVehicleHandling(vehicle, "dragCoeff", 0.0)
	local hf = getVehicleHandling(vehicle)["handlingFlags"]
	hf = bitOr(hf, 0x1000000)
	setVehicleHandling(vehicle, "handlingFlags", hf)
	
	setElementData(vehicle,"upmCurrentGear",newnumbergear)
end
addEvent( "onGearChange", true )
addEventHandler( "onGearChange", resourceRoot, gearChangeHandler ) -- Bound to this resource only, saves on CPU usage.

function spoolChangeHandler ( vehicle, spool, newAcceleration) -- newInertia
	setVehicleHandling(vehicle, "engineAcceleration", newAcceleration )
	--setVehicleHandling(vehicle, "engineInertia", newInertia )
	setElementData(vehicle,"upmCurrentSpool",spool)
end
addEvent( "onSpoolChange", true )
addEventHandler( "onSpoolChange", resourceRoot, spoolChangeHandler )


function spreadBackfire(player,veh, fireNumber, x1, y1, z1, dx1, dy1, dz1, s1, s2, s3, x2, y2, z2)
	--outputChatBox("ai")
	local vx,vy,vz = getElementPosition(veh)
	local colsphere = createColSphere(vx,vy,vz,50)
	local tosend = getElementsWithinColShape(colsphere, "player")
	for i,v in ipairs(tosend) do
		if v ~= player then
			triggerClientEvent(v,"onServerBackfireSpread", resourceRoot, fireNumber, x1, y1, z1, dx1, dy1, dz1, s1, s2, s3, x2, y2, z2)
		else
			--outputChatBox("boom",v)
		end
	end
	
end
addEvent( "onClientBackfire", true )
addEventHandler( "onClientBackfire", resourceRoot, spreadBackfire)
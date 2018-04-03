function loadSettings()
	local saverootnode = xmlLoadFile("upmgearssettings.xml")
	if not saverootnode then
		--outputChatBox("load: no saverootnode")
		local newnode = xmlCreateFile("upmgearssettings.xml","settings")
		local newEnable = xmlCreateChild(newnode,"enablegears")
		local newAuto = xmlCreateChild(newnode,"enableauto")
		xmlNodeSetValue(newEnable,"true")
		xmlNodeSetValue(newAuto,"true")
		local savedBool = xmlSaveFile(newnode)
		----outputChatBox("saved: "..tostring(savedBool))
		xmlUnloadFile(newnode)
		
		enable = true
		autogearbox = true
		
	else
		--outputChatBox("load: found saverootnode")
		
		local enableNode = xmlFindChild(saverootnode,"enablegears",0)
		if not enableNode then
			--outputChatBox("load: no enableNode")
			enableNode = xmlCreateChild(saverootnode,"enablegears")
			xmlNodeSetValue(enableNode,"true")
		end
		local enableValue = xmlNodeGetValue(enableNode)
		if not enableValue then
			--outputChatBox("load: no enableValue")
			xmlNodeSetValue(enableNode,"true")
			enableValue = "true"
		end
		
		local autoNode = xmlFindChild(saverootnode,"enableauto",0)
		if not autoNode then
			--outputChatBox("load: no autoNode")
			autoNode = xmlCreateChild(saverootnode,"enableauto")
			xmlNodeSetValue(autoNode,"true")
		end
		local autoValue = xmlNodeGetValue(autoNode)
		if not autoValue then
			--outputChatBox("load: no autoValue")
			xmlNodeSetValue(autoNode,"true")
			autoValue = "true"
		end
		--outputChatBox("load: "..autoValue .. " " ..enableValue)
		
		if enableValue == "true" then enable = true else enable = false end
		if autoValue == "true" then autogearbox = true else autogearbox = false end
		
		xmlSaveFile(saverootnode)
		xmlUnloadFile(saverootnode)
		
	end
end

function saveSettings()
	local saverootnode = xmlLoadFile("upmgearssettings.xml")
	if not saverootnode then
		--outputChatBox("save: no root")
		local newnode = xmlCreateFile("upmgearssettings.xml","settings")
		local newEnable = xmlCreateChild(newnode,"enablegears")
		local newAuto = xmlCreateChild(newnode,"enableauto")
		local savedBool = xmlSaveFile(newnode)
		----outputChatBox("saved: "..tostring(savedBool))
		xmlUnloadFile(newnode)
		
		saverootnode = xmlLoadFile("upmgearssettings.xml")
	end
	--outputChatBox("save: " ..tostring(enable) .. " " .. tostring(autogearbox))
	
	local enableNode = xmlFindChild(saverootnode,"enablegears",0)
	if not enableNode then
		--outputChatBox("save: enablenode not found")
		enableNode = xmlCreateChild(newnode,"enablegears")
		xmlNodeSetValue(enableNode,tostring(enable))
		enableNode = xmlFindChild(saverootnode,"enablegears",0)
	end
	xmlNodeSetValue(enableNode,tostring(enable))
	
	local autoNode = xmlFindChild(saverootnode,"enableauto",0)
	if not autoNode then
		--outputChatBox("save: autonode not found")
		autoNode = xmlCreateChild(newnode,"enableauto")
		xmlNodeSetValue(autoNode,tostring(autogearbox))
		autoNode = xmlFindChild(saverootnode,"enableauto",0)
	end
	xmlNodeSetValue(autoNode,tostring(autogearbox))
	
	xmlSaveFile(saverootnode)
	xmlUnloadFile(saverootnode)
end
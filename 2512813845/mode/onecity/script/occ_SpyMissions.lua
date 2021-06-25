
--[[ =======================================================================

	OCC Spy Mission - Logic

	Receivers for custom player opperation events are defined here. They handle
	EXECUTE_SCRIPT  triggered in the replacement Espionage UI script.
-- =========================================================================]]

include("SupportFunctions");
-- ===========================================================================
--	Game Event
-- ===========================================================================
function OnCustomSpyMissionTriggered(ePlayer : number, params : table)
--[[ FORMAT
			kParameters.SpyID = m_spy:GetID();
			kParameters.SpyX =  m_spy:GetX();
			kParameters.SpyY =  m_spy:GetY();
			kParameters.OperationIndex = m_operation.Index;
			kParameters.OperationType = m_operation.OperationType;
			kParameters.OperationTurns = m_operation.Turns;
			kParameters.OperationChance = m_operation.BaseProbability;
			kParameters.LocalPlayer = Game.GetLocalPlayer();
			
--]]

	if params == nil then
		print("Missing Parameters")
		return
	end

	local spyID = params.SpyID
	local spyX = params.SpyX
	local spyY = params.SpyY
	local operation = {}
	operation.Index = params.OperationIndex
	operation.OperationType = params.OperationType
	operation.Turns = params.OperationTurns
	operation.BaseProbability = params.OperationChance
	operation.Index = params.OperationIndex
	local playerID = params.LocalPlayer

	print("Received",operation,spyID,spyX,spyY)
	MissionStarts(operation,spyID,spyX,spyY,playerID)

end


GameEvents.CustomSpyMissionTriggered.Add( OnCustomSpyMissionTriggered );

function OnCustomSpyEscapeTriggered(ePlayer : number, params : table)
--[[ FORMAT
		tParameters.SpyID = g_spy:GetID();
		tParameters.SpyX =  g_spy:GetX();
		tParameters.SpyY =  g_spy:GetY();
		tParameters.EscapeType =  4;
		tParameters.LocalPlayer = Game.GetLocalPlayer();		
--]]

	if params == nil then
		print("Missing Parameters")
		return
	end

	local spyID = params.SpyID
	local spyX = params.SpyX
	local spyY = params.SpyY
	local playerID = params.LocalPlayer
	local escape = params.EscapeType

	print("Received Escape",escape,spyID,spyX,spyY)
	EscapeStarts(escape,spyID,spyX,spyY,playerID)

end


GameEvents.CustomSpyEscapeTriggered.Add( OnCustomSpyEscapeTriggered );


function OnMissionProgress()

	local pAllPlayerIDs : table = PlayerManager.GetAliveIDs();	
	for _,iPlayerID in ipairs(pAllPlayerIDs) do
	
		local pPlayer : object = Players[iPlayerID];
		local playerUnits = pPlayer:GetUnits()
		for i, unit in playerUnits:Members() do
			if unit ~= nil then
				if unit:GetProperty("ON_A_MISSION") ~= nil then
					print("unit:GetProperty(ON_A_MISSION)",unit:GetProperty("ON_A_MISSION"))
					if unit:GetProperty("ON_A_MISSION") == 1 then
						print("unit:GetProperty(TIME_LEFT)",unit:GetProperty("TIME_LEFT"))
						local turnRemaining = unit:GetProperty("TIME_LEFT")
						if turnRemaining > 1 then
							turnRemaining = turnRemaining - 1
							unit:SetProperty("TIME_LEFT",turnRemaining)
							print(unit,turnRemaining)
							UnitManager.FinishMoves(unit);
							elseif turnRemaining == 1 then
							ExecuteMission(unit)
							unit:SetProperty("TIME_LEFT",-1)
							else
							print("Error: Need to Clean Unit Tags",unit:GetX(),unit:GetY())
						end
					end
				end
			end
		end
		
	end

end

GameEvents.OnGameTurnStarted.Add(OnMissionProgress);

-- ===========================================================================
--	Other Functions
-- ===========================================================================

function MissionStarts(operation:table,spyID:number,x,y,initiatorID:number)
	print("MissionStarts",operation.OperationType)

	-- Get the spy
	local pPlayer = Players[initiatorID]
	local playerUnits = pPlayer:GetUnits()
	local pSpy = playerUnits:FindID(spyID)
	
	-- Report 
	UnitManager.ReportActivation(pSpy, operation.OperationType);
	
	-- Expense the movement of the units
	UnitManager.FinishMoves(pSpy);
	
	-- Flag it
	pSpy:SetProperty("ON_A_MISSION",1)
	pSpy:SetProperty("OPERATION",operation.OperationType)
	pSpy:SetProperty("TIME_LEFT",operation.Turns)
	pSpy:SetProperty("BASE_PROBABILITY",operation.BaseProbability)
end

function EscapeStarts(escape:number,spyID:number,x,y,initiatorID:number)
	print("EscapeStarts",escape)

	-- Get the spy
	local pPlayer = Players[initiatorID]
	local playerUnits = pPlayer:GetUnits()
	local pSpy = playerUnits:FindID(spyID)
	
	-- Report 
	--UnitManager.ReportActivation(pSpy, operation.OperationType);
	
	-- Expense the movement of the units
	UnitManager.FinishMoves(pSpy);
	
	-- Flag it
	pSpy:SetProperty("ON_A_MISSION",1)
	pSpy:SetProperty("OPERATION","ESCAPE_"..escape)
	pSpy:SetProperty("TIME_LEFT",4)
	
end

function ExecuteMission(pUnit:table)
	print("ExecuteMission",pUnit:GetProperty("OPERATION"))
	local outcome:string = MissionOutcome(pUnit)
	local bescape = false
	if outcome == nil then
		print("ExecuteMission",pUnit:GetProperty("OPERATION"),"Error: No Valid Outcome")
		return
	end
	
	if (string.sub(string.lower(tostring(pUnit:GetProperty("OPERATION")),1,6)) == "escape") then
		bescape = true
	end
	outcome = "ESPIONAGE_SUCCESS_MUST_ESCAPE"
	-- Mission Effect is triggered
	if outcome == "ESPIONAGE_SUCCESS_UNDETECTED" or outcome == "ESPIONAGE_SUCCESS_MUST_ESCAPE" or (bescape == true and outcome ~= "ESPIONAGE_KILLED") then
		
		if bescape == true  then
			Spy_Escape(pUnit)
		end
		
		if pUnit:GetProperty("OPERATION") == "UNITOPERATION_SPYPOISON" then
			print("Trigger")
			
		local notificationData :table = {};
		notificationData[ParameterTypes.MESSAGE] = "succeed"--Locale.Lookup("LOC_NOTIFICATION_NEW_RELIC_MESSAGE", lockedRelics[relicRand].Name);
		notificationData[ParameterTypes.SUMMARY] = "summary" --Locale.Lookup("LOC_NOTIFICATION_NEW_RELIC_SUMMARY");
		--notificationData[CustomNotificationParameters.CivicDiscovered_CivicIndex] = lockedRelics[relicRand].Index;
		NotificationManager.SendNotification(iPlayerID, NotificationTypes.SPY_ESCAPED_CAPTURE, notificationData);
			
			
			
			
		end
	
	end
	
	-- Spy must flee
	if outcome == "ESPIONAGE_SUCCESS_MUST_ESCAPE" or outcome == "ESPIONAGE_FAIL_MUST_ESCAPE" then
		
		local notificationData :table = {};
		notificationData[ParameterTypes.MESSAGE] = "escape" --Locale.Lookup("LOC_NOTIFICATION_NEW_RELIC_MESSAGE", lockedRelics[relicRand].Name);
		notificationData[ParameterTypes.SUMMARY] = "summary" --Locale.Lookup("LOC_NOTIFICATION_NEW_RELIC_SUMMARY");
		notificationData[ParameterTypes.LOCATION] = { x = pUnit:GetX(), y = pUnit:GetY() };
		NotificationManager.SendNotification(iPlayerID, NotificationTypes.USER_DEFINED_9, notificationData);
		print("Escape Notification Sent")
	end
	-- Spy failed
	
	if outcome == "ESPIONAGE_FAIL_MUST_ESCAPE" or outcome == "ESPIONAGE_FAIL_UNDETECTED" then
		print("Escape")
		local notificationData :table = {};
		notificationData[ParameterTypes.MESSAGE] = "Fail" --Locale.Lookup("LOC_NOTIFICATION_NEW_RELIC_MESSAGE", lockedRelics[relicRand].Name);
		notificationData[ParameterTypes.SUMMARY] = "summary" --Locale.Lookup("LOC_NOTIFICATION_NEW_RELIC_SUMMARY");
		--notificationData[CustomNotificationParameters.CivicDiscovered_CivicIndex] = lockedRelics[relicRand].Index;
		NotificationManager.SendNotification(iPlayerID, NotificationTypes.SPY_MISSION_FAILED, notificationData);
	end
	
end

function MissionOutcome(pUnit)
	if pUnit == nil or pUnit:GetProperty("BASE_PROBABILITY") == nil then
		return
	end
	print("MissionOutcome",pUnit,pUnit:GetProperty("BASE_PROBABILITY"))
	local baseprobability = pUnit:GetProperty("BASE_PROBABILITY")/100
	local results = {}
	results["ESPIONAGE_SUCCESS_UNDETECTED"] = baseprobability
	results["ESPIONAGE_SUCCESS_MUST_ESCAPE"] = (1 - baseprobability)/3
	results["ESPIONAGE_FAIL_UNDETECTED"] = (1 - baseprobability)/3
	results["ESPIONAGE_FAIL_MUST_ESCAPE"] = (1 - baseprobability)/4
	results["ESPIONAGE_KILLED"] = (1 - baseprobability)/12
	
	local roll = RandRange(1, 100, "OCC - MissionOutcome()",pUnit:GetProperty("OPERATION"));
	print("MissionOutcome",roll/100,results["ESPIONAGE_SUCCESS_UNDETECTED"],results["ESPIONAGE_SUCCESS_MUST_ESCAPE"],results["ESPIONAGE_FAIL_UNDETECTED"],results["ESPIONAGE_FAIL_MUST_ESCAPE"],results["ESPIONAGE_KILLED"])
	if roll / 100 < results["ESPIONAGE_SUCCESS_UNDETECTED"] then
		print(roll / 100,results["ESPIONAGE_SUCCESS_UNDETECTED"])
		return "ESPIONAGE_SUCCESS_UNDETECTED"
	elseif roll / 100 < (results["ESPIONAGE_SUCCESS_UNDETECTED"] + results["ESPIONAGE_SUCCESS_MUST_ESCAPE"]) then
		print(roll / 100,(results["ESPIONAGE_SUCCESS_UNDETECTED"] + results["ESPIONAGE_SUCCESS_MUST_ESCAPE"]))
		return "ESPIONAGE_SUCCESS_MUST_ESCAPE"
	elseif roll / 100 < (results["ESPIONAGE_SUCCESS_UNDETECTED"] + results["ESPIONAGE_SUCCESS_MUST_ESCAPE"] + results["ESPIONAGE_FAIL_UNDETECTED"]) then
		print(roll / 100,(results["ESPIONAGE_SUCCESS_UNDETECTED"] + results["ESPIONAGE_SUCCESS_MUST_ESCAPE"] + results["ESPIONAGE_FAIL_UNDETECTED"]))
		return "ESPIONAGE_FAIL_UNDETECTED"
	elseif roll / 100 < (results["ESPIONAGE_SUCCESS_UNDETECTED"] + results["ESPIONAGE_SUCCESS_MUST_ESCAPE"] + results["ESPIONAGE_FAIL_UNDETECTED"] + results["ESPIONAGE_FAIL_MUST_ESCAPE"]) then
		print(roll / 100,(results["ESPIONAGE_SUCCESS_UNDETECTED"] + results["ESPIONAGE_SUCCESS_MUST_ESCAPE"] + results["ESPIONAGE_FAIL_UNDETECTED"]+ results["ESPIONAGE_FAIL_MUST_ESCAPE"]))
		return "ESPIONAGE_FAIL_MUST_ESCAPE"
	else
		print(roll / 100,1-results["ESPIONAGE_KILLED"])
		return "ESPIONAGE_KILLED"
	end	
end

-- Spy Missions

function Spy_Escape(pUnit:table)
	if pUnit == nil then
		print("Error: Spy_Escape, no valid unit")
		return
	end
	
	local ownerID = pUnit:GetOwner()
	local pPlayer = Players[ownerID]
	local capital =  pPlayer:GetCities():GetCapitalCity()
	print("Spy_Escape",capital:GetX(), capital:GetY())
	UnitManager.MoveUnit(pUnit, capital:GetX(), capital:GetY());
	
end
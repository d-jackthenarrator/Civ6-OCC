--[[
-- Created by D. / Jack The Narrator
-- Support for new Spy Missions for OCC
-- Copy the BASE file so Expansion would be added on top
--]]

-- ===========================================================================
--
--	Slideout panel for selecting a new destination for a spy unit
--
-- ===========================================================================
include("InstanceManager");
include("AnimSidePanelSupport");
include("SupportFunctions");
include("EspionageSupport");
include("Colors");

-- ===========================================================================
--	CONSTANTS
-- ===========================================================================
local RELOAD_CACHE_ID:string = "EspionageChooser"; -- Must be unique (usually the same as the file name)
local MAX_BEFORE_TRUNC_CHOOSE_NEXT:number = 210;

local EspionageChooserModes:table = {
	DESTINATION_CHOOSER	= 0;
	MISSION_CHOOSER		= 1;
};

local MISSION_CHOOSER_MISSIONSCROLLPANEL_RELATIVE_SIZE_Y = -132;
local DESTINATION_CHOOSER_MISSIONSCROLLPANEL_RELATIVE_SIZE_Y = -267;

local DISTRICT_IM:string = "DistrictIM";
local DISTRICT_SCROLL_POS:string = "DistrictScrollPos";

local MAX_DISTRICTS_TO_SHOW:number = 7;

-- ===========================================================================
--	MEMBERS
-- ===========================================================================
local m_AnimSupport			:table; -- AnimSidePanelSupport

-- Current EspionageChooserMode
local m_currentChooserMode	:number = -1;

-- Instance managers
local m_RouteChoiceIM		:table = InstanceManager:new("DestinationInstance", "DestinationButton",	Controls.DestinationStack);
local m_MissionStackIM		:table = InstanceManager:new("MissionInstance",		"MissionButton",		Controls.MissionStack);

-- Currently selected spy
local m_spy					:table = nil;

-- While in DESTINATION_CHOOSER - Currently selected destination
-- While in MISSION_CHOOSER - City where the selected spy resides
local m_city				:table = nil;

-- ===========================================================================
					   
																			  
function Refresh()
	if m_spy == nil then
		UI.DataError("m_spy is nil. Expected to be currently selected spy.");
		Close();
		return;
	end

	if m_city == nil and m_currentChooserMode == EspionageChooserModes.MISSION_CHOOSER then
		UI.DataError("m_city is nil while updating espionage mission chooser. Expected to be city spy currently resides in.");
		Close();
		return;
	end


	RefreshTop();
	RefreshBottom();
end

																		  
-- ===========================================================================
function RefreshTop()
	if m_currentChooserMode == EspionageChooserModes.DESTINATION_CHOOSER then
		-- DESTINATION_CHOOSER
		Controls.Title:SetText(Locale.ToUpper("LOC_ESPIONAGECHOOSER_PANEL_HEADER"));

		-- Controls that should never be visible in the DESTINATION_CHOOSER
		Controls.ActiveBoostContainer:SetHide(true);
		Controls.NoActiveBoostLabel:SetHide(true);
		
		-- If we've selected a city then show the district icons for that city
		if m_city then
			
			AddDistrictIcons(Controls, m_city);
			Controls.DistrictInfo:SetHide(false);
			Controls.SelectACityMessage:SetHide(true);
																  
		
																  
																  
	   
	  
	 
	

			UpdateCityBanner(m_city);
													   
															   
		  
		else
			Controls.BannerBase:SetHide(true);
			Controls.DistrictsScrollLeftButton:SetHide(true);
			Controls.DistrictsScrollRightButton:SetHide(true);
			Controls.DistrictInfo:SetHide(true);
			Controls.SelectACityMessage:SetHide(false);
		end
	else
		-- MISSION_CHOOSER
		Controls.Title:SetText(Locale.ToUpper("LOC_ESPIONAGECHOOSER_CHOOSE_MISSION"));

		-- Controls that should never be visible in the MISSION_CHOOSER
		Controls.SelectACityMessage:SetHide(true);
		Controls.DistrictInfo:SetHide(true);

		-- Controls that should always be visible in the MISSION_CHOOSER
		Controls.BannerBase:SetHide(false);

		UpdateCityBanner(m_city);
		
		-- Update active gain sources boost message
		local player = Players[Game.GetLocalPlayer()];
		local playerDiplomacy:table = player:GetDiplomacy();
		if playerDiplomacy then
			local boostedTurnsRemaining:number = playerDiplomacy:GetSourceTurnsRemaining(m_city);
			if boostedTurnsRemaining > 0 then
				TruncateStringWithTooltip(Controls.ActiveBoostLabel, MAX_BEFORE_TRUNC_CHOOSE_NEXT, Locale.Lookup("LOC_ESPIONAGECHOOSER_GAIN_SOURCES_ACTIVE", boostedTurnsRemaining));
				
				--Controls.ActiveBoostLabel:SetText(Locale.Lookup("LOC_ESPIONAGECHOOSER_GAIN_SOURCES_ACTIVE", boostedTurnsRemaining));
				Controls.ActiveBoostContainer:SetHide(false);
				Controls.NoActiveBoostLabel:SetHide(true);
			else
				Controls.ActiveBoostContainer:SetHide(true);
				Controls.NoActiveBoostLabel:SetHide(false);
			end
		end
	end
end

-- ===========================================================================
function RefreshBottom()
	if m_currentChooserMode == EspionageChooserModes.DESTINATION_CHOOSER then
		-- DESTINATION_CHOOSER
		if m_city then
			Controls.DestinationPanel:SetHide(true);
			Controls.MissionPanel:SetHide(false);
			Controls.PossibleMissionsLabel:SetHide(false);
			Controls.DestinationChooserButtons:SetHide(false);
			Controls.MissionScrollPanel:SetParentRelativeSizeY(DESTINATION_CHOOSER_MISSIONSCROLLPANEL_RELATIVE_SIZE_Y);
			RefreshMissionList();
	
 
						  
													 
					 
																			
												   
						
		else
			Controls.DestinationPanel:SetHide(false);
			Controls.MissionPanel:SetHide(true);
			m_RouteChoiceIM:ResetInstances();
			RefreshDestinationList();
		end
	else
		-- MISSION_CHOOSER
		-- Controls that should never be visible in the MISSION_CHOOSER
		Controls.DestinationPanel:SetHide(true);
		Controls.PossibleMissionsLabel:SetHide(true);
		Controls.DestinationChooserButtons:SetHide(true);

		-- Controls that should always be visible in the MISSION_CHOOSER
		Controls.MissionPanel:SetHide(false);

		Controls.MissionScrollPanel:SetParentRelativeSizeY(MISSION_CHOOSER_MISSIONSCROLLPANEL_RELATIVE_SIZE_Y);
		RefreshMissionList();
	end
end
-- ===========================================================================
-- Add Support for the new Missions
-- ===========================================================================
function OnCustomMissionStarted()
	print("OnCustomMissionStarted()")
	Close()
end

LuaEvents.EspionagePopup_CustomMissionStarted.Add (OnCustomMissionStarted)
-- ===========================================================================
function GoToProperInterfaceMode(spyUnit:table)
	local desiredInterfaceMode:number = nil;

	if spyUnit and spyUnit:IsReadyToMove() and spyUnit:GetProperty("ON_A_MISSION") ~= 1 then
		local spyUnitInfo:table = GameInfo.Units[spyUnit:GetUnitType()];
		if spyUnitInfo.Spy then
			-- Make sure the spy is awake
			local activityType:number = UnitManager.GetActivityType(spyUnit);
			if activityType == ActivityTypes.ACTIVITY_AWAKE then
				local spyPlot:table = Map.GetPlot(spyUnit:GetX(), spyUnit:GetY());
				local city:table = Cities.GetPlotPurchaseCity(spyPlot);
				if city and city:GetOwner() == Game.GetLocalPlayer() then
					--UI.SetInterfaceMode(InterfaceModeTypes.SPY_TRAVEL_TO_CITY);
					desiredInterfaceMode = InterfaceModeTypes.SPY_TRAVEL_TO_CITY;
				else
					--UI.SetInterfaceMode(InterfaceModeTypes.SPY_CHOOSE_MISSION);
					desiredInterfaceMode = InterfaceModeTypes.SPY_CHOOSE_MISSION;
				end
			end
		end
	end

	if desiredInterfaceMode then
		if UI.GetInterfaceMode() == desiredInterfaceMode then
			-- If already in the right interfacec mode then just refresh
			Open();
		else
			UI.SetInterfaceMode(desiredInterfaceMode);
		end
	else
		-- If not going to an espionage interface mode then close if we're open
		if m_AnimSupport:IsVisible() then
			Close();
		end
	end
end

-- ===========================================================================
-- Refresh the destination list with all revealed non-city state owned cities
-- ===========================================================================
function RefreshDestinationList()
	local localPlayerID = Game.GetLocalPlayer();
	local localPlayer = Players[localPlayerID];
	if localPlayer == nil then
		return;
	end

	-- Add each players cities to destination list
	local players:table = Game.GetPlayers();
	for i, player in ipairs(players) do
		local diploStateID:number = player:GetDiplomaticAI():GetDiplomaticStateIndex( localPlayerID );
		if diploStateID ~= -1 then
			local disploState:string = GameInfo.DiplomaticStates[diploStateID].StateType;
			-- Only show full civs
			if player:IsMajor() and disploState ~= "DIPLO_STATE_ALLIED" then
				if (player:GetID() == localPlayer:GetID() or player:GetTeam() == -1 or localPlayer:GetTeam() == -1 or player:GetTeam() ~= localPlayer:GetTeam()) then
					AddPlayerCities(player);
				end
			end
		end
	end

	Controls.DestinationPanel:CalculateInternalSize();
end

-- ===========================================================================
-- Refresh the mission list with counterspy targets for cities the player owns
-- and offensive spy operations for cities owned by other players
-- ===========================================================================

function RefreshMissionList()
	print("RefreshMissionList()")
	m_MissionStackIM:ResetInstances();

	-- Determine if this is a owned by the local player
	if m_city:GetOwner() == Game.GetLocalPlayer() then
		-- If we own this city show a list of possible counterspy targets
		for operation in GameInfo.UnitOperations() do
		
			
			if operation.OperationType == "UNITOPERATION_SPY_COUNTERSPY" then
				local cityPlot:table = Map.GetPlot(m_city:GetX(), m_city:GetY());
				local canStart:boolean, results:table = UnitManager.CanStartOperation( m_spy, operation.Hash, cityPlot, false, true);
				if canStart then
					-- Check the CanStartOperation results for a target district plot
					for i,districtPlotID in ipairs(results[UnitOperationResults.PLOTS]) do
						AddCounterspyOperation(operation, districtPlotID);
					end
				end
			end
		end
	else
		-- Fill mission stack with possible missions at selected city
		for operation in GameInfo.UnitOperations() do
			if operation.CategoryInUI == "OFFENSIVESPY" then
				local cityPlot:table = Map.GetPlot(m_city:GetX(), m_city:GetY());
				local canStart:boolean, results:table = UnitManager.CanStartOperation( m_spy, operation.Hash, cityPlot, false, true);
				if canStart then
					local bAddedOperation:boolean = false;

					-- Look through the results to determine if this operation is targeting a specific district
					if results and results[UnitOperationResults.PLOTS] then
						for i,districtPlotID in ipairs(results[UnitOperationResults.PLOTS]) do
							local pTargetPlot:table = Map.GetPlotByIndex(districtPlotID);
							if pTargetPlot ~= nil then
								AddAvailableOffensiveOperation(operation, results, pTargetPlot);
								bAddedOperation = true;
							end
						end
					end

					-- If the operation wasn't added with a specific district then just use the city
					if bAddedOperation == false then
						AddAvailableOffensiveOperation(operation, results, cityPlot);
					end
				else
					---- If we're provided with a failure reason then show the mission disabled
					if results and results[UnitOperationResults.FAILURE_REASONS] then
						AddDisabledOffensiveOperation(operation, results, cityPlot);
					end
				end
			end
			-- New Custom Mission
			if operation.CategoryInUI == "OFFENSIVESPY_EXTRA" then
				local cityPlot:table = Map.GetPlot(m_city:GetX(), m_city:GetY());
				local canStart:boolean, results:table = UnitManager.CanStartOperation( m_spy, operation.Hash, cityPlot, false, true);
				print("operation.OperationType",operation.OperationType,"operation.Hash",operation.Hash,"operation.TargetDistrict",operation.TargetDistrict,"operation.VisibleInUI",operation.VisibleInUI,"operation.Offensive",operation.Offensive,"canStart",canStart,"results",results)
				print("operation.Index",operation.Index,"operation.Turns",operation.Turns)
				canStart = true
				if canStart then
					local bAddedOperation:boolean = false;

					-- Look through the results to determine if this operation is targeting a specific district
					if results and results[UnitOperationResults.PLOTS] then
						for i,districtPlotID in ipairs(results[UnitOperationResults.PLOTS]) do
							local pTargetPlot:table = Map.GetPlotByIndex(districtPlotID);
							if pTargetPlot ~= nil then
								AddCustomAvailableOffensiveOperation(operation, results, pTargetPlot);
								bAddedOperation = true;
							end
						end
					end

					-- If the operation wasn't added with a specific district then just use the city
					if bAddedOperation == false then
						AddCustomAvailableOffensiveOperation(operation, results, cityPlot);
					end
				else
					---- If we're provided with a failure reason then show the mission disabled
					if results and results[UnitOperationResults.FAILURE_REASONS] then
						AddDisabledCustomOffensiveOperation(operation, results, cityPlot);
					end
				end
			end
		end
	end

	Controls.MissionScrollPanel:CalculateInternalSize();
	

	print("RefreshMissionList() - Completed")
end

-- ===========================================================================
-- Support
-- ===========================================================================
function GetFormattedCustomOperationDetailText(operation:table, spy:table, city:table)

	if operation.CategoryInUI ~= "OFFENSIVESPY_EXTRA" then
		return GetFormattedOperationDetailText(operation, spy, city)
	end
	local outputString:string = "";
	local eOperation:number = GameInfo.UnitOperations[operation.Hash].Index;
	local sOperationDetails:string = "" -- UnitManager.GetOperationDetailText(eOperation, spy, Map.GetPlot(city:GetX(), city:GetY()));
	if operation.OperationType == "UNITOPERATION_SPY_GREAT_WORK_HEIST" then
		outputString = Locale.Lookup("LOC_SPYMISSIONDETAILS_UNITOPERATION_SPY_GREAT_WORK_HEIST", sOperationDetails);
	elseif operation.OperationType == "UNITOPERATION_SPY_SIPHON_FUNDS" then
		outputString = Locale.Lookup("LOC_SPYMISSIONDETAILS_UNITOPERATION_SPY_SIPHON_FUNDS", Locale.ToUpper(city:GetName()), sOperationDetails);
	elseif operation.OperationType == "UNITOPERATION_SPY_FOMENT_UNREST" then
		outputString = Locale.Lookup("LOC_SPYMISSIONDETAILS_UNITOPERATION_SPY_FOMENT_UNREST", sOperationDetails);
	elseif operation.OperationType == "UNITOPERATION_SPY_FABRICATE_SCANDAL" then
		outputString = Locale.Lookup("LOC_SPYMISSIONDETAILS_UNITOPERATION_SPY_FABRICATE_SCANDAL", sOperationDetails);
	elseif operation.OperationType == "UNITOPERATION_SPY_NEUTRALIZE_GOVERNOR" then
		outputString = Locale.Lookup("LOC_SPYMISSIONDETAILS_UNITOPERATION_SPY_NEUTRALIZE_GOVERNOR", sOperationDetails);
	elseif sOperationDetails ~= "" then
		outputString = sOperationDetails;
	else
		-- Find the loc string by OperationType if this operation doesn't use GetOperationDetailText
		outputString = Locale.Lookup("LOC_SPYMISSIONDETAILS_" .. operation.OperationType);
	end

	return outputString;
end

function GetCustomTimeToComplete(operation:table, spy:table)

	if operation.CategoryInUI ~= "OFFENSIVESPY_EXTRA" then
		return UnitManager.GetTimeToComplete(operation.Index, spy)
		else
		return 1
	end
end

function GetCustomProbabilityTable(operation:table, spy:table, plot:table)
	local results = {}
	if operation.CategoryInUI ~= "OFFENSIVESPY_EXTRA" then
		results = UnitManager.GetResultProbability(m_operation.Index, m_spy, m_pTargetPlot) 
		else
		local baseprobability = operation.BaseProbability / 100
		results["ESPIONAGE_SUCCESS_UNDETECTED"] = baseprobability
		results["ESPIONAGE_SUCCESS_MUST_ESCAPE"] = (1 - baseprobability)/3
		results["ESPIONAGE_FAIL_UNDETECTED"] = (1 - baseprobability)/3
		results["ESPIONAGE_FAIL_MUST_ESCAPE"] = (1 - baseprobability)/4
		results["ESPIONAGE_KILLED"] = (1 - baseprobability)/12	
	end
	return results
end




-- ===========================================================================
-- Custom UI Support
-- ===========================================================================

function AddCustomAvailableOffensiveOperation(operation:table, result:table, pTargetPlot:table)
	print("AddCustomAvailableOffensiveOperation")
	local missionInstance:table = AddCustomOffensiveOperation(operation, result, pTargetPlot);

	-- Update mission details
	missionInstance.MissionDetails:SetText(GetFormattedCustomOperationDetailText(operation, m_spy, m_city));
	missionInstance.MissionDetails:SetColorByName("White");

	missionInstance.MissionStack:CalculateSize();
	missionInstance.MissionButton:DoAutoSize();

	-- If this is the mission choose set callback to open up mission briefing
	print("m_currentChooserMode",m_currentChooserMode,EspionageChooserModes.MISSION_CHOOSER)
	if m_currentChooserMode == EspionageChooserModes.MISSION_CHOOSER then
		missionInstance.MissionButton:RegisterCallback( Mouse.eLClick, function() OnMissionSelected(operation, missionInstance, pTargetPlot); end );
	end

	-- While in DESTINATION_CHOOSER mode we don't want the buttons to act
	-- like buttons since they cannot be clicked in that mode
	if m_currentChooserMode == EspionageChooserModes.DESTINATION_CHOOSER then
		missionInstance.MissionButton:SetDisabled(true);
		missionInstance.MissionButton:SetVisState(0);
	else
		missionInstance.MissionButton:SetDisabled(false);
	end
end

function AddDisabledCustomOffensiveOperation(operation:table, result:table, targetCityPlot:table)

	local missionInstance:table = AddCustomOffensiveOperation(operation, result, targetCityPlot);
	-- Update mission description with reason the mission is disabled
	if result and result[UnitOperationResults.FAILURE_REASONS] then
		local failureReasons:table = result[UnitOperationResults.FAILURE_REASONS];
		local missionDetails:string = "";

		-- Add all given reasons into mission details
		for i,reason in ipairs(failureReasons) do
			if missionDetails == "" then
				missionDetails = reason;
			else
				missionDetails = missionDetails .. "[NEWLINE]" .. reason;
			end
		end

		missionInstance.MissionDetails:SetText(missionDetails);
		missionInstance.MissionDetails:SetColorByName("Red");
	end

	missionInstance.MissionStack:CalculateSize();
	missionInstance.MissionButton:DoAutoSize();

	-- Disable mission button
	missionInstance.MissionButton:SetDisabled(true);
end


function AddCustomOffensiveOperation(operation:table, result:table, targetCityPlot:table)
	print("AddCustomOffensiveOperation")
	local missionInstance:table = m_MissionStackIM:GetInstance();
	missionInstance.MissionButton:SetDisabled(false);
	-- Update mission name
	missionInstance.MissionName:SetText(Locale.Lookup(operation.Description));
	-- Update mission icon
	missionInstance.MissionIcon:SetIcon(operation.Icon);
	missionInstance.MissionIcon:SetHide(false)
	missionInstance.TargetDistrictIcon:SetHide(true);
	RefreshCustomMissionStats(missionInstance, operation, result, m_spy, m_city, targetCityPlot);

	missionInstance.MissionStatsStack:SetHide(false);
	missionInstance.MissionStatsStack:CalculateSize();

	-- Default the selector brace to hidden
	missionInstance.SelectorBrace:SetColor(UI.GetColorValueFromHexLiteral(0x00FFFFFF));
	return missionInstance;
end

function RefreshCustomMissionStats( parentControl:table, operation:table, result:table, spy:table, city:table, targetPlot:table )
	print("RefreshCustomMissionStats")
	-- Update turns to completed
	local eOperation:number = operation.Index;
	
	local turnsToComplete:number = 0
	
	turnsToComplete = GetCustomTimeToComplete(operation, spy)

	parentControl.TurnsToCompleteLabel:SetText(turnsToComplete);

	-- Update mission success chance
	if operation.Hash ~= UnitOperationTypes.SPY_COUNTERSPY then
		local resultProbability = {}
		resultProbability = GetCustomProbabilityTable(operation, spy, targetPlot)


	    if resultProbability["ESPIONAGE_SUCCESS_UNDETECTED"] then
		    local probability:number = resultProbability["ESPIONAGE_SUCCESS_UNDETECTED"];

		    -- Add ESPIONAGE_SUCCESS_MUST_ESCAPE
		    if resultProbability["ESPIONAGE_SUCCESS_MUST_ESCAPE"] then
			    probability = probability + resultProbability["ESPIONAGE_SUCCESS_MUST_ESCAPE"];
		    end

		    probability = math.floor((probability * 100)+0.5);
		    parentControl.ProbabilityLabel:SetText(probability .. "%");

		    -- Set Color
		    if probability > 85 then
			    parentControl.ProbabilityLabel:SetColorByName("OperationChance_Green");
		    elseif probability > 65 then
			    parentControl.ProbabilityLabel:SetColorByName("OperationChance_YellowGreen");
		    elseif probability > 45 then
			    parentControl.ProbabilityLabel:SetColorByName("OperationChance_Yellow");
		    elseif probability > 25 then
			    parentControl.ProbabilityLabel:SetColorByName("OperationChance_Orange");
		    else
			    parentControl.ProbabilityLabel:SetColorByName("OperationChance_Red");
		    end
		end

		parentControl.ProbabilityGrid:SetHide(false);
    else
        parentControl.ProbabilityGrid:SetHide(true);
    end

	-- result is the data bundle retruned by CanStartOperation container useful information about the operation query
	-- If the results contain a plot ID then show that as the target district
	if operation.Hash == UnitOperationTypes.SPY_COUNTERSPY then
	    local kDistrictInfo:table = GameInfo.Districts[targetPlot:GetDistrictType()];
	    parentControl.MissionDistrictName:SetText(Locale.Lookup(kDistrictInfo.Name));
	    local iconString:string = "ICON_" .. kDistrictInfo.DistrictType;
		if parentControl.MissionDistrictIcon then
			parentControl.MissionDistrictIcon:SetIcon(iconString);
		end
	elseif result and result[UnitOperationResults.PLOTS] then
		for i,districtPlotID in ipairs(result[UnitOperationResults.PLOTS]) do
			local districts:table = city:GetDistricts();
			for i,district in districts:Members() do
				local districtPlot:table = Map.GetPlot(district:GetX(), district:GetY());
				if districtPlot:GetIndex() == districtPlotID then
					local districtInfo:table = GameInfo.Districts[district:GetType()];
					parentControl.MissionDistrictName:SetText(Locale.Lookup(districtInfo.Name));
					local iconString:string = "ICON_" .. districtInfo.DistrictType;
					if parentControl.MissionDistrictIcon then
						parentControl.MissionDistrictIcon:SetIcon(iconString);
					end
				end
			end
		end
	else -- Default to show city center
		parentControl.MissionDistrictName:SetText(Locale.Lookup("LOC_DISTRICT_CITY_CENTER_NAME"));
		parentControl.MissionDistrictIcon:SetIcon("ICON_DISTRICT_CITY_CENTER");
	end
end
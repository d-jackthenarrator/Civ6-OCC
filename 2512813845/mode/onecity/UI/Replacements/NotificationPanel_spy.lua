-- Copyright 2017-2018, Firaxis Games

-- This file is being included into the base NotificationPanel file using the wildcard include setup in NotificationPanel.lua
-- Refer to the bottom of NotificationPanel.lua to see how that's happening
-- DO NOT include any NotificationPanel files here or it will cause problems
--include("NotificationPanel");


-- ===========================================================================
-- CACHE BASE FUNCTIONS
-- ===========================================================================
local BASE_RegisterHandlers = RegisterHandlers;
local BASE_LateInitialize = LateInitialize;
local BASE_OnDefaultAddNotification = OnDefaultAddNotification;


-- ===========================================================================
-- VARIABLES
-- ===========================================================================
-- Additional notification handlers for events not defined as part of the g_notificationHandlers object.
-- Has to be an additional table due to g_notificationHandlers being an already defined havok structure.
-- Indexed by notification type hash. 
local m_customNotifyHandlers :table = {};

-- ===========================================================================
function OnDefaultAddNotification(pNotification:table)
	BASE_OnDefaultAddNotification(pNotification);

	local notificationID	:number				= pNotification:GetID();
	local playerID			:number				= Game.GetLocalPlayer();
	local notificationEntry	:NotificationType	= GetNotificationEntry( playerID, notificationID );
	local turnNumber		:number				= Game.GetCurrentGameTurn()

	--Skip the war declaration notification spam at start of game

	if(notificationEntry.m_Instance ~= nil)then
		if(notificationEntry.m_TypeName == 'NotificationTypes.USER_DEFINED_9')then
			notificationEntry.m_Instance.Icon:SetIcon("NOTIFICATION_SPY_CHOOSE_ESCAPE_ROUTE");
		end
	end
end

-- ===========================================================================
-- HELPER FUNCTIONS
-- ===========================================================================
function DismissAll(playerID :number, notificationType :number)
	local notifyIDList :table = NotificationManager.GetList(playerID);
	if(notifyIDList ~= nil) then
		for _, loopNotifyID in pairs(notifyIDList) do
			local pNotification = NotificationManager.Find(playerID, loopNotifyID);
			if(pNotification ~= nil and pNotification:GetType() == notificationType) then	
				NotificationManager.Dismiss( playerID, loopNotifyID );
			end
		end	
	end
end

function DismissByProperty(playerID :number, notificationType :number, propertyName :string, propertyValue)
	local notifyIDList :table = NotificationManager.GetList(playerID);
	if(notifyIDList ~= nil) then
		for _, loopNotifyID in pairs(notifyIDList) do
			local pNotification = NotificationManager.Find(playerID, loopNotifyID);
			if(pNotification ~= nil and pNotification:GetType() == notificationType) then
				local notifyPropValue = pNotification:GetValue(propertyName);
				if(notifyPropValue ~= nil and notifyPropValue == propertyValue) then
					NotificationManager.Dismiss( playerID, loopNotifyID );
				end
			end
		end	
	end
end


-- ===========================================================================
-- NEW NOTIFICATION HANDLERS
-- ===========================================================================


function OnNewInfamousPirateActivate( notificationEntry : NotificationType )
	if (notificationEntry ~= nil and notificationEntry.m_PlayerID == Game.GetLocalPlayer()) then
		local pNotification :table = GetActiveNotificationFromEntry(notificationEntry, notificationID);
		if pNotification ~= nil then
			local searchZoneID :number = pNotification:GetValue(g_notificationKeys.InfamousSearchZoneID);
			if(searchZoneID ~= nil) then
				local searchZones :table = Game:GetProperty(g_gamePropertyKeys.InfamousPirateSearchZones);
				if(searchZones ~= nil) then
					for loop, curZone in ipairs(searchZones) do
						if(curZone.ZoneID == searchZoneID and curZone.CenterPlotIndex ~= nil) then
							local zoneCenterPlot :object = Map.GetPlotByIndex(curZone.CenterPlotIndex);
							if(zoneCenterPlot ~= nil) then
								UI.LookAtPlot(zoneCenterPlot:GetX(), zoneCenterPlot:GetY());
							end
						end
					end
				end
			end
		end
	end
end


-- ===========================================================================
-- NEW EVENT HANDLERS
-- ===========================================================================
function OnNotificationAdded_Spy( playerID:number, notificationID:number )
	local pAddNotification = NotificationManager.Find(playerID, notificationID);
	if(pAddNotification == nil) then
		print("Added notification missing.");
		return;
	end

end

-- =======================================================================================
-- Custom Espionage Handlers
-- =======================================================================================
function OnCustomChooseEscapeRouteActivate( notificationEntry : NotificationType )
	
	if (notificationEntry ~= nil and notificationEntry.m_PlayerID == Game.GetLocalPlayer()) then
		local pNotification :table = GetActiveNotificationFromEntry(notificationEntry, notificationID);
		if pNotification ~= nil then
			if pNotification:IsLocationValid() then			
				local x, y = pNotification:GetLocation();
				print("	OnCustomChooseEscapeRouteActivate",x,y)
				LuaEvents.NotificationPanel_OpenCustomEspionageEscape( x, y );
			end
		end
	end
	
	


end

-- ===========================================================================
-- BASE FUNCTION REPLACEMENTS
-- ===========================================================================
function RegisterHandlers()
	BASE_RegisterHandlers();
	print("RegisterHandlers()",g_notificationHandlers)
	g_notificationHandlers[NotificationTypes.USER_DEFINED_9].Activate		= OnCustomChooseEscapeRouteActivate;
end

function LateInitialize()
	BASE_LateInitialize();


	Events.NotificationAdded.Add( OnNotificationAdded_Spy ); -- Additional and separate from the base NotificationPanel implementation.
end


--==========================================================================================================================
-- One City Challenge by D. / Jack The Narrator
--==========================================================================================================================
-----------------------------------------------
-- Expansionist
-----------------------------------------------

INSERT INTO Types (Type, Kind) VALUES ('UNIT_EXPANSIONIST', 'KIND_UNIT');
INSERT INTO TypeTags (Type, Tag) VALUES ('UNIT_EXPANSIONIST', 'CLASS_LANDCIVILIAN');
INSERT INTO Units	(
		UnitType,
		BaseMoves,		
		Cost,
		AdvisorType,
		BaseSightRange,
		ZoneOfControl,
		Domain,
		FormationClass,
		Name,		
		Description,
		CanCapture,
		CostProgressionModel,
		CostProgressionParam1,
		PurchaseYield,
		PrereqCivic
		)
VALUES  (
		'UNIT_EXPANSIONIST',
		'2',	
		'60', 
		'ADVISOR_GENERIC',
		'2', 
		0,
		'DOMAIN_LAND', 
		'FORMATION_CLASS_CIVILIAN', 
		'LOC_EXPANSIONIST_NAME', 
		'LOC_EXPANSIONIST_DESC',
		0, 
		'COST_PROGRESSION_PREVIOUS_COPIES', 
		'20', 
		'YIELD_GOLD', 
		'CIVIC_EARLY_EMPIRE'
		);

-----------------------------------------------
-- Rally Point
-----------------------------------------------

INSERT INTO Types (Type, Kind) VALUES ('IMPROVEMENT_RALLY_POINT', 'KIND_IMPROVEMENT');
INSERT INTO Improvements	(
		ImprovementType,
		Icon,		
		PlunderType,
		Buildable,
		Appeal,
		Name,		
		Description
		)
VALUES  (
		'IMPROVEMENT_RALLY_POINT',
		'ICON_IMPROVEMENT_BARBARIAN_CAMP',	
		'NO_PLUNDER', 
		0,
		'-1', 
		'OCC_IMPROVEMENT_RALLY_POINT_NAME', 
		'OCC_IMPROVEMENT_RALLY_POINT_DESC'
		);


-----------------------------------------------
-- Create the new walls
-----------------------------------------------
UPDATE Improvements
Set TraitType=NULL
WHERE ImprovementType='IMPROVEMENT_GREAT_WALL';

UPDATE Improvements
Set Name='LOC_IMPROVEMENT_OCC_WALL_NAME'
WHERE ImprovementType='IMPROVEMENT_GREAT_WALL';

UPDATE Improvements
Set Description='LOC_IMPROVEMENT_OCC_WALL_DESC'
WHERE ImprovementType='IMPROVEMENT_GREAT_WALL';

UPDATE Improvements
Set CanBuildOutsideTerritory=1
WHERE ImprovementType='IMPROVEMENT_GREAT_WALL';

UPDATE Improvements
Set Buildable=0
WHERE ImprovementType='IMPROVEMENT_GREAT_WALL';

DELETE FROM Improvement_ValidBuildUnits
WHERE ImprovementType='IMPROVEMENT_GREAT_WALL';

-----------------------------------------------
-- ModifierArguments -- Religious Settlement
-----------------------------------------------
UPDATE ModifierArguments
Set Value='UNIT_EXPANSIONIST'
WHERE ModifierId='RELIGIOUS_SETTLEMENTS_SETTLER_MODIFIER' AND Name='UnitType';

UPDATE ModifierArguments
Set Value=2
WHERE ModifierId='RELIGIOUS_SETTLEMENTS_SETTLER_MODIFIER' AND Name='Amount';

-----------------------------------------------
-- ModifierArguments -- Monumentality Settlement
-----------------------------------------------
UPDATE ModifierArguments
Set Value='UNIT_EXPANSIONIST'
WHERE ModifierId='COMMEMORATION_INFRASTRUCTURE_SETTLER_DISCOUNT_MODIFIER' AND Name='UnitType';

-----------------------------------------------
-- MajorStartingUnits
-----------------------------------------------
UPDATE MajorStartingUnits 
SET Quantity = '1' 
WHERE Unit = 'UNIT_SETTLER';

-----------------------------------------------
-- Start with 3 Radius
-----------------------------------------------

INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES ('TRAIT_LEADER_MAJOR_CIV', 'TRAIT_INCREASED_TILES_MAX');

INSERT INTO Modifiers (ModifierId, ModifierType) VALUES ('TRAIT_INCREASED_TILES_MAX', 'MODIFIER_PLAYER_ADJUST_CITY_TILES');

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES ('TRAIT_INCREASED_TILES_MAX', 'Amount', '30');

-----------------------------------------------
-- Buff Trade Routes
-----------------------------------------------

UPDATE GlobalParameters
SET Value = '40' 
WHERE Name = 'TRADE_ROUTE_BASE_RANGE';

UPDATE GlobalParameters
SET Value = '40' 
WHERE Name = 'TRADE_ROUTE_LAND_RANGE_REFUEL';

UPDATE GlobalParameters
SET Value = '40' 
WHERE Name = 'TRADE_ROUTE_WATER_RANGE_REFUEL';

UPDATE GlobalParameters
SET Value = '8' 
WHERE Name = 'TRADE_ROUTE_GOLD_PER_DESTINATION_DISTRICT';

UPDATE GlobalParameters
SET Value = '8' 
WHERE Name = 'TRADE_ROUTE_GOLD_PER_ORIGIN_DISTRICT';

UPDATE GlobalParameters
SET Value = '5' 
WHERE Name = 'TRADING_POST_GOLD_IN_FOREIGN_CITY';

UPDATE GlobalParameters
SET Value = '2' 
WHERE Name = 'TRADING_POST_GOLD_IN_OWN_CITY';

-----------------------------------------------
-- Growth And Amenities
-----------------------------------------------

UPDATE GlobalParameters
SET Value = '4' 
WHERE Name = 'CITY_AMENITIES_FOR_FREE';

UPDATE GlobalParameters
SET Value = '12' 
WHERE Name = 'CITY_GROWTH_THRESHOLD';

-----------------------------------------------
-- Governor
-----------------------------------------------
-- Pingala GOVERNOR_THE_EDUCATOR
DELETE FROM GovernorsCannotAssign
WHERE GovernorType = 'GOVERNOR_THE_EDUCATOR';

INSERT INTO GovernorsCannotAssign (GovernorType, CannotAssign) VALUES ('GOVERNOR_THE_EDUCATOR', 1);

DELETE FROM GovernorPromotionSets
WHERE GovernorType = 'GOVERNOR_THE_EDUCATOR';

INSERT INTO Types (Type, Kind) VALUES ('THE_EDUCATOR_LEVEL_0', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_EDUCATOR_LEVEL_1', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_EDUCATOR_LEVEL_2', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_EDUCATOR_LEVEL_3', 'KIND_GOVERNOR_PROMOTION');

INSERT INTO GovernorPromotionSets	(GovernorType, 						GovernorPromotion)
VALUES  							('GOVERNOR_THE_EDUCATOR',			'THE_EDUCATOR_LEVEL_0'), -- +15% Science
									('GOVERNOR_THE_EDUCATOR',			'THE_EDUCATOR_LEVEL_1'), -- +10 Science in Capital
									('GOVERNOR_THE_EDUCATOR',			'THE_EDUCATOR_LEVEL_2'), -- Science on each tiles
									('GOVERNOR_THE_EDUCATOR',			'THE_EDUCATOR_LEVEL_3'); -- 

INSERT INTO GovernorPromotions		(GovernorPromotionType, 			Name,								Description,						Level,	Column,	BaseAbility)
VALUES  							('THE_EDUCATOR_LEVEL_0',			'OCC_THE_EDUCATOR_LEVEL_0_NAME',	'OCC_THE_EDUCATOR_LEVEL_0_DESC',	0,		1,		1),
									('THE_EDUCATOR_LEVEL_1',			'OCC_THE_EDUCATOR_LEVEL_1_NAME',	'OCC_THE_EDUCATOR_LEVEL_1_DESC',	1,		1,		0),
									('THE_EDUCATOR_LEVEL_2',			'OCC_THE_EDUCATOR_LEVEL_2_NAME',	'OCC_THE_EDUCATOR_LEVEL_2_DESC',	1,		1,		0),
									('THE_EDUCATOR_LEVEL_3',			'OCC_THE_EDUCATOR_LEVEL_3_NAME',	'OCC_THE_EDUCATOR_LEVEL_3_DESC',	1,		1,		0);
									
INSERT INTO GovernorPromotionPrereqs	(GovernorPromotionType, 			PrereqGovernorPromotion)
VALUES  								('THE_EDUCATOR_LEVEL_1',			'THE_EDUCATOR_LEVEL_0'),
										('THE_EDUCATOR_LEVEL_2',			'THE_EDUCATOR_LEVEL_1'),
										('THE_EDUCATOR_LEVEL_3',			'THE_EDUCATOR_LEVEL_2');

INSERT INTO GovernorPromotionConditions	(GovernorPromotionType, 			HiddenWithoutPrereqs,	EarliestGameEra)
VALUES  								('THE_EDUCATOR_LEVEL_0',			0,						NULL),
										('THE_EDUCATOR_LEVEL_1',			1,						'ERA_MEDIEVAL'),
										('THE_EDUCATOR_LEVEL_2',			1,						'ERA_INDUSTRIAL'),
										('THE_EDUCATOR_LEVEL_3',			1,						'ERA_ATOMIC');

INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_EDUCATOR_LEVEL_0', 'OCC_MOD_THE_EDUCATOR_LEVEL_0');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_EDUCATOR_LEVEL_1', 'OCC_MOD_THE_EDUCATOR_LEVEL_1');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_EDUCATOR_LEVEL_2', 'OCC_MOD_THE_EDUCATOR_LEVEL_2');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_EDUCATOR_LEVEL_3', 'OCC_MOD_THE_EDUCATOR_LEVEL_3');

INSERT INTO Modifiers 	(ModifierId, 						ModifierType,												OwnerRequirementSetId,	SubjectRequirementSetId) 
VALUES 					('OCC_MOD_THE_EDUCATOR_LEVEL_0', 	'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER',		NULL,					NULL),	
						('OCC_MOD_THE_EDUCATOR_LEVEL_1', 	'MODIFIER_PLAYER_CAPITAL_CITY_ADJUST_CITY_YIELD_CHANGE',	NULL,					NULL),	
						('OCC_MOD_THE_EDUCATOR_LEVEL_2', 	'MODIFIER_PLAYER_ADJUST_PLOT_YIELD',						NULL,					NULL),	
						('OCC_MOD_THE_EDUCATOR_LEVEL_3', 	'MODIFIER_PLAYER_CAPITAL_CITY_ADJUST_CITY_YIELD_CHANGE',	NULL,					NULL);							
									
INSERT INTO ModifierArguments 	(ModifierId, 						Name,				Value) 
VALUES 							('OCC_MOD_THE_EDUCATOR_LEVEL_0', 	'Amount',			15),
								('OCC_MOD_THE_EDUCATOR_LEVEL_0', 	'YieldType',		'YIELD_SCIENCE'),
								('OCC_MOD_THE_EDUCATOR_LEVEL_1', 	'Amount',			10),
								('OCC_MOD_THE_EDUCATOR_LEVEL_1', 	'YieldType',		'YIELD_SCIENCE'),
								('OCC_MOD_THE_EDUCATOR_LEVEL_2', 	'Amount',			1),
								('OCC_MOD_THE_EDUCATOR_LEVEL_2', 	'YieldType',		'YIELD_SCIENCE'),
								('OCC_MOD_THE_EDUCATOR_LEVEL_3', 	'Amount',			25),
								('OCC_MOD_THE_EDUCATOR_LEVEL_3', 	'YieldType',		'YIELD_SCIENCE');								
						
-- Moksha GOVERNOR_THE_CARDINAL
DELETE FROM GovernorsCannotAssign
WHERE GovernorType = 'GOVERNOR_THE_CARDINAL';

INSERT INTO GovernorsCannotAssign (GovernorType, CannotAssign) VALUES ('GOVERNOR_THE_CARDINAL', 1);

DELETE FROM GovernorPromotionSets
WHERE GovernorType = 'GOVERNOR_THE_CARDINAL';

INSERT INTO Types (Type, Kind) VALUES ('THE_CARDINAL_LEVEL_0', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_CARDINAL_LEVEL_1', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_CARDINAL_LEVEL_2', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_CARDINAL_LEVEL_3', 'KIND_GOVERNOR_PROMOTION');

INSERT INTO GovernorPromotionSets	(GovernorType, 						GovernorPromotion)
VALUES  							('GOVERNOR_THE_CARDINAL',			'THE_CARDINAL_LEVEL_0'), 
									('GOVERNOR_THE_CARDINAL',			'THE_CARDINAL_LEVEL_1'), 
									('GOVERNOR_THE_CARDINAL',			'THE_CARDINAL_LEVEL_2'), 
									('GOVERNOR_THE_CARDINAL',			'THE_CARDINAL_LEVEL_3'); 

INSERT INTO GovernorPromotions		(GovernorPromotionType, 			Name,								Description,						Level,	Column,	BaseAbility)
VALUES  							('THE_CARDINAL_LEVEL_0',			'OCC_THE_CARDINAL_LEVEL_0_NAME',	'OCC_THE_CARDINAL_LEVEL_0_DESC',	0,		1,		1),
									('THE_CARDINAL_LEVEL_1',			'OCC_THE_CARDINAL_LEVEL_1_NAME',	'OCC_THE_CARDINAL_LEVEL_1_DESC',	1,		1,		0),
									('THE_CARDINAL_LEVEL_2',			'OCC_THE_CARDINAL_LEVEL_2_NAME',	'OCC_THE_CARDINAL_LEVEL_2_DESC',	1,		1,		0),
									('THE_CARDINAL_LEVEL_3',			'OCC_THE_CARDINAL_LEVEL_3_NAME',	'OCC_THE_CARDINAL_LEVEL_3_DESC',	1,		1,		0);
									
INSERT INTO GovernorPromotionPrereqs	(GovernorPromotionType, 			PrereqGovernorPromotion)
VALUES  								('THE_CARDINAL_LEVEL_1',			'THE_CARDINAL_LEVEL_0'),
										('THE_CARDINAL_LEVEL_2',			'THE_CARDINAL_LEVEL_1'),
										('THE_CARDINAL_LEVEL_3',			'THE_CARDINAL_LEVEL_2');

INSERT INTO GovernorPromotionConditions	(GovernorPromotionType, 			HiddenWithoutPrereqs,	EarliestGameEra)
VALUES  								('THE_CARDINAL_LEVEL_0',			0,						NULL),
										('THE_CARDINAL_LEVEL_1',			1,						'ERA_MEDIEVAL'),
										('THE_CARDINAL_LEVEL_2',			1,						'ERA_INDUSTRIAL'),
										('THE_CARDINAL_LEVEL_3',			1,						'ERA_ATOMIC');

INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_CARDINAL_LEVEL_0', 'OCC_MOD_THE_CARDINAL_LEVEL_0');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_CARDINAL_LEVEL_1', 'OCC_MOD_THE_CARDINAL_LEVEL_1');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_CARDINAL_LEVEL_2', 'OCC_MOD_THE_CARDINAL_LEVEL_2');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_CARDINAL_LEVEL_3', 'OCC_MOD_THE_CARDINAL_LEVEL_3');

INSERT INTO Modifiers 	(ModifierId, 						ModifierType,												OwnerRequirementSetId,	SubjectRequirementSetId) 
VALUES 					('OCC_MOD_THE_CARDINAL_LEVEL_0', 	'MODIFIER_PLAYER_ADJUST_GREAT_PERSON_POINTS',				NULL,					NULL),	
						('OCC_MOD_THE_CARDINAL_LEVEL_1', 	'MODIFIER_PLAYER_ADJUST_PLOT_YIELD',						NULL,					NULL),	
						('OCC_MOD_THE_CARDINAL_LEVEL_2', 	'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER',		NULL,					NULL),	
						('OCC_MOD_THE_CARDINAL_LEVEL_3', 	'MODIFIER_PLAYER_ADJUST_TOURISM',							NULL,					NULL);							
									
INSERT INTO ModifierArguments 	(ModifierId, 						Name,					Value) 
VALUES 							('OCC_MOD_THE_CARDINAL_LEVEL_0', 	'Amount',				5),
								('OCC_MOD_THE_CARDINAL_LEVEL_0', 	'GreatPersonClassType',	'GREAT_PERSON_CLASS_PROPHET'),
								('OCC_MOD_THE_CARDINAL_LEVEL_1', 	'Amount',				1),
								('OCC_MOD_THE_CARDINAL_LEVEL_1', 	'YieldType',			'YIELD_CULTURE'),
								('OCC_MOD_THE_CARDINAL_LEVEL_2', 	'Amount',				25),
								('OCC_MOD_THE_CARDINAL_LEVEL_2', 	'YieldType',			'YIELD_FAITH'),
								('OCC_MOD_THE_CARDINAL_LEVEL_3', 	'Amount',				200);				

-- Fat Liang GOVERNOR_THE_BUILDER
DELETE FROM GovernorsCannotAssign
WHERE GovernorType = 'GOVERNOR_THE_BUILDER';

INSERT INTO GovernorsCannotAssign (GovernorType, CannotAssign) VALUES ('GOVERNOR_THE_BUILDER', 1);

DELETE FROM GovernorPromotionSets
WHERE GovernorType = 'GOVERNOR_THE_BUILDER';

INSERT INTO Types (Type, Kind) VALUES ('THE_BUILDER_LEVEL_0', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_BUILDER_LEVEL_1', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_BUILDER_LEVEL_2', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_BUILDER_LEVEL_3', 'KIND_GOVERNOR_PROMOTION');

INSERT INTO GovernorPromotionSets	(GovernorType, 						GovernorPromotion)
VALUES  							('GOVERNOR_THE_BUILDER',			'THE_BUILDER_LEVEL_0'), 
									('GOVERNOR_THE_BUILDER',			'THE_BUILDER_LEVEL_1'), 
									('GOVERNOR_THE_BUILDER',			'THE_BUILDER_LEVEL_2'), 
									('GOVERNOR_THE_BUILDER',			'THE_BUILDER_LEVEL_3'); 

INSERT INTO GovernorPromotions		(GovernorPromotionType, 			Name,								Description,						Level,	Column,	BaseAbility)
VALUES  							('THE_BUILDER_LEVEL_0',				'OCC_THE_BUILDER_LEVEL_0_NAME',		'OCC_THE_BUILDER_LEVEL_0_DESC',	0,		1,		1),
									('THE_BUILDER_LEVEL_1',				'OCC_THE_BUILDER_LEVEL_1_NAME',		'OCC_THE_BUILDER_LEVEL_1_DESC',	1,		1,		0),
									('THE_BUILDER_LEVEL_2',				'OCC_THE_BUILDER_LEVEL_2_NAME',		'OCC_THE_BUILDER_LEVEL_2_DESC',	1,		1,		0),
									('THE_BUILDER_LEVEL_3',				'OCC_THE_BUILDER_LEVEL_3_NAME',		'OCC_THE_BUILDER_LEVEL_3_DESC',	1,		1,		0);
									
INSERT INTO GovernorPromotionPrereqs	(GovernorPromotionType, 			PrereqGovernorPromotion)
VALUES  								('THE_BUILDER_LEVEL_1',			'THE_BUILDER_LEVEL_0'),
										('THE_BUILDER_LEVEL_2',			'THE_BUILDER_LEVEL_1'),
										('THE_BUILDER_LEVEL_3',			'THE_BUILDER_LEVEL_2');

INSERT INTO GovernorPromotionConditions	(GovernorPromotionType, 			HiddenWithoutPrereqs,	EarliestGameEra)
VALUES  								('THE_BUILDER_LEVEL_0',			0,						NULL),
										('THE_BUILDER_LEVEL_1',			1,						'ERA_MEDIEVAL'),
										('THE_BUILDER_LEVEL_2',			1,						'ERA_INDUSTRIAL'),
										('THE_BUILDER_LEVEL_3',			1,						'ERA_ATOMIC');

INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_BUILDER_LEVEL_0', 'OCC_MOD_THE_BUILDER_LEVEL_0');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_BUILDER_LEVEL_1', 'OCC_MOD_THE_BUILDER_LEVEL_1');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_BUILDER_LEVEL_2', 'OCC_MOD_THE_BUILDER_LEVEL_2');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_BUILDER_LEVEL_3', 'OCC_MOD_THE_BUILDER_LEVEL_3');

INSERT INTO Modifiers 	(ModifierId, 						ModifierType,													OwnerRequirementSetId,	SubjectRequirementSetId) 
VALUES 					('OCC_MOD_THE_BUILDER_LEVEL_0', 	'MODIFIER_PLAYER_CAPITAL_CITY_ADJUST_CITY_YIELD_CHANGE',		NULL,					NULL),	
						('OCC_MOD_THE_BUILDER_LEVEL_1', 	'MODIFIER_PLAYER_CITIES_ADJUST_DISTRICT_PRODUCTION_MODIFIER',	NULL,					NULL),	
						('OCC_MOD_THE_BUILDER_LEVEL_2', 	'MODIFIER_PLAYER_ADJUST_VALID_IMPROVEMENT',						NULL,					NULL),	
						('OCC_MOD_THE_BUILDER_LEVEL_3', 	'MODIFIER_PLAYER_CAPITAL_CITY_ADJUST_CITY_YIELD_CHANGE',		NULL,					NULL);							
									
INSERT INTO ModifierArguments 	(ModifierId, 						Name,					Value) 
VALUES 							('OCC_MOD_THE_BUILDER_LEVEL_0', 	'Amount',				5),
								('OCC_MOD_THE_BUILDER_LEVEL_0', 	'YieldType',			'YIELD_FOOD'),
								('OCC_MOD_THE_BUILDER_LEVEL_1', 	'Amount',				25),
								('OCC_MOD_THE_BUILDER_LEVEL_2', 	'ImprovementType',		'IMPROVEMENT_CITY_PARK'),
								('OCC_MOD_THE_BUILDER_LEVEL_3', 	'YieldType',			'YIELD_FOOD'),
								('OCC_MOD_THE_BUILDER_LEVEL_3', 	'Amount',				25);	

-- Reyna GOVERNOR_THE_MERCHANT	
DELETE FROM GovernorsCannotAssign
WHERE GovernorType = 'GOVERNOR_THE_MERCHANT';

INSERT INTO GovernorsCannotAssign (GovernorType, CannotAssign) VALUES ('GOVERNOR_THE_MERCHANT', 1);

DELETE FROM GovernorPromotionSets
WHERE GovernorType = 'GOVERNOR_THE_MERCHANT';

INSERT INTO Types (Type, Kind) VALUES ('THE_MERCHANT_LEVEL_0', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_MERCHANT_LEVEL_1', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_MERCHANT_LEVEL_2', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_MERCHANT_LEVEL_3', 'KIND_GOVERNOR_PROMOTION');

INSERT INTO GovernorPromotionSets	(GovernorType, 						GovernorPromotion)
VALUES  							('GOVERNOR_THE_MERCHANT',			'THE_MERCHANT_LEVEL_0'), 
									('GOVERNOR_THE_MERCHANT',			'THE_MERCHANT_LEVEL_1'), 
									('GOVERNOR_THE_MERCHANT',			'THE_MERCHANT_LEVEL_2'), 
									('GOVERNOR_THE_MERCHANT',			'THE_MERCHANT_LEVEL_3'); 

INSERT INTO GovernorPromotions		(GovernorPromotionType, 			Name,								Description,						Level,	Column,	BaseAbility)
VALUES  							('THE_MERCHANT_LEVEL_0',				'OCC_THE_MERCHANT_LEVEL_0_NAME',		'OCC_THE_MERCHANT_LEVEL_0_DESC',	0,		1,		1),
									('THE_MERCHANT_LEVEL_1',				'OCC_THE_MERCHANT_LEVEL_1_NAME',		'OCC_THE_MERCHANT_LEVEL_1_DESC',	1,		1,		0),
									('THE_MERCHANT_LEVEL_2',				'OCC_THE_MERCHANT_LEVEL_2_NAME',		'OCC_THE_MERCHANT_LEVEL_2_DESC',	1,		1,		0),
									('THE_MERCHANT_LEVEL_3',				'OCC_THE_MERCHANT_LEVEL_3_NAME',		'OCC_THE_MERCHANT_LEVEL_3_DESC',	1,		1,		0);
									
INSERT INTO GovernorPromotionPrereqs	(GovernorPromotionType, 			PrereqGovernorPromotion)
VALUES  								('THE_MERCHANT_LEVEL_1',			'THE_MERCHANT_LEVEL_0'),
										('THE_MERCHANT_LEVEL_2',			'THE_MERCHANT_LEVEL_1'),
										('THE_MERCHANT_LEVEL_3',			'THE_MERCHANT_LEVEL_2');

INSERT INTO GovernorPromotionConditions	(GovernorPromotionType, 			HiddenWithoutPrereqs,	EarliestGameEra)
VALUES  								('THE_MERCHANT_LEVEL_0',			0,						NULL),
										('THE_MERCHANT_LEVEL_1',			1,						'ERA_MEDIEVAL'),
										('THE_MERCHANT_LEVEL_2',			1,						'ERA_INDUSTRIAL'),
										('THE_MERCHANT_LEVEL_3',			1,						'ERA_ATOMIC');

INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_MERCHANT_LEVEL_0', 'OCC_MOD_THE_MERCHANT_LEVEL_0');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_MERCHANT_LEVEL_1', 'OCC_MOD_THE_MERCHANT_LEVEL_1A');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_MERCHANT_LEVEL_1', 'OCC_MOD_THE_MERCHANT_LEVEL_1B');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_MERCHANT_LEVEL_2', 'OCC_MOD_THE_MERCHANT_LEVEL_2');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_MERCHANT_LEVEL_3', 'OCC_MOD_THE_MERCHANT_LEVEL_3');

INSERT INTO Modifiers 	(ModifierId, 						ModifierType,															OwnerRequirementSetId,	SubjectRequirementSetId) 
VALUES 					('OCC_MOD_THE_MERCHANT_LEVEL_0', 	'MODIFIER_PLAYER_CAPITAL_CITY_ADJUST_CITY_YIELD_CHANGE',				NULL,					NULL),	
						('OCC_MOD_THE_MERCHANT_LEVEL_1A', 	'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD',								NULL,					NULL),	
						('OCC_MOD_THE_MERCHANT_LEVEL_1B', 	'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD',								NULL,					NULL),	
						('OCC_MOD_THE_MERCHANT_LEVEL_2', 	'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_MODIFIER',						NULL,					'DISTRICT_IS_COMMERCIAL_HUB'),	
						('OCC_MOD_THE_MERCHANT_LEVEL_3', 	'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS',		NULL,					'DISTRICT_IS_COMMERCIAL_HUB');							
									
INSERT INTO ModifierArguments 	(ModifierId, 						Name,					Value) 
VALUES 							('OCC_MOD_THE_MERCHANT_LEVEL_0', 	'Amount',				7),
								('OCC_MOD_THE_MERCHANT_LEVEL_0', 	'YieldType',			'YIELD_GOLD'),
								('OCC_MOD_THE_MERCHANT_LEVEL_1A', 	'Amount',				5),
								('OCC_MOD_THE_MERCHANT_LEVEL_1A', 	'YieldType',			'YIELD_GOLD'),
								('OCC_MOD_THE_MERCHANT_LEVEL_1B', 	'Amount',				2),
								('OCC_MOD_THE_MERCHANT_LEVEL_1B', 	'YieldType',			'YIELD_SCIENCE'),
								('OCC_MOD_THE_MERCHANT_LEVEL_2', 	'Amount',				150),
								('OCC_MOD_THE_MERCHANT_LEVEL_2', 	'YieldType',			'YIELD_GOLD'),
								('OCC_MOD_THE_MERCHANT_LEVEL_3', 	'YieldTypeToMirror',	'YIELD_GOLD'),
								('OCC_MOD_THE_MERCHANT_LEVEL_3', 	'YieldTypeToGrant',		'YIELD_SCIENCE');							
								
-- Magnus GOVERNOR_THE_RESOURCE_MANAGER		
DELETE FROM GovernorsCannotAssign
WHERE GovernorType = 'GOVERNOR_THE_RESOURCE_MANAGER';

INSERT INTO GovernorsCannotAssign (GovernorType, CannotAssign) VALUES ('GOVERNOR_THE_RESOURCE_MANAGER', 1);

DELETE FROM GovernorPromotionSets
WHERE GovernorType = 'GOVERNOR_THE_RESOURCE_MANAGER';

INSERT INTO Types (Type, Kind) VALUES ('THE_RESOURCE_MANAGER_LEVEL_0', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_RESOURCE_MANAGER_LEVEL_1', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_RESOURCE_MANAGER_LEVEL_2', 'KIND_GOVERNOR_PROMOTION');
INSERT INTO Types (Type, Kind) VALUES ('THE_RESOURCE_MANAGER_LEVEL_3', 'KIND_GOVERNOR_PROMOTION');

INSERT INTO GovernorPromotionSets	(GovernorType, 						GovernorPromotion)
VALUES  							('GOVERNOR_THE_RESOURCE_MANAGER',			'THE_RESOURCE_MANAGER_LEVEL_0'), 
									('GOVERNOR_THE_RESOURCE_MANAGER',			'THE_RESOURCE_MANAGER_LEVEL_1'), 
									('GOVERNOR_THE_RESOURCE_MANAGER',			'THE_RESOURCE_MANAGER_LEVEL_2'), 
									('GOVERNOR_THE_RESOURCE_MANAGER',			'THE_RESOURCE_MANAGER_LEVEL_3'); 

INSERT INTO GovernorPromotions		(GovernorPromotionType, 			Name,								Description,						Level,	Column,	BaseAbility)
VALUES  							('THE_RESOURCE_MANAGER_LEVEL_0',				'OCC_THE_RESOURCE_MANAGER_LEVEL_0_NAME',		'OCC_THE_RESOURCE_MANAGER_LEVEL_0_DESC',	0,		1,		1),
									('THE_RESOURCE_MANAGER_LEVEL_1',				'OCC_THE_RESOURCE_MANAGER_LEVEL_1_NAME',		'OCC_THE_RESOURCE_MANAGER_LEVEL_1_DESC',	1,		1,		0),
									('THE_RESOURCE_MANAGER_LEVEL_2',				'OCC_THE_RESOURCE_MANAGER_LEVEL_2_NAME',		'OCC_THE_RESOURCE_MANAGER_LEVEL_2_DESC',	1,		1,		0),
									('THE_RESOURCE_MANAGER_LEVEL_3',				'OCC_THE_RESOURCE_MANAGER_LEVEL_3_NAME',		'OCC_THE_RESOURCE_MANAGER_LEVEL_3_DESC',	1,		1,		0);
									
INSERT INTO GovernorPromotionPrereqs	(GovernorPromotionType, 			PrereqGovernorPromotion)
VALUES  								('THE_RESOURCE_MANAGER_LEVEL_1',			'THE_RESOURCE_MANAGER_LEVEL_0'),
										('THE_RESOURCE_MANAGER_LEVEL_2',			'THE_RESOURCE_MANAGER_LEVEL_1'),
										('THE_RESOURCE_MANAGER_LEVEL_3',			'THE_RESOURCE_MANAGER_LEVEL_2');

INSERT INTO GovernorPromotionConditions	(GovernorPromotionType, 			HiddenWithoutPrereqs,	EarliestGameEra)
VALUES  								('THE_RESOURCE_MANAGER_LEVEL_0',			0,						NULL),
										('THE_RESOURCE_MANAGER_LEVEL_1',			1,						'ERA_MEDIEVAL'),
										('THE_RESOURCE_MANAGER_LEVEL_2',			1,						'ERA_INDUSTRIAL'),
										('THE_RESOURCE_MANAGER_LEVEL_3',			1,						'ERA_ATOMIC');

INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_RESOURCE_MANAGER_LEVEL_0', 'OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_0');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_RESOURCE_MANAGER_LEVEL_1', 'OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1A');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_RESOURCE_MANAGER_LEVEL_1', 'OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1B');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_RESOURCE_MANAGER_LEVEL_2', 'OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_2');
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) VALUES ('THE_RESOURCE_MANAGER_LEVEL_3', 'OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_3');

INSERT INTO Modifiers 	(ModifierId, 						ModifierType,															OwnerRequirementSetId,	SubjectRequirementSetId) 
VALUES 					('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_0', 	'MODIFIER_PLAYER_CAPITAL_CITY_ADJUST_CITY_YIELD_CHANGE',				NULL,					NULL),	
						('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1A', 	'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD',								NULL,					NULL),	
						('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1B', 	'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD',								NULL,					NULL),	
						('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_2', 	'MODIFIER_PLAYER_ADJUST_PLOT_YIELD',									NULL,					NULL),	
						('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_3', 	'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER',					NULL,					NULL);							
									
INSERT INTO ModifierArguments 	(ModifierId, 						Name,					Value) 
VALUES 							('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_0', 	'Amount',				4),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_0', 	'YieldType',			'YIELD_PRODUCTION'),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1A', 	'Amount',				3),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1A', 	'YieldType',			'YIELD_FOOD'),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1B', 	'Amount',				3),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_1B', 	'YieldType',			'YIELD_PRODUCTION'),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_2', 	'Amount',				1),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_2', 	'YieldType',			'YIELD_PRODUCTION'),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_3', 	'Amount',				50),
								('OCC_MOD_THE_RESOURCE_MANAGER_LEVEL_3', 	'YieldType',			'YIELD_PRODUCTION');							
--

UPDATE Eras SET StartingDefenseUnits = StartingDefenseUnits - 1;

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_SCOUT', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_AMERICA'		,
	'CIVILIZATION_MONGOLIA'		,
	'CIVILIZATION_SHOSHONE'		,
	'CIVILIZATION_SONGHAI'		,
	'CIVILIZATION_ZULU'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_TRIREME', 'UNITAI_EXPLORE_SEA', 1, Type 
	'CIVILIZATION_GERMANY'		,
	'CIVILIZATION_MONGOLIA'		,
	'CIVILIZATION_SHOSHONE' 
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_TRIREME', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_CARTHAGE'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_ARCHER', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_BABYLON'		,
	'CIVILIZATION_INCA'			,
	'CIVILIZATION_MAYA'			
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_SPEARMAN', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_CELTS'		,
	'CIVILIZATION_GREECE'		,
	'CIVILIZATION_PERSIA'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_WORKER', 'UNITAI_WORKER', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_INDIA'		,
	'CIVILIZATION_KOREA'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_WARRIOR', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_ARABIA'		,
	'CIVILIZATION_AUSTRIA'		,
	'CIVILIZATION_ASSYRIA'		,
	'CIVILIZATION_BRAZIL'		,
	'CIVILIZATION_BYZANTIUM'	,
	'CIVILIZATION_CARTHAGE'		,
	'CIVILIZATION_CHINA'		,
	'CIVILIZATION_DENMARK'		,
	'CIVILIZATION_ENGLAND'		,
	'CIVILIZATION_ETHIOPIA'		,
	'CIVILIZATION_FRANCE'		,
	'CIVILIZATION_GERMANY'		,
	'CIVILIZATION_INDONESIA'	,
	'CIVILIZATION_JAPAN'		,
	'CIVILIZATION_MOROCCO'		,
	'CIVILIZATION_NETHERLANDS'	,
	'CIVILIZATION_OTTOMAN'		,
	'CIVILIZATION_POLAND'		,
	'CIVILIZATION_POLYNESIA'	,
	'CIVILIZATION_PORTUGAL'		,
	'CIVILIZATION_RUSSIA'		,
	'CIVILIZATION_SIAM'			,
	'CIVILIZATION_SPAIN'		,
	'CIVILIZATION_SWEDEN'		,
	'CIVILIZATION_VENICE'		,
	'CIVILIZATION_ZULU'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_ARCHER', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_BABYLON'		,
	'CIVILIZATION_INCA'			,
	'CIVILIZATION_MAYA'			,
	'CIVILIZATION_SONGHAI'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_SPEARMAN', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_CELTS'		,
	'CIVILIZATION_GREECE'		,
	'CIVILIZATION_PERSIA'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_CHARIOT_ARCHER', 'UNITAI_EXPLORE', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_EGYPT'		,
	'CIVILIZATION_HUNS'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_WORKER', 'UNITAI_WORKER', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_INDIA'		,
	'CIVILIZATION_KOREA'
);

INSERT INTO Civilization_FreeUnits (UnitClassType, UnitAIType, Count, CivilizationType)
SELECT 'UNITCLASS_GREAT_GENERAL', 'UNITAI_GENERAL', 1, Type 
FROM Civilizations WHERE Type IN (
	'CIVILIZATION_CHINA'
);

UPDATE LoadedFile SET Value=1 WHERE Type='CEL_Start.sql';
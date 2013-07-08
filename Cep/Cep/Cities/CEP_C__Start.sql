--


--
-- Global Mods
--


UPDATE Units SET Cost = ROUND((Cost * 1.2) / 10, 0) * 10  WHERE Cost > 0;

UPDATE Units
SET HurryCostModifier = 50
WHERE (Combat > 0 OR RangedCombat > 0) AND HurryCostModifier >= 0;

UPDATE Units
SET HurryCostModifier = -1
WHERE Special = 'SPECIALUNIT_PEOPLE'
AND NOT CombatClass = 'UNITCOMBAT_DIPLOMACY';


UPDATE Buildings
SET Cost = ROUND((Cost * 1.2) / 10, 0) * 10
WHERE Cost > 0 AND NOT BuildingClass IN (
	SELECT Type FROM BuildingClasses
	WHERE (
		MaxGlobalInstances = 1
		OR MaxTeamInstances = 1
		OR MaxPlayerInstances = 1
	)
);

UPDATE Buildings
SET Cost = ROUND((Cost * 1.2) / 10, 0) * 10
WHERE Cost > 0 AND BuildingClass IN (
	SELECT Type FROM BuildingClasses
	WHERE (
		MaxGlobalInstances = 1
		OR MaxTeamInstances = 1
		OR MaxPlayerInstances = 1
	)
);

UPDATE Projects
SET Cost = Cost * 1.2
WHERE Cost > 0;

UPDATE Buildings
SET Cost = 100, NumCityCostMod = 25
WHERE NumCityCostMod > 0;

UPDATE Buildings
SET HurryCostModifier = 0
WHERE HurryCostModifier > 0;

UPDATE Buildings
SET HurryCostModifier = 50
WHERE BuildingClass IN (
	'BUILDINGCLASS_WALLS',
	'BUILDINGCLASS_CASTLE',
	'BUILDINGCLASS_ARSENAL',
	'BUILDINGCLASS_MILITARY_BASE'
);


--
-- Happiness
--

UPDATE Buildings
SET Happiness = Happiness + 1
WHERE BuildingClass IN (
	'BUILDINGCLASS_COLOSSEUM'
);

UPDATE Buildings
SET UnmoddedHappiness = UnmoddedHappiness + 1
WHERE BuildingClass IN (
	'BUILDINGCLASS_THEATRE',
	'BUILDINGCLASS_STADIUM'
);

UPDATE LoadedFile SET Value=1 WHERE Type='GEC_Start.sql';
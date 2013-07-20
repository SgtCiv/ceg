/*

You can change most options in this file at any time, unless indicated otherwise.
Changes take effect the next time you start or load a game with Communitas.

For example, if you are using the "Citystate Diplomacy" mod change the lines that read:

	INSERT INTO CEP (Type, Value)
	VALUES ('USING_CSD', 0);

...change to...

	INSERT INTO CEP (Type, Value)
	VALUES ('USING_CSD', 1);

Then start a new game.

*/



-------------
-- Options --
-------------

/*
-- LANGUAGE --

Set your language.
The text defaults to English when the English version is more recent than the local language.

Code	Language	 
-----	--------
DE_DE	Deutsch			German
EN_US	English			English (US)
ES_ES	Espanol			Spanish
FR_FR	Francais		French
IT_IT	Italiano		Italian
JA_JP	Nihongo			Japanese
PL_PL	Polski			Polish
RU_RU	Russkij Jazyk	Russian
ZH_CN	Zhongwen		Chinese

*/
INSERT INTO Cep (Type, Value) VALUES ('LANGUAGE', 'EN_US');


/*
CityState Diplomacy Mod Compatibility
1 = using CSD and CEP
0 = not using CSD and CEP
*/
INSERT INTO CEP (Type, Value) VALUES ('USING_CSD', 0);
INSERT INTO CEP (Type, Value) VALUES ('DISABLE_GOLD_GIFTS', 0);


/*
Good For

These show the "good for" value of objects on their tooltips.
This is helpful for people new to the game or analyzing balance.

1 = show Good For
0 = hide Good For
*/

INSERT INTO Cep (Type, Value) VALUES ('SHOW_GOOD_FOR_UNITS',		1);
INSERT INTO Cep (Type, Value) VALUES ('SHOW_GOOD_FOR_BUILDINGS',	1);
INSERT INTO Cep (Type, Value) VALUES ('SHOW_GOOD_FOR_POLICIES',		1);
INSERT INTO Cep (Type, Value) VALUES ('SHOW_GOOD_FOR_TECHS',		1);
INSERT INTO Cep (Type, Value) VALUES ('SHOW_GOOD_FOR_BUILDS',		1);

INSERT INTO Cep (Type, Value) VALUES ('SHOW_GOOD_FOR_RAW_NUMBERS',	0);
INSERT INTO Cep (Type, Value) VALUES ('SHOW_GOOD_FOR_AI_NUMBERS',	0);


/*
Barbarians Upgrade
1 = barbarians upgrade in camps
0 = barbarians do not upgrade 
*/
INSERT INTO Cep (Type, Value)
VALUES ('BARBARIANS_UPGRADE', 1);


/*
Barbarians Heal
1 = barbarians heal when fortified
0 = barbarians do not heal
*/
INSERT INTO Cep (Type, Value)
VALUES ('BARBARIANS_HEAL', 1);


/*
Speech
1 = play speech
0 = silence speech
*/
INSERT INTO Cep (Type, Value) VALUES ('PLAY_SPEECH_START'		, 0);
INSERT INTO Cep (Type, Value) VALUES ('PLAY_SPEECH_WONDERS'		, 1);
INSERT INTO Cep (Type, Value) VALUES ('PLAY_SPEECH_TECHS'		, 1);


/*
Human-vs-barbarian combat bonus.
*/
UPDATE HandicapInfos SET BarbarianBonus = 150 WHERE Type = 'HANDICAP_SETTLER';
UPDATE HandicapInfos SET BarbarianBonus =  50 WHERE Type = 'HANDICAP_CHIEFTAIN';
UPDATE HandicapInfos SET BarbarianBonus =  20 WHERE Type = 'HANDICAP_WARLORD';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_PRINCE';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_KING';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_EMPEROR';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_IMMORTAL';
UPDATE HandicapInfos SET BarbarianBonus =  15 WHERE Type = 'HANDICAP_DEITY';

UPDATE Defines SET Value = 60 WHERE Name = 'BARBARIAN_MAX_XP_VALUE';


/*
Minimum distance (in tiles) between cities.
*/
UPDATE Defines
SET Value = 2
WHERE Name = 'MIN_CITY_RANGE';


/*
Delay between each line of scrolling text after combat.
*/
UPDATE Defines
SET Value = 0.6
WHERE Name = 'POST_COMBAT_TEXT_DELAY';


/*
Unit Movement Animation Duration
The animation time required for a unit to visually move between tiles.
The default CEP values are 50% of vanilla (half duration = twice as fast).
*/
UPDATE MovementRates SET
TotalTime			= 0.5 * TotalTime,
EaseIn				= 0.5 * EaseIn,
EaseOut				= 0.5 * EaseOut,
IndividualOffset	= 0.5 * IndividualOffset,
RowOffset			= 0.5 * RowOffset;


/*
Aircraft Move Speed
The speed of aircraft movement.
The default CEP values are 400% of vanilla (four times as fast).
*/

UPDATE ArtDefine_UnitMemberCombats
SET MoveRate = 4 * MoveRate;

UPDATE ArtDefine_UnitMemberCombats
SET TurnRateMin = 4 * TurnRateMin
WHERE MoveRate > 0;

UPDATE ArtDefine_UnitMemberCombats
SET TurnRateMax = 4 * TurnRateMax
WHERE MoveRate > 0;

















--
-- Do not change items below

UPDATE Defines SET Value=1 WHERE Name='QUEST_DISABLED_INVEST' AND EXISTS 
(SELECT Value FROM Cep WHERE Type='DISABLE_GOLD_GIFTS' AND Value=1);

UPDATE Civilizations SET DawnOfManAudio = "" WHERE EXISTS 
(SELECT Value FROM Cep WHERE Type='PLAY_SPEECH_START' AND Value=0);

UPDATE Buildings SET WonderSplashAudio = "" WHERE EXISTS 
(SELECT Value FROM Cep WHERE Type='PLAY_SPEECH_WONDERS' AND Value=0);

UPDATE Technologies SET AudioIntroHeader = "" WHERE EXISTS 
(SELECT Value FROM Cep WHERE Type='PLAY_SPEECH_TECHS' AND Value=0);

UPDATE Technologies SET AudioIntro = "" WHERE EXISTS 
(SELECT Value FROM Cep WHERE Type='PLAY_SPEECH_TECHS' AND Value=0);

UPDATE LoadedFile SET Value=1 WHERE Type='CEP_Options.sql';

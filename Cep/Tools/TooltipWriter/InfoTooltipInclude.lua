-------------------------------------------------
-- Help text for Info Objects (Units, Buildings, etc.)
-------------------------------------------------

if Game == nil then
	--print("InfoTooltipInclude.lua: Game == nil")
	return
end

include("ModTools.lua")

-- UNIT
function GetHelpTextForUnit(unitID, bIncludeRequirementsInfo)
	local unitInfo = GameInfo.Units[unitID]
	local unitClassInfo = GameInfo.UnitClasses[unitInfo.Class]
	
	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[Game.GetActiveTeam()]

	local textBody = ""
	local fieldTextKey = ""
	
	-- Name
	local textName = Locale.ConvertTextKey(unitInfo.Description)
	if os.date and (os.date("%d/%m") == "01/04") then
		textName = string.format("%s %s", Locale.ConvertTextKey("TXT_KEY_APRIL_FOOLS"), textName)
	end
	textBody = textBody .. Locale.ToUpper(textName)
	
	-- Pre-written Help text
	if unitInfo.Help then
		local textHeader = Locale.ConvertTextKey( unitInfo.Help )
		if textHeader and textHeader ~= "" then
			textBody = textBody .. "[NEWLINE]----------------"
			textBody = textBody .. "[NEWLINE]" .. textHeader
		end	
	end
	
	-- Value
	textBody = textBody .. "[NEWLINE]----------------"		
	if Cep.SHOW_GOOD_FOR_UNITS == 1 then
		textBody = textBody .. Game.GetFlavors("Unit_Flavors", "UnitType", unitInfo.Type)
	end
	
	
	--
	-- Abilities
	--
	
	textBody = string.format("%s[NEWLINE][NEWLINE]%s", textBody, Locale.ConvertTextKey("TXT_KEY_TOOLTIP_ABILITIES"))
	
	-- Promotions
	local footerRangedStrength	= ""
	local footerStrength		= ""
	local footerMoves			= ""
	local footerEnd				= ""
	for row in GameInfo.Unit_FreePromotions{UnitType = unitInfo.Type} do
		local promoInfo = GameInfo.UnitPromotions[row.PromotionType]
		if promoInfo.Class ~= "PROMOTION_CLASS_ATTRIBUTE_NEGATIVE" then
			local promoText = Locale.ConvertTextKey(promoInfo.Help)	
			if string.find(promoText, "^.ICON_RANGE_STRENGTH") then
				footerRangedStrength = footerRangedStrength .. "[NEWLINE]" .. promoText
			elseif string.find(promoText, ".ICON_STRENGTH.([^%%]*%% vs)") then
				footerStrength = footerStrength .. "[NEWLINE]" .. promoText
				footerRangedStrength = footerRangedStrength .. "[NEWLINE]" .. string.gsub(promoText, ".ICON_STRENGTH.([^%%]*%% vs)", function(x) return "[ICON_RANGE_STRENGTH]"..x end)
			elseif string.find(promoText, "^.ICON_STRENGTH") then
				footerStrength = footerStrength .. "[NEWLINE]" .. promoText
			elseif string.find(promoText, "^.ICON_MOVES") then
				footerMoves = footerMoves .. "[NEWLINE]" .. promoText
			else
				footerEnd = footerEnd .. "[NEWLINE]" .. promoText
			end
		end
	end
	
	-- Range
	local iRange = unitInfo.Range
	if (iRange ~= 0) then
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RANGE", iRange)
	end
	
	-- Ranged Strength
	local iRangedStrength = unitInfo.RangedCombat
	if (iRangedStrength ~= 0) then
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RANGED_STRENGTH", iRangedStrength) .. footerRangedStrength
	end
	
	-- Strength
	local iStrength = unitInfo.Combat
	if (iStrength ~= 0) then
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_STRENGTH", iStrength) .. footerStrength
	end
	
	-- Moves
	textBody = textBody .. "[NEWLINE]"
	textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_MOVEMENT", unitInfo.Moves)
	textBody = textBody .. footerMoves	
	textBody = textBody .. footerEnd
	
	-- Special Abilities
	if unitInfo.WorkRate ~= 0 then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_WORK_RATE", unitInfo.WorkRate)		
	end
	if unitInfo.Found then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_FOUND")		
	end
	if unitInfo.Food then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_FOOD")		
	end
	if unitInfo.SpecialCargo then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_CARGO", "TXT_KEY_" .. unitInfo.SpecialCargo)
	end
	if unitInfo.Suicide then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_SUICIDE")		
	end
	if unitInfo.NukeDamageLevel >= 1 then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_NUKE_RADIUS", unitInfo.NukeDamageLevel)		
	end
	
	-- Replaces
	local defaultObjectType = unitClassInfo.DefaultUnit
	if unitInfo.Type ~= defaultObjectType then
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_BUILDING_EFFECT_REPLACES", GameInfo.Units[defaultObjectType].Description)
	end
	
	
	--
	-- Requirements
	--
	
	textBody = string.format("%s[NEWLINE][NEWLINE]%s", textBody, Locale.ConvertTextKey("TXT_KEY_TOOLTIP_REQUIREMENTS"))
	
	-- Cost
	local cost = activePlayer:GetUnitProductionNeeded(unitID)
	if unitID == GameInfo.Units.UNIT_SETTLER.ID then
		cost = Game.Round(cost * Cep.UNIT_SETTLER_BASE_COST / 105, -1)
	end
	textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_COST", cost)
	
	-- Purchase Cost Multiplier
	local costMultiplier = nil
	if unitInfo.HurryCostModifier ~= -1 then
		costMultiplier = math.pow(cost * GameDefines.GOLD_PURCHASE_GOLD_PER_PRODUCTION, GameDefines.HURRY_GOLD_PRODUCTION_EXPONENT)
		costMultiplier = costMultiplier * (100 + unitInfo.HurryCostModifier)
		costMultiplier = Game.Round(Game.RoundDown(costMultiplier) / cost, -1)
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_HURRY_COST_MODIFIER", costMultiplier, costMultiplier)
	end
	
	-- add help text for how much a new city would cost when looking at a settler
	if (activePlayer.CalcNextCityMaintenance ~= nil) and (unitInfo.Type == "UNIT_SETTLER") and (Unit_GetMaintenance(unitInfo.ID) > 0) then
		textBody = textBody .. "[NEWLINE][NEWLINE]"..Locale.ConvertTextKey("TXT_KEY_NEXT_CITY_SETTLER_MAINTENANCE_TEXT",activePlayer:CalcNextCityMaintenance() or 0)
	end
	
	if Unit_GetMaintenance(unitID) > 0 then
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_MAINTENANCE", Unit_GetMaintenance(unitInfo.ID))
	end
	
	-- Requirements
	if (bIncludeRequirementsInfo) then
		if (unitInfo.Requirements) then
			textBody = textBody .. Locale.ConvertTextKey( unitInfo.Requirements )
		end
	end
	
	if unitInfo.ProjectPrereq then
		local projectName = GameInfo.Projects[unitInfo.ProjectPrereq].Description
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_BUILDING_EFFECT_REQUIRES_BUILDING", projectName)		
	end
	
	-- Tech prerequisites
	fieldTextKey = "TXT_KEY_BUILDING_EFFECT_REQUIRES_BUILDING"
	for pEntry in GameInfo.Unit_TechTypes{UnitType = unitInfo.Type} do
		local entryValue = Locale.ConvertTextKey(GameInfo.Technologies[pEntry.TechType].Description)
		textBody = textBody .. "[NEWLINE]" .. Locale.ConvertTextKey(fieldTextKey, entryValue)
	end
	
	-- Obsolescence
	local pObsolete = unitInfo.ObsoleteTech
	if pObsolete ~= nil and pObsolete ~= "" then
		pObsolete = Locale.ConvertTextKey(GameInfo.Technologies[pObsolete].Description)
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_UNIT_OBSOLETE_TECH", pObsolete)
	end
	
	-- Limit
	local unitLimit = unitClassInfo.MaxPlayerInstances
	if unitLimit ~= -1 then
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_BUILDING_EFFECT_NATIONAL_LIMIT", "", "", unitLimit)
	end
	unitLimit = unitClassInfo.MaxTeamInstances
	if unitLimit ~= -1 then
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_BUILDING_EFFECT_TEAM_LIMIT", "", "", unitLimit)
	end
	unitLimit = unitClassInfo.MaxGlobalInstances
	if unitLimit ~= -1 then
		textBody = textBody .. "[NEWLINE]"
		textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_BUILDING_EFFECT_WORLD_LIMIT", "", "", unitLimit)
	end
	
	-- Resource Requirements
	local iNumResourcesNeededSoFar = 0
	local iNumResourceNeeded
	local iResourceID
	for pResource in GameInfo.Resources() do
		iResourceID = pResource.ID
		iNumResourceNeeded = Game.GetNumResourceRequiredForUnit(unitID, iResourceID)
		if (iNumResourceNeeded > 0) then
			-- First resource required
			if (iNumResourcesNeededSoFar == 0) then
				textBody = textBody .. "[NEWLINE]"
				textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_RESOURCES_REQUIRED")
				textBody = textBody .. " " .. iNumResourceNeeded .. " " .. pResource.IconString .. " " .. Locale.ConvertTextKey(pResource.Description)
			else
				textBody = textBody .. ", " .. iNumResourceNeeded .. " " .. pResource.IconString .. " " .. Locale.ConvertTextKey(pResource.Description)
			end
			
			-- JON: Not using this for now, the formatting is better when everything is on the same line
			--iNumResourcesNeededSoFar = iNumResourcesNeededSoFar + 1
		end
 	end
	
	return textBody	
end

-- BUILDING
function GetHelpTextForBuilding(iBuildingID, bExcludeName, bExcludeHeader, bNoMaintenance, pCity)
	local pBuildingInfo = GameInfo.Buildings[iBuildingID]
	 
	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[Game.GetActiveTeam()]
	
	local buildingClass = GameInfo.Buildings[iBuildingID].BuildingClass
	local buildingClassID = GameInfo.BuildingClasses[buildingClass].ID
	
	local textBody = ""
	
	local lines = {}
	if (not bExcludeHeader) then
		
		if (not bExcludeName) then
			-- Name
			textBody = textBody .. Locale.ToUpper(Locale.ConvertTextKey( pBuildingInfo.Description ))
			textBody = textBody .. "[NEWLINE]----------------[NEWLINE]"
		end
		
		-- Cost
		--Only show cost info if the cost is greater than 0.
		if(pBuildingInfo.Cost > 0) then
			local iCost = activePlayer:GetBuildingProductionNeeded(iBuildingID)
			table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_COST", iCost))
		end
		
		if(pBuildingInfo.UnlockedByLeague and Game.GetNumActiveLeagues() > 0) then
			local pLeague = Game.GetActiveLeague()
			if (pLeague ~= nil) then
				local iCostPerPlayer = pLeague:GetProjectBuildingCostPerPlayer(iBuildingID)
				local sCostPerPlayer = Locale.ConvertTextKey("TXT_KEY_PEDIA_COST_LABEL")
				sCostPerPlayer = sCostPerPlayer .. " " .. Locale.ConvertTextKey("TXT_KEY_LEAGUE_PROJECT_COST_PER_PLAYER", iCostPerPlayer)
				table.insert(lines, sCostPerPlayer)
			end
		end
		
		-- Maintenance
		if (not bNoMaintenance) then
			local iMaintenance = pBuildingInfo.GoldMaintenance
			if (iMaintenance ~= nil and iMaintenance ~= 0) then		
				table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE", iMaintenance))
			end
		end
		
	end
	
	-- Happiness (from all sources)
	local iHappinessTotal = 0
	local iHappiness = pBuildingInfo.Happiness
	if (iHappiness ~= nil) then
		iHappinessTotal = iHappinessTotal + iHappiness
	end
	local iHappiness = pBuildingInfo.UnmoddedHappiness
	if (iHappiness ~= nil) then
		iHappinessTotal = iHappinessTotal + iHappiness
	end
	iHappinessTotal = iHappinessTotal + activePlayer:GetExtraBuildingHappinessFromPolicies(iBuildingID)
	if (pCity ~= nil) then
		iHappinessTotal = iHappinessTotal + pCity:GetReligionBuildingClassHappiness(buildingClassID) + activePlayer:GetPlayerBuildingClassHappiness(buildingClassID)
	end
	if (iHappinessTotal ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_HAPPINESS", iHappinessTotal))
	end
	
	-- Culture
	local iCulture = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_CULTURE)
	if (pCity ~= nil) then
		iCulture = iCulture + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE) + activePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE)
		iCulture = iCulture + pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE)
	end
	if (iCulture ~= nil and iCulture ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_CULTURE", iCulture))
	end

	-- Faith
	local iFaith = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_FAITH)
	if (pCity ~= nil) then
		iFaith = iFaith + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH) + activePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH)
		iFaith = iFaith + pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH)
	end
	if (iFaith ~= nil and iFaith ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_FAITH", iFaith))
	end
	
	-- Defense
	local iDefense = pBuildingInfo.Defense
	if (iDefense ~= nil and iDefense ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_DEFENSE", iDefense / 100))
	end
	
	-- Hit Points
	local iHitPoints = pBuildingInfo.ExtraCityHitPoints
	if (iHitPoints ~= nil and iHitPoints ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_HITPOINTS", iHitPoints))
	end
	
	-- Food
	local iFood = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_FOOD)
	if (pCity ~= nil) then
		iFood = iFood + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD) + activePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD)
		iFood = iFood + pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD)
	end
	if (iFood ~= nil and iFood ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_FOOD", iFood))
	end
	
	-- Gold Mod
	local iGold = Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_GOLD)
	iGold = iGold + activePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_GOLD)
	
	if (iGold ~= nil and iGold ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_GOLD", iGold))
	end
	
	-- Gold Change
	iGold = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_GOLD)
	if (pCity ~= nil) then
		iGold = iGold + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD) + activePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD)
		iGold = iGold + pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD)
	end
	if (iGold ~= nil and iGold ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_GOLD_CHANGE", iGold))
	end
	
	-- Science
	local iScience = Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_SCIENCE)
	iScience = iScience + activePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_SCIENCE)
	if (iScience ~= nil and iScience ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_SCIENCE", iScience))
	end
	
	-- Science
	local iScienceChange = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_SCIENCE) + activePlayer:GetPolicyBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE)
	if (pCity ~= nil) then
		iScienceChange = iScienceChange + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE) + activePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE)
		iScienceChange = iScienceChange + pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE)
	end
	if (iScienceChange ~= nil and iScienceChange ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_SCIENCE_CHANGE", iScienceChange))
	end
	
	-- Production
	local iProduction = Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_PRODUCTION)
	iProduction = iProduction + activePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_PRODUCTION)
	if (iProduction ~= nil and iProduction ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_PRODUCTION", iProduction))
	end

	-- Production Change
	local iProd = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_PRODUCTION)
	if (pCity ~= nil) then
		iProd = iProd + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_PRODUCTION) + activePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_PRODUCTION)
		iProd = iProd + pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_PRODUCTION)
	end
	if (iProd ~= nil and iProd ~= 0) then
		table.insert(lines, Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_PRODUCTION_CHANGE", iProd))
	end
	
	-- Great People
	local specialistType = pBuildingInfo.SpecialistType
	if specialistType ~= nil then
		local iNumPoints = pBuildingInfo.GreatPeopleRateChange
		if (iNumPoints > 0) then
			table.insert(lines, "[ICON_GREAT_PEOPLE] " .. Locale.ConvertTextKey(GameInfo.Specialists[specialistType].GreatPeopleTitle) .. " " .. iNumPoints) 
		
		end
		
		if(pBuildingInfo.SpecialistCount > 0) then
			-- Append a key such as TXT_KEY_SPECIALIST_ARTIST_SLOTS
			local specialistSlotsKey = GameInfo.Specialists[specialistType].Description .. "_SLOTS"
			table.insert(lines, "[ICON_GREAT_PEOPLE] " .. Locale.ConvertTextKey(specialistSlotsKey) .. " " .. pBuildingInfo.SpecialistCount)
		end
	end
	
	local iNumGreatWorks = pBuildingInfo.GreatWorkCount
	if(iNumGreatWorks > 0) then
		local greatWorksSlotType = GameInfo.GreatWorkSlots[pBuildingInfo.GreatWorkSlotType]
		local localizedText = Locale.Lookup(greatWorksSlotType.SlotsToolTipText, iNumGreatWorks)
		table.insert(lines, localizedText)
	end

	if (pCity ~= nil) then
		local iTourism = pCity:GetFaithBuildingTourism()
		if(iTourism > 0 and pBuildingInfo.FaithCost > 0 and pBuildingInfo.UnlockedByBelief and pBuildingInfo.Cost == -1) then
			local localizedText = Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_TOURISM", iTourism)
			table.insert(lines, localizedText)
		end
	end
	
	local iTechEnhancedTourism = pBuildingInfo.TechEnhancedTourism
	local iEnhancingTech = GameInfoTypes[pBuildingInfo.EnhancedYieldTech]
	if(iTechEnhancedTourism > 0 and activeTeam:GetTeamTechs():HasTech(iEnhancingTech)) then
		local localizedText = Locale.ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_TOURISM", iTechEnhancedTourism)
		table.insert(lines, localizedText)
	end	
	
	textBody = textBody .. table.concat(lines, "[NEWLINE]")
	
	-- Pre-written Help text
	if (pBuildingInfo.Help ~= nil) then
		local strWrittenHelpText = Locale.ConvertTextKey( pBuildingInfo.Help )
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			textBody = textBody .. "[NEWLINE]----------------[NEWLINE]"
			textBody = textBody .. strWrittenHelpText
		end
	end
	
	return textBody
	
end


-- IMPROVEMENT
function GetHelpTextForImprovement(iImprovementID, bExcludeName, bExcludeHeader, bNoMaintenance)
	local pImprovementInfo = GameInfo.Improvements[iImprovementID]
	
	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[Game.GetActiveTeam()]
	
	local textBody = ""
	
	if (not bExcludeHeader) then
		
		if (not bExcludeName) then
			-- Name
			textBody = textBody .. Locale.ToUpper(Locale.ConvertTextKey( pImprovementInfo.Description ))
			textBody = textBody .. "[NEWLINE]----------------[NEWLINE]"
		end
				
	end
		
	-- if we end up having a lot of these we may need to add some more stuff here
	
	-- Pre-written Help text
	if (pImprovementInfo.Help ~= nil) then
		local strWrittenHelpText = Locale.ConvertTextKey( pImprovementInfo.Help )
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			-- textBody = textBody .. "[NEWLINE]----------------[NEWLINE]"
			textBody = textBody .. strWrittenHelpText
		end
	end
	
	return textBody
	
end


-- PROJECT
function GetHelpTextForProject(iProjectID, bIncludeRequirementsInfo)
	local pProjectInfo = GameInfo.Projects[iProjectID]
	
	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[Game.GetActiveTeam()]
	
	local textBody = ""
	
	-- Name
	textBody = textBody .. Locale.ToUpper(Locale.ConvertTextKey( pProjectInfo.Description ))
	
	-- Cost
	local iCost = activePlayer:GetProjectProductionNeeded(iProjectID)
	textBody = textBody .. "[NEWLINE]----------------[NEWLINE]"
	textBody = textBody .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_COST", iCost)
	
	-- Pre-written Help text
	local strWrittenHelpText = Locale.ConvertTextKey( pProjectInfo.Help )
	if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
		-- Separator
		textBody = textBody .. "[NEWLINE]----------------[NEWLINE]"
		textBody = textBody .. strWrittenHelpText
	end
	
	-- Requirements?
	if (bIncludeRequirementsInfo) then
		if (pProjectInfo.Requirements) then
			textBody = textBody .. Locale.ConvertTextKey( pProjectInfo.Requirements )
		end
	end
	
	return textBody
	
end


-- PROCESS
function GetHelpTextForProcess(iProcessID, bIncludeRequirementsInfo)
	local pProcessInfo = GameInfo.Processes[iProcessID]
	local activePlayer = Players[Game.GetActivePlayer()]
	local activeTeam = Teams[Game.GetActiveTeam()]
	
	local textBody = ""
	
	-- Name
	textBody = textBody .. Locale.ToUpper(Locale.ConvertTextKey(pProcessInfo.Description))
	
	-- Pre-written Help text
	local strWrittenHelpText = Locale.ConvertTextKey(pProcessInfo.Help)
	if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
		textBody = textBody .. "[NEWLINE]----------------[NEWLINE]"
		textBody = textBody .. strWrittenHelpText
	end
	
	-- League Project text
	local tProject = nil
	for t in GameInfo.LeagueProjects() do
		if (iProcessID == GameInfo.Processes[t.Process].ID) then
			tProject = t
			break
		end
	end
	local pLeague = Game.GetActiveLeague()
	if (tProject ~= nil and pLeague ~= nil) then
		textBody = textBody .. "[NEWLINE][NEWLINE]"
		textBody = textBody .. pLeague:GetProjectDetails(GameInfo.LeagueProjects[tProject.Type].ID, Game.GetActivePlayer())
	end
	
	return textBody
end

-------------------------------------------------
-- Tooltips for Yield & Similar (e.g. Culture)
-------------------------------------------------

-- FOOD
function GetFoodTooltip(pCity)
	
	local iYieldType = YieldTypes.YIELD_FOOD
	local strFoodToolTip = ""
	
	if (not OptionsManager.IsNoBasicHelp()) then
		strFoodToolTip = strFoodToolTip .. Locale.ConvertTextKey("TXT_KEY_FOOD_HELP_INFO")
		strFoodToolTip = strFoodToolTip .. "[NEWLINE][NEWLINE]"
	end
	
	local fFoodProgress = pCity:GetFoodTimes100() / 100
	local iFoodNeeded = pCity:GrowthThreshold()
	
	strFoodToolTip = strFoodToolTip .. Locale.ConvertTextKey("TXT_KEY_FOOD_PROGRESS", fFoodProgress, iFoodNeeded)
	
	strFoodToolTip = strFoodToolTip .. "[NEWLINE][NEWLINE]"
	strFoodToolTip = strFoodToolTip .. GetYieldTooltipHelper(pCity, iYieldType, "[ICON_FOOD]")
	
	return strFoodToolTip
end

-- GOLD
function GetGoldTooltip(pCity)
	
	local iYieldType = YieldTypes.YIELD_GOLD

	local strGoldToolTip = ""
	if (not OptionsManager.IsNoBasicHelp()) then
		strGoldToolTip = strGoldToolTip .. Locale.ConvertTextKey("TXT_KEY_GOLD_HELP_INFO")
		strGoldToolTip = strGoldToolTip .. "[NEWLINE][NEWLINE]"
	end
	
	strGoldToolTip = strGoldToolTip .. GetYieldTooltipHelper(pCity, iYieldType, "[ICON_GOLD]")
	
	return strGoldToolTip
end

-- SCIENCE
function GetScienceTooltip(pCity)
	
	local strScienceToolTip = ""

	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
		strScienceToolTip = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_SCIENCE_OFF_TOOLTIP")
	else

		local iYieldType = YieldTypes.YIELD_SCIENCE
	
		if (not OptionsManager.IsNoBasicHelp()) then
			strScienceToolTip = strScienceToolTip .. Locale.ConvertTextKey("TXT_KEY_SCIENCE_HELP_INFO")
			strScienceToolTip = strScienceToolTip .. "[NEWLINE][NEWLINE]"
		end
	
		strScienceToolTip = strScienceToolTip .. GetYieldTooltipHelper(pCity, iYieldType, "[ICON_RESEARCH]")
	end
	
	return strScienceToolTip
end

-- PRODUCTION
function GetProductionTooltip(pCity)

	local iBaseProductionPT = pCity:GetBaseYieldRate(YieldTypes.YIELD_PRODUCTION)
	local iProductionPerTurn = pCity:GetCurrentProductionDifferenceTimes100(false, false) / 100--pCity:GetYieldRate(YieldTypes.YIELD_PRODUCTION)
	local strCodeToolTip = pCity:GetYieldModifierTooltip(YieldTypes.YIELD_PRODUCTION)
	
	local strProductionBreakdown = GetYieldTooltip(pCity, YieldTypes.YIELD_PRODUCTION, iBaseProductionPT, iProductionPerTurn, "[ICON_PRODUCTION]", strCodeToolTip)
	
	-- Basic explanation of production
	local strProductionHelp = ""
	if (not OptionsManager.IsNoBasicHelp()) then
		strProductionHelp = strProductionHelp .. Locale.ConvertTextKey("TXT_KEY_PRODUCTION_HELP_INFO")
		strProductionHelp = strProductionHelp .. "[NEWLINE][NEWLINE]"
		--Controls.ProductionButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_CITYVIEW_CHANGE_PROD_TT"))
	else
		--Controls.ProductionButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_CITYVIEW_CHANGE_PROD"))
	end
	
	return strProductionHelp .. strProductionBreakdown
end

-- CULTURE
function GetCultureTooltip(pCity)
	
	local strCultureToolTip = ""
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)) then
		strCultureToolTip = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_POLICIES_OFF_TOOLTIP")
	else
		if (not OptionsManager.IsNoBasicHelp()) then
			strCultureToolTip = strCultureToolTip .. Locale.ConvertTextKey("TXT_KEY_CULTURE_HELP_INFO")
			strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]"
		end
		
		local bFirst = true
		
		-- Culture from Buildings
		local iCultureFromBuildings = pCity:GetJONSCulturePerTurnFromBuildings()
		if (iCultureFromBuildings ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_BUILDINGS", iCultureFromBuildings)
		end
		
		-- Culture from Policies
		local iCultureFromPolicies = pCity:GetJONSCulturePerTurnFromPolicies()
		if (iCultureFromPolicies ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_POLICIES", iCultureFromPolicies)
		end
		
		-- Culture from Specialists
		local iCultureFromSpecialists = pCity:GetJONSCulturePerTurnFromSpecialists()
		if (iCultureFromSpecialists ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_SPECIALISTS", iCultureFromSpecialists)
		end
		
		-- Culture from Great Works
		local iCultureFromGreatWorks = pCity:GetJONSCulturePerTurnFromGreatWorks()
		if (iCultureFromGreatWorks ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_GREAT_WORKS", iCultureFromGreatWorks)
		end
		
		-- Culture from Religion
		local iCultureFromReligion = pCity:GetJONSCulturePerTurnFromReligion()
		if ( iCultureFromReligion ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_RELIGION", iCultureFromReligion)
		end
		
		-- Culture from Leagues
		local iCultureFromLeagues = pCity:GetJONSCulturePerTurnFromLeagues()
		if ( iCultureFromLeagues ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_LEAGUES", iCultureFromLeagues)
		end
		
		-- Culture from Terrain
		local iCultureFromTerrain = pCity:GetBaseYieldRateFromTerrain(YieldTypes.YIELD_CULTURE)
		if (iCultureFromTerrain ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_TERRAIN", iCultureFromTerrain)
		end

		-- Culture from Traits
		local iCultureFromTraits = pCity:GetJONSCulturePerTurnFromTraits()
		if (iCultureFromTraits ~= 0) then
			
			-- Spacing
			if (bFirst) then
				bFirst = false
			else
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
			end
			
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_FROM_TRAITS", iCultureFromTraits)
		end
		
		-- Empire Culture modifier
		local iAmount = Players[pCity:GetOwner()]:GetCultureCityModifier()
		if (iAmount ~= 0) then
			strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]"
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_PLAYER_MOD", iAmount)
		end
		
		-- City Culture modifier
		local iAmount = pCity:GetCultureRateModifier()
		if (iAmount ~= 0) then
			strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]"
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_CITY_MOD", iAmount)
		end
		
		-- Culture Wonders modifier
		if (pCity:GetNumWorldWonders() > 0) then
			iAmount = Players[pCity:GetOwner()]:GetCultureWonderMultiplier()
			
			if (iAmount ~= 0) then
				strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]"
				strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_CULTURE_WONDER_BONUS", iAmount)
			end
		end
		
		-- Puppet modifier
		if (pCity:IsPuppet()) then
			iAmount = GameDefines.PUPPET_CULTURE_MODIFIER
			
			if (iAmount ~= 0) then
				strCultureToolTip = strCultureToolTip .. "[NEWLINE]"
				strCultureToolTip = strCultureToolTip .. Locale.ConvertTextKey("TXT_KEY_PRODMOD_PUPPET", iAmount)
			end
		end
	end
	
	
	-- Tile growth
	local iCulturePerTurn = pCity:GetJONSCulturePerTurn()
	local iCultureStored = pCity:GetJONSCultureStored()
	local iCultureNeeded = pCity:GetJONSCultureThreshold()

	strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]"
	strCultureToolTip = strCultureToolTip .. Locale.ConvertTextKey("TXT_KEY_CULTURE_INFO", iCultureStored, iCultureNeeded)
	
	if iCulturePerTurn > 0 then
		local iCultureDiff = iCultureNeeded - iCultureStored
		local iCultureTurns = math.ceil(iCultureDiff / iCulturePerTurn)
		strCultureToolTip = strCultureToolTip .. " " .. Locale.ConvertTextKey("TXT_KEY_CULTURE_TURNS", iCultureTurns)
	end
	
	return strCultureToolTip
end

-- FAITH
function GetFaithTooltip(pCity)
	
	local faithTips = {}
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		table.insert(faithTips, Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP"))
	else

		if (not OptionsManager.IsNoBasicHelp()) then
			table.insert(faithTips, Locale.ConvertTextKey("TXT_KEY_FAITH_HELP_INFO"))
		end
	
		-- Faith from Buildings
		local iFaithFromBuildings = pCity:GetFaithPerTurnFromBuildings()
		if (iFaithFromBuildings ~= 0) then
		
			table.insert(faithTips, "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_FAITH_FROM_BUILDINGS", iFaithFromBuildings))
		end
	
		-- Faith from Traits
		local iFaithFromTraits = pCity:GetFaithPerTurnFromTraits()
		if (iFaithFromTraits ~= 0) then
				
			table.insert(faithTips, "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_FAITH_FROM_TRAITS", iFaithFromTraits))
		end
	
		-- Faith from Terrain
		local iFaithFromTerrain = pCity:GetBaseYieldRateFromTerrain(YieldTypes.YIELD_FAITH)
		if (iFaithFromTerrain ~= 0) then
				
			table.insert(faithTips, "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_FAITH_FROM_TERRAIN", iFaithFromTerrain))
		end

		-- Faith from Policies
		local iFaithFromPolicies = pCity:GetFaithPerTurnFromPolicies()
		if (iFaithFromPolicies ~= 0) then
					
			table.insert(faithTips, "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_FAITH_FROM_POLICIES", iFaithFromPolicies))
		end

		-- Faith from Religion
		local iFaithFromReligion = pCity:GetFaithPerTurnFromReligion()
		if (iFaithFromReligion ~= 0) then
				
			table.insert(faithTips, "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_FAITH_FROM_RELIGION", iFaithFromReligion))
		end
		
		-- Puppet modifier
		if (pCity:IsPuppet()) then
			iAmount = GameDefines.PUPPET_FAITH_MODIFIER
		
			if (iAmount ~= 0) then
				table.insert(faithTips, Locale.ConvertTextKey("TXT_KEY_PRODMOD_PUPPET", iAmount))
			end
		end
	
		-- Citizens breakdown
		table.insert(faithTips, "----------------")

		table.insert(faithTips, GetReligionTooltip(pCity))
	end
	
	local strFaithToolTip = table.concat(faithTips, "[NEWLINE]")
	return strFaithToolTip
end

-- TOURISM
function GetTourismTooltip(pCity)
	return pCity:GetTourismTooltip()
end

-- Yield Tooltip Helper
function GetYieldTooltipHelper(pCity, iYieldType, strIcon)
	
	local strModifiers = ""
	
	-- Base Yield
	local iBaseYield = pCity:GetBaseYieldRate(iYieldType)

	local iYieldPerPop = pCity:GetYieldPerPopTimes100(iYieldType)
	if (iYieldPerPop ~= 0) then
		iYieldPerPop = iYieldPerPop * pCity:GetPopulation()
		iYieldPerPop = iYieldPerPop / 100
		
		iBaseYield = iBaseYield + iYieldPerPop
	end

	-- Total Yield
	local iTotalYield
	
	-- Food is special
	if (iYieldType == YieldTypes.YIELD_FOOD) then
		iTotalYield = pCity:FoodDifferenceTimes100() / 100
	else
		iTotalYield = pCity:GetYieldRateTimes100(iYieldType) / 100
	end
	
	-- Yield modifiers string
	strModifiers = strModifiers .. pCity:GetYieldModifierTooltip(iYieldType)
	
	-- Build tooltip
	local strYieldToolTip = GetYieldTooltip(pCity, iYieldType, iBaseYield, iTotalYield, strIcon, strModifiers)
	
	return strYieldToolTip

end


------------------------------
-- Helper function to build yield tooltip string
function GetYieldTooltip(pCity, iYieldType, iBase, iTotal, strIconString, strModifiersString)
	
	local strYieldBreakdown = ""
	
	-- Base Yield from terrain
	local iYieldFromTerrain = pCity:GetBaseYieldRateFromTerrain(iYieldType)
	if (iYieldFromTerrain ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_TERRAIN", iYieldFromTerrain, strIconString)
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]"
	end
	
	-- Base Yield from Buildings
	local iYieldFromBuildings = pCity:GetBaseYieldRateFromBuildings(iYieldType)
	if (iYieldFromBuildings ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_BUILDINGS", iYieldFromBuildings, strIconString)
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]"
	end
	
	-- Base Yield from Specialists
	local iYieldFromSpecialists = pCity:GetBaseYieldRateFromSpecialists(iYieldType)
	if (iYieldFromSpecialists ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_SPECIALISTS", iYieldFromSpecialists, strIconString)
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]"
	end
	
	-- Base Yield from Misc
	local iYieldFromMisc = pCity:GetBaseYieldRateFromMisc(iYieldType)
	if (iYieldFromMisc ~= 0) then
		if (iYieldType == YieldTypes.YIELD_SCIENCE) then
			strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_POP", iYieldFromMisc, strIconString)
		else
			strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_MISC", iYieldFromMisc, strIconString)
		end
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]"
	end
	
	-- Base Yield from Pop
	local iYieldPerPop = pCity:GetYieldPerPopTimes100(iYieldType)
	if (iYieldPerPop ~= 0) then
		local iYieldFromPop = iYieldPerPop * pCity:GetPopulation()
		iYieldFromPop = iYieldFromPop / 100
		
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_POP_EXTRA", iYieldFromPop, strIconString)
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]"
	end
	
	-- Base Yield from Religion
	local iYieldFromReligion = pCity:GetBaseYieldRateFromReligion(iYieldType)
	if (iYieldFromReligion ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_FROM_RELIGION", iYieldFromReligion, strIconString)
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]"
	end
	
	if (iYieldType == YieldTypes.YIELD_FOOD) then
		local iYieldFromTrade = pCity:GetYieldRate(YieldTypes.YIELD_FOOD, false) - pCity:GetYieldRate(YieldTypes.YIELD_FOOD, true)
		if (iYieldFromTrade ~= 0) then
			strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_FOOD_FROM_TRADE_ROUTES", iYieldFromTrade)
			strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]"
		end
	end
		
	local strExtraBaseString = ""
	
	-- Food eaten by pop
	local iYieldEaten = 0
	if (iYieldType == YieldTypes.YIELD_FOOD) then
		iYieldEaten = pCity:FoodConsumption(true, 0)
		if (iYieldEaten ~= 0) then
			--strModifiers = strModifiers .. "[NEWLINE]"
			--strModifiers = strModifiers .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_YIELD_EATEN_BY_POP", iYieldEaten, "[ICON_FOOD]")
			--strModifiers = strModifiers .. "[NEWLINE]----------------[NEWLINE]"			
			strExtraBaseString = strExtraBaseString .. "   " .. Locale.ConvertTextKey("TXT_KEY_FOOD_USAGE", pCity:GetYieldRate(YieldTypes.YIELD_FOOD, false), iYieldEaten)
			
			local iFoodSurplus = pCity:GetYieldRate(YieldTypes.YIELD_FOOD, false) - iYieldEaten
			iBase = iFoodSurplus
			
			--if (iFoodSurplus >= 0) then
				--strModifiers = strModifiers .. Locale.ConvertTextKey("TXT_KEY_YIELD_AFTER_EATEN", iFoodSurplus, "[ICON_FOOD]")
			--else
				--strModifiers = strModifiers .. Locale.ConvertTextKey("TXT_KEY_YIELD_AFTER_EATEN_NEGATIVE", iFoodSurplus, "[ICON_FOOD]")
			--end
		end
	end
	
	local strTotal
	if (iTotal >= 0) then
		strTotal = Locale.ConvertTextKey("TXT_KEY_YIELD_TOTAL", iTotal, strIconString)
	else
		strTotal = Locale.ConvertTextKey("TXT_KEY_YIELD_TOTAL_NEGATIVE", iTotal, strIconString)
	end
	
	strYieldBreakdown = strYieldBreakdown .. "----------------"
	
	-- Build combined string
	if (iBase ~= iTotal or strExtraBaseString ~= "") then
		local strBase = Locale.ConvertTextKey("TXT_KEY_YIELD_BASE", iBase, strIconString) .. strExtraBaseString
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]" .. strBase
	end
	
	-- Modifiers
	if (strModifiersString ~= "") then
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]----------------" .. strModifiersString .. "[NEWLINE]----------------"
	end
	strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]" .. strTotal
	
	return strYieldBreakdown

end


----------------------------------------------------------------        
-- MOOD INFO
----------------------------------------------------------------        
function GetMoodInfo(iOtherPlayer)
	
	local strInfo = ""
	
	-- Always war!
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_WAR)) then
		return "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_ALWAYS_WAR_TT")
	end
	
	local iActivePlayer = Game.GetActivePlayer()
	local activePlayer = Players[iActivePlayer]
	local activeTeam = Teams[activePlayer:GetTeam()]
	local pOtherPlayer = Players[iOtherPlayer]
	local iOtherTeam = pOtherPlayer:GetTeam()
	local pOtherTeam = Teams[iOtherTeam]
	
	--local iVisibleApproach = Players[iActivePlayer]:GetApproachTowardsUsGuess(iOtherPlayer)
	
	-- At war right now
	--[[if (activeTeam:IsAtWar(iOtherTeam)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_AT_WAR") .. "[NEWLINE]"
		
	-- Not at war right now
	else
		
		-- We've fought before
		if (activePlayer:GetNumWarsFought(iOtherPlayer) > 0) then
			-- They don't appear to be mad
			if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY or 
				iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL) then
				strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PAST_WAR_NEUTRAL") .. "[NEWLINE]"
			-- They aren't happy with us
			else
				strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PAST_WAR_BAD") .. "[NEWLINE]"
			end
		end
	end]]--
		
	-- Neutral things
	--[[if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_AFRAID") .. "[NEWLINE]"
	end]]--
		
	-- Good things
	--[[if (pOtherPlayer:WasResurrectedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_RESURRECTED") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:IsDoF(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DOF") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:IsPlayerDoFwithAnyFriend(iOtherPlayer)) then		-- Human has a mutual friend with the AI
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MUTUAL_DOF") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:IsPlayerDenouncedEnemy(iOtherPlayer)) then		-- Human has denounced an enemy of the AI
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MUTUAL_ENEMY") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:GetNumCiviliansReturnedToMe(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CIVILIANS_RETURNED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherTeam:HasEmbassyAtTeam(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HAS_EMBASSY") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:GetNumTimesIntrigueSharedBy(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SHARED_INTRIGUE") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerForgivenForSpying(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_FORGAVE_FOR_SPYING") .. "[NEWLINE]"
	end]]--
	
	-- Bad things
	--[[if (pOtherPlayer:IsFriendDeclaredWarOnUs(iActivePlayer)) then		-- Human was a friend and declared war on us
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_FRIEND_DECLARED_WAR") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsFriendDenouncedUs(iActivePlayer)) then			-- Human was a friend and denounced us
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_FRIEND_DENOUNCED") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:GetWeDeclaredWarOnFriendCount() > 0) then		-- Human declared war on friends
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DECLARED_WAR_ON_FRIENDS") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:GetWeDenouncedFriendCount() > 0) then			-- Human has denounced his friends
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIENDS") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:GetNumFriendsDenouncedBy() > 0) then			-- Human has been denounced by friends
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_BY_FRIENDS") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:IsDenouncedPlayer(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DENOUNCED_BY_US") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsDenouncedPlayer(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DENOUNCED_BY_THEM") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerDoFwithAnyEnemy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DOF_WITH_ENEMY") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerDenouncedFriend(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIEND") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerNoSettleRequestEverAsked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NO_SETTLE_ASKED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerStopSpyingRequestEverAsked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_STOP_SPYING_ASKED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsDemandEverMade(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_TRADE_DEMAND") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:GetNumTimesRobbedBy(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CAUGHT_STEALING") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:GetNumTimesCultureBombed(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CULTURE_BOMB") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:GetNegativeReligiousConversionPoints(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_RELIGIOUS_CONVERSIONS") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:HasOthersReligionInMostCities(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ADOPTING_MY_RELIGION") .. "[NEWLINE]"
	end]]--
	--[[if (activePlayer:HasOthersReligionInMostCities(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ADOPTING_HIS_RELIGION") .. "[NEWLINE]"
	end]]--
	--[[local myLateGamePolicies = activePlayer:GetLateGamePolicyTree()
	local otherLateGamePolicies = pOtherPlayer:GetLateGamePolicyTree()
	if (myLateGamePolicies ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE and otherLateGamePolicies ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE) then
	    local myPoliciesStr = Locale.ConvertTextKey(GameInfo.PolicyBranchTypes[myLateGamePolicies].Description)
	    print (myPoliciesStr)
		if (myLateGamePolicies == otherLateGamePolicies) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SAME_LATE_POLICY_TREES", myPoliciesStr) .. "[NEWLINE]"
		else
			local otherPoliciesStr = Locale.ConvertTextKey(GameInfo.PolicyBranchTypes[otherLateGamePolicies].Description)
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DIFFERENT_LATE_POLICY_TREES", myPoliciesStr, otherPoliciesStr) .. "[NEWLINE]"
		end
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenMilitaryPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MILITARY_PROMISE") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredMilitaryPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MILITARY_PROMISE_IGNORED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenExpansionPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_EXPANSION_PROMISE") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredExpansionPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_EXPANSION_PROMISE_IGNORED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenBorderPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BORDER_PROMISE") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredBorderPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BORDER_PROMISE_IGNORED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenAttackCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CITY_STATE_PROMISE") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredAttackCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CITY_STATE_PROMISE_IGNORED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenBullyCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BULLY_CITY_STATE_PROMISE_BROKEN") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredBullyCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_BULLY_CITY_STATE_PROMISE_IGNORED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenSpyPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SPY_PROMISE_BROKEN") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredSpyPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SPY_PROMISE_IGNORED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenNoConvertPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NO_CONVERT_PROMISE_BROKEN") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredNoConvertPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NO_CONVERT_PROMISE_IGNORED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenCoopWarPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_COOP_WAR_PROMISE") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsPlayerRecklessExpander(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_RECKLESS_EXPANDER") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:GetNumRequestsRefused(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_REFUSED_REQUESTS") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:GetRecentTradeValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_TRADE_PARTNER") .. "[NEWLINE]"	
	end]]--
	--[[if (pOtherPlayer:GetCommonFoeValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_COMMON_FOE") .. "[NEWLINE]"	
	end]]--
	--[[if (pOtherPlayer:GetRecentAssistValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ASSISTANCE_TO_THEM") .. "[NEWLINE]"	
	end	]]--
	--[[if (pOtherPlayer:IsLiberatedCapital(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_LIBERATED_CAPITAL") .. "[NEWLINE]"	
	end]]--
	--[[if (pOtherPlayer:IsLiberatedCity(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_LIBERATED_CITY") .. "[NEWLINE]"	
	end	]]--
	--[[if (pOtherPlayer:IsGaveAssistanceTo(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_ASSISTANCE_FROM_THEM") .. "[NEWLINE]"	
	end	]]--	
	--[[if (pOtherPlayer:IsHasPaidTributeTo(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PAID_TRIBUTE") .. "[NEWLINE]"	
	end	]]--
	--[[if (pOtherPlayer:IsNukedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_NUKED") .. "[NEWLINE]"	
	end]]--	
	--[[if (pOtherPlayer:IsCapitalCapturedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_CAPTURED_CAPITAL") .. "[NEWLINE]"	
	end	]]--

	-- Protected Minors
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorKilled(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_KILLED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorAttacked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_ATTACKED") .. "[NEWLINE]"
	end]]--
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorBullied(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_BULLIED") .. "[NEWLINE]"
	end]]--
	
	-- Bullied Minors
	--[[if (pOtherPlayer:IsAngryAboutSidedWithTheirProtectedMinor(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_SIDED_WITH_MINOR") .. "[NEWLINE]"
	end]]--
	
	--local iActualApproach = pOtherPlayer:GetMajorCivApproach(iActivePlayer)
	
	-- MOVED TO LUAPLAYER
	--[[
	-- Bad things we don't want visible if someone is friendly (acting or truthfully)
	if (iVisibleApproach ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY) then-- and
		--iActualApproach ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_DECEPTIVE) then
		if (pOtherPlayer:GetLandDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_LAND_DISPUTE") .. "[NEWLINE]"
		end
		--if (pOtherPlayer:GetVictoryDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			--strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_VICTORY_DISPUTE") .. "[NEWLINE]"
		--end
		if (pOtherPlayer:GetWonderDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_WONDER_DISPUTE") .. "[NEWLINE]"
		end
		if (pOtherPlayer:GetMinorCivDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MINOR_CIV_DISPUTE") .. "[NEWLINE]"
		end
		if (pOtherPlayer:GetWarmongerThreat(iActivePlayer) > ThreatTypes.THREAT_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_WARMONGER_THREAT") .. "[NEWLINE]"
		end
	end
	]]--
	
	local aOpinion = pOtherPlayer:GetOpinionTable(iActivePlayer)
	--local aOpinionList = {}
	for i,v in ipairs(aOpinion) do
		--aOpinionList[i] = "[ICON_BULLET]" .. v .. "[NEWLINE]"
		strInfo = strInfo .. "[ICON_BULLET]" .. v .. "[NEWLINE]"
	end
	--strInfo = table.cat(aOpinionList, "[NEWLINE]")

	--  No specific events - let's see what string we should use
	if (strInfo == "") then
		
		-- Appears Friendly
		if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_FRIENDLY")
		-- Appears Guarded
		elseif (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_GUARDED")
		-- Appears Hostile
		elseif (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_HOSTILE")
		-- Neutral - default string
		else
			strInfo = "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_DIPLO_DEFAULT_STATUS")
		end
	end
	
	-- Remove extra newline off the end if we have one
	if (Locale.EndsWith(strInfo, "[NEWLINE]")) then
		local iNewLength = Locale.Length(strInfo)-9
		strInfo = Locale.Substring(strInfo, 1, iNewLength)
	end
	
	return strInfo
	
end
------------------------------
-- Helper function to build religion tooltip string
function GetReligionTooltip(city)

	local religionToolTip = ""
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		return religionToolTip
	end

	local bFoundAFollower = false
	local eReligion = city:GetReligiousMajority()
	local bFirst = true
	
	if (eReligion >= 0) then
		bFoundAFollower = true
		local religion = GameInfo.Religions[eReligion]
		local strReligion = Locale.ConvertTextKey(Game.GetReligionName(eReligion))
	    local strIcon = religion.IconString
		local strPressure = ""
			
		if (city:IsHolyCityForReligion(eReligion)) then
			if (not bFirst) then
				religionToolTip = religionToolTip .. "[NEWLINE]"
			else
				bFirst = false
			end
			religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_HOLY_CITY_TOOLTIP_LINE", strIcon, strReligion)			
		end

		local iPressure
		local iNumTradeRoutesAddingPressure
		iPressure, iNumTradeRoutesAddingPressure = city:GetPressurePerTurn(eReligion)
		if (iPressure > 0) then
			strPressure = Locale.ConvertTextKey("TXT_KEY_RELIGIOUS_PRESSURE_STRING", math.floor(iPressure/GameDefines["RELIGION_MISSIONARY_PRESSURE_MULTIPLIER"]))
		end
		
		local iFollowers = city:GetNumFollowers(eReligion)			
		if (not bFirst) then
			religionToolTip = religionToolTip .. "[NEWLINE]"
		else
			bFirst = false
		end
		
		--local iNumTradeRoutesAddingPressure = city:GetNumTradeRoutesAddingPressure(eReligion)
		if (iNumTradeRoutesAddingPressure > 0) then
			religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE_WITH_TRADE", strIcon, iFollowers, strPressure, iNumTradeRoutesAddingPressure)
		else
			religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE", strIcon, iFollowers, strPressure)
		end
	end	
		
	local iReligionID
	for pReligion in GameInfo.Religions() do
		iReligionID = pReligion.ID
		
		if (iReligionID >= 0 and iReligionID ~= eReligion and city:GetNumFollowers(iReligionID) > 0) then
			bFoundAFollower = true
			local religion = GameInfo.Religions[iReligionID]
			local strReligion = Locale.ConvertTextKey(Game.GetReligionName(iReligionID))
			local strIcon = religion.IconString
			local strPressure = ""

			if (city:IsHolyCityForReligion(iReligionID)) then
				if (not bFirst) then
					religionToolTip = religionToolTip .. "[NEWLINE]"
				else
					bFirst = false
				end
				religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_HOLY_CITY_TOOLTIP_LINE", strIcon, strReligion)			
			end
				
			local iPressure = city:GetPressurePerTurn(iReligionID)
			if (iPressure > 0) then
				strPressure = Locale.ConvertTextKey("TXT_KEY_RELIGIOUS_PRESSURE_STRING", math.floor(iPressure/GameDefines["RELIGION_MISSIONARY_PRESSURE_MULTIPLIER"]))
			end
			
			local iFollowers = city:GetNumFollowers(iReligionID)			
			if (not bFirst) then
				religionToolTip = religionToolTip .. "[NEWLINE]"
			else
				bFirst = false
			end
			
			local iNumTradeRoutesAddingPressure = city:GetNumTradeRoutesAddingPressure(iReligionID)
			if (iNumTradeRoutesAddingPressure > 0) then
				religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE_WITH_TRADE", strIcon, iFollowers, strPressure, iNumTradeRoutesAddingPressure)
			else
				religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE", strIcon, iFollowers, strPressure)
			end
		end
	end
	
	if (not bFoundAFollower) then
		religionToolTip = religionToolTip .. Locale.ConvertTextKey("TXT_KEY_RELIGION_NO_FOLLOWERS")
	end
		
	return religionToolTip
end
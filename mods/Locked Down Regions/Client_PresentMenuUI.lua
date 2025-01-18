require('string_util');
require('tblprint');
require('ui');
require('version');

function Client_PresentMenuUI(RootParent, setMaxSize, setScrollable, Game, close)
	rootParent = RootParent;
	game = Game;

	if not canRunMod() then
		return close();
	end

	setMaxSize(500, 300);
	refresh(Mod.PublicGameData);
end

function refresh(storage, vert)
	if not UI.IsDestroyed(vert) then
		UI.Destroy(vert);
	end

	vert = Vert(rootParent);

	if game.Game.State ~= WL.GameState.Finished and game.Us and game.Settings.StartedBy == game.Us.ID then
		makeHostMenu(storage, vert);
	else
		-- other players and spectators can see which regions are locked down
		makeNormalMenu(storage, vert);
	end
end

function makeHostMenu(storage, vert)
	local newStorage = storage;

	function updateStorage()
		game.SendGameCustomMessage('Updating...', newStorage, function(storage)
			refresh(storage, vert);
		end);
	end

	if not storage.bonuses then
		newStorage.bonuses = {};

		for bonusId, bonus in pairs(game.Map.Bonuses) do
			table.insert(newStorage.bonuses, bonusId);
		end

		-- sort bonus names A to Z
		table.sort(newStorage.bonuses, function(a, b)
			return game.Map.Bonuses[a].Name < game.Map.Bonuses[b].Name;
		end);

		return updateStorage();
	end
	
	local vert1 = Vert(vert);
	local vert2;
	local addLockedDownRegionBtn = Btn(vert1).SetText('Add locked down region');

	addLockedDownRegionBtn.SetOnClick(function()
		addLockedDownRegionBtn.SetInteractable(false);

		if UI.IsDestroyed(vert2) then
			vert2 = Vert(vert1);
		end

		local bonusHorz = Horz(vert2);
		Label(bonusHorz).SetText('Bonus:');
		local selectBonusBtnContainer = Horz(bonusHorz);
		local selectBonusBtn = Btn(selectBonusBtnContainer).SetText('(none)');
		local selectBonusFromOptionContainer = Horz(bonusHorz);
		local selectBonusFromOption = nil;
		local selectBonusFromListVertContainer = Vert(vert2);
		local selectBonusFromListVert = nil
		local untilTurnHorz = Horz(vert2);
		local errorLabel = Label(vert2).SetColor('#FF0000').SetText('');
		local selectedBonus = nil;
		local turnNo = game.Game.TurnNumber;

		if turnNo < 1 then
			turnNo = 1;
		end

		function selectBonusBtnClicked()
			selectBonusBtn.SetInteractable(false);
			selectedBonus = nil;
			selectBonusBtn.SetText('(select a bonus on the map)');

			errorLabel.SetText('');

			UI.InterceptNextBonusLinkClick(function(selected)
				bonusSelected(selected);
			end)

			if not UI.IsDestroyed(selectBonusFromOption) then
				UI.Destroy(selectBonusFromOption);
			end

			if not UI.IsDestroyed(selectBonusFromListVert) then
				UI.Destroy(selectBonusFromListVert);
			end

			selectBonusFromOption = Horz(selectBonusFromOptionContainer);
			Label(selectBonusFromOption).SetText('or');

			local chooseFromListBtn = Btn(selectBonusFromOption).SetText('choose from a list');

			chooseFromListBtn.SetOnClick(function()
				chooseFromListBtn.SetInteractable(false);
				makeChooseFromListMenu();
			end);
		end

		function makeChooseFromListMenu()
			UI.Destroy(selectBonusBtn);
			selectBonusBtn = Btn(selectBonusBtnContainer).SetText('select');
			selectBonusBtn.SetOnClick(function()
				selectBonusBtnClicked();
				-- for some reason these have to explicitly be done here
				-- even though it should happen fine in the function
				selectBonusBtn.SetInteractable(false);
				selectBonusBtn.SetText('(select a bonus on the map)');
			end);

			selectBonusFromListVert = Vert(selectBonusFromListVertContainer);

			local searchBar = Horz(selectBonusFromListVert);

			Label(searchBar).SetText('Search:');

			local searchFor = TextInput(searchBar).SetFlexibleWidth(1).SetFlexibleHeight(1).SetPreferredWidth(300);

			Label(selectBonusFromListVert).SetText('Search is case-insensitive. Clear the search to view all.');

			local searchBtn = Btn(searchBar).SetText('Go');
			local results = Vert(selectBonusFromListVert);

			function addAllBonuses()
				for _, bonusId in pairs(storage.bonuses) do
					addBonus(bonusId);
				end
			end

			function addBonus(bonusId)
				local bonus = game.Map.Bonuses[bonusId];
				local horz = Horz(results);
				local bonusBtn = Btn(horz).SetText(bonus.Name);
				local viewBonusBtn = Btn(horz).SetText('View').SetOnClick(function()
					game.HighlightTerritories(bonus.Territories);
				end);

				bonusBtn.SetOnClick(function()
					bonusBtn.SetInteractable(false);
					bonusSelected(game.Map.Bonuses[bonusId]);
				end);
			end

			searchBtn.SetOnClick(function()
				searchBtn.SetInteractable(false);
				UI.Destroy(results);
				results = Vert(selectBonusFromListVert);

				local searchingFor = toCaseInsensitivePattern(escapePattern(searchFor.GetText()));
				-- print('searchingFor = ' .. searchingFor);

				if searchingFor == '' then
					searchingFor = '.';
				end

				for _, bonusId in pairs(storage.bonuses) do
					local bonus = game.Map.Bonuses[bonusId];

					if string.find(bonus.Name, searchingFor) then
						addBonus(bonus.ID);
					end
				end

				searchBtn.SetInteractable(true);
			end);

			addAllBonuses();
		end

		function bonusSelected(selected)
			if selected then
				selectBonusBtn.SetText(selected.Name);

				if isValidSelectedBonus(storage, selected.ID) then
					selectedBonus = selected.ID;
				else
					errorLabel.SetText('There is already a region that has some of the same territories of the one you just selected');
					selectedBonus = nil;
				end
			else
				selectedBonus = nil;
				selectBonusBtn.SetText('(none)');
			end

			selectBonusBtn.SetInteractable(true);

			if not UI.IsDestroyed(selectBonusFromOption) then
				UI.Destroy(selectBonusFromOption);
			end

			if not UI.IsDestroyed(selectBonusFromListVert) then
				UI.Destroy(selectBonusFromListVert);
			end
		end

		selectBonusBtn.SetOnClick(function()
			selectBonusBtnClicked();
		end);

		Label(untilTurnHorz).SetText('Locks down until end of turn:');

		local initalValue = newStorage.lastUsedLockdownTurnNo or 0;

		if initalValue < turnNo then
			initalValue = turnNo;
		end

		local turn = NumInput(untilTurnHorz)
			.SetSliderMinValue(turnNo)
			.SetSliderMaxValue(turnNo + 100)
			.SetValue(initalValue);

		Btn(vert2)
			.SetText('Done')
			.SetOnClick(function()	
				local turnValue = turn.GetValue();

				if turnValue < turnNo then
					errorLabel.SetText('Locks down until end of turn must be at least ' .. turnNo);
				elseif selectedBonus then
					newStorage.newLockedDownRegions[selectedBonus] = turnValue;
					newStorage.lastUsedLockdownTurnNo = turnValue;

					updateStorage();
				else
					UI.Destroy(vert2);
					addLockedDownRegionBtn.SetInteractable(true);
				end
			end);
	end);

	Label(vert).SetText('Locked down regions:');

	function displayLockedDownRegions(listName)
		for bonusId, lockedDownUntilTurn in pairs(storage[listName]) do
			if lockedDownUntilTurn + 1 > game.Game.TurnNumber then
				local bonus = game.Map.Bonuses[bonusId];
				local horz = Horz(vert);

				Btn(horz).SetText(bonus.Name).SetOnClick(function()
					game.HighlightTerritories(bonus.Territories);
				end);

				Label(horz).SetText('until end of turn ' .. lockedDownUntilTurn);

				Btn(horz).SetText('Remove').SetOnClick(function()
					if newStorage.lockedDownRegions[bonusId] then
						newStorage.lockedDownRegions[bonusId] = -1;
					end

					newStorage.newLockedDownRegions[bonusId] = nil;
					updateStorage();
				end);
			end
		end
	end

	displayLockedDownRegions('newLockedDownRegions');
	displayLockedDownRegions('lockedDownRegions');
end

function makeNormalMenu(storage, vert)
	local label = Label(vert).SetText('Locked down regions:');
	local hasLockedDownRegions = false;

	for bonusId, lockedDownUntilTurn in pairs(storage.lockedDownRegions) do
		if lockedDownUntilTurn + 1 > game.Game.TurnNumber then
			hasLockedDownRegions = true;
			local bonus = game.Map.Bonuses[bonusId];
			local horz = Horz(vert);

			Btn(horz).SetText(bonus.Name).SetOnClick(function()
				game.HighlightTerritories(bonus.Territories);
			end);

			Label(horz).SetText('until end of turn ' .. lockedDownUntilTurn);
		end
	end

	if not hasLockedDownRegions then
		label.SetText(label.GetText() .. ' (none)');
	end
end

function bonusContainsBonus(bonus1, bonus2)
	-- for any common territories

	if bonus1.ID == bonus2.ID then
		return true;
	end

	for _, terr1 in pairs(bonus1.Territories) do
		for _, terr2 in pairs(bonus2.Territories) do
			if terr1 == terr2 then
				return true;
			end
		end
	end

	return false;
end

function isValidSelectedBonus(storage, selectedId)
	if not selectedId then
		return false;
	end

	local selectedBonus = game.Map.Bonuses[selectedId];

	for bonusId, lockedDownUntilTurn in pairs(storage.lockedDownRegions) do
		if lockedDownUntilTurn + 1 > game.Game.TurnNumber then
			local existingBonus = game.Map.Bonuses[bonusId];

			if bonusContainsBonus(selectedBonus, existingBonus) then
				return false;
			end
		end
	end

	return true;
end

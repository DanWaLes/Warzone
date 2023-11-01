require '_util';
require '_ui';
require 'version';

function Client_PresentMenuUI(RootParent, setMaxSize, setScrollable, Game, close)
	rootParent = RootParent;
	game = Game;

	if (game.Game.State == WL.GameState.Finished) or not canRunMod() then
		return close();
	end

	refresh(Mod.PublicGameData);
end

function refresh(storage, vert)
	if not UI.IsDestroyed(vert) then
		UI.Destroy(vert);
	end

	vert = Vert(rootParent);

	if game.Us and game.Settings.StartedBy == game.Us.ID then
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

	local vert1 = Vert(vert);
	local vert2;

	local addLockedDownRegionBtn = Btn(vert1).SetText('Add locked down region');		
	addLockedDownRegionBtn.SetOnClick(function()
		addLockedDownRegionBtn.SetInteractable(false);

		if UI.IsDestroyed(vert2) then
			vert2 = Vert(vert1);
		end

		local bonusHorz = Horz(vert2);
		local untilTurnHorz = Horz(vert2);
		local errorLabel = Label(vert2).SetColor('#FF0000').SetText('');
		local selectedBonus = nil;
		local turnNo = game.Game.TurnNumber;

		if turnNo < 1 then
			turnNo = 1;
		end

		Label(bonusHorz).SetText('Bonus:');

		local selectBonusBtn = Btn(bonusHorz).SetText('(none)');

		selectBonusBtn.SetOnClick(function()
			selectBonusBtn.SetInteractable(false);
			selectedBonus = nil;
			selectBonusBtn.SetText('(selecting)');
			errorLabel.SetText('');

			UI.InterceptNextBonusLinkClick(function(selected)
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
			end);
		end);

		Label(untilTurnHorz).SetText('Locks down until end of turn:');

		local turn = NumInput(untilTurnHorz)
			.SetSliderMinValue(turnNo)
			.SetSliderMaxValue(turnNo + 100)
			.SetValue(turnNo + 20);

		Btn(vert2)
			.SetText('Done')
			.SetOnClick(function()	
				local turnValue = turn.GetValue();

				if turnValue < turnNo then
					errorLabel.SetText('Locks down until end of turn must be at least ' .. turnNo);
				elseif selectedBonus then
					newStorage.lockedDownRegions[selectedBonus] = turnValue;
					newStorage.newLockedDownRegions[selectedBonus] = turnValue;
					updateStorage();
				else
					UI.Destroy(vert2);
					addLockedDownRegionBtn.SetInteractable(true);
				end
			end);
	end);

	Label(vert).SetText('Locked down regions:');

	for bonusId, lockedDownUntilTurn in pairs(storage.lockedDownRegions) do
		local bonus = game.Map.Bonuses[bonusId];
		local horz = Horz(vert);

		Btn(horz).SetText(bonus.Name).SetOnClick(function()
			game.HighlightTerritories(bonus.Territories);
		end);

		Label(horz).SetText('until end of turn ' .. lockedDownUntilTurn);
		Btn(horz).SetText('Remove').SetOnClick(function()
			newStorage.lockedDownRegions[bonusId] = -1;
			newStorage.newLockedDownRegions[bonusId] = nil;
			updateStorage();
		end);
	end
end

function makeNormalMenu(storage, vert)
	local label = Label(vert).SetText('Locked down regions:');
	local hasLockedDownRegions = false;

	for bonusId, lockedDownUntilTurn in pairs(storage.lockedDownRegions) do
		hasLockedDownRegions = true;
		local bonus = game.Map.Bonuses[bonusId];
		local horz = Horz(vert);

		Btn(horz).SetText(bonus.Name).SetOnClick(function()
			game.HighlightTerritories(bonus.Territories);
		end);

		Label(horz).SetText('until end of turn ' .. lockedDownUntilTurn);
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

	for bonusId in pairs(storage.lockedDownRegions) do
		local existingBonus = game.Map.Bonuses[bonusId];

		if bonusContainsBonus(selectedBonus, existingBonus) then
			return false;
		end
	end

	return true;
end
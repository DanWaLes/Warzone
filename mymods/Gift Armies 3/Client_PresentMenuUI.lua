require '_util';
require '_ui';
require 'version';
require 'armies';

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if not game.Us or game.Us.State ~= WL.GamePlayerState.Playing or not canRunMod() then
		return;
	end

	local vert = Vert(rootParent);

	Label(vert).SetText('Gift armies from');
	local fromBtn = Btn(vert).SetText('(Select territory)');
	local fromError = Label(vert).SetColor('#FF0000').SetText('');

	Label(vert).SetText('Gift armies to');
	local toBtn = Btn(vert).SetText('(Select territory)').SetInteractable(false);
	local toError = Label(vert).SetColor('#FF0000').SetText('');

	Label(vert).SetText('Number of armies');
	local actualArmiesSlider = NumInput(vert).SetValue(0).SetInteractable(false);
	local specialUnitsContainer = Vert(vert);
	local specialUnitsInputs = {};
	local availableSpecialUnits = {}; 

	local doneBtn = Btn(vert).SetText('Done').SetInteractable(false);

	local terrIds = {
		from = nil,
		to = nil
	};

	local armies = nil;

	function terrBtnClicked(btn, errLabel, tpe, callback)
		btn.SetInteractable(false);
		btn.SetText('(Selecting)');

		UI.InterceptNextTerritoryClick(function(terr)
			if not terr then
				errLabel.SetText('');

				if terrIds[tpe] then
					btn.SetText(game.Map.Terriories[terrIds[tpe]].Name);
				else
					btn.SetText('(Select territory)');
					btn.SetInteractable(true);
				end

				return;
			end

			if callback(game.LatestStanding.Territories[terr.ID], terr) then
				errLabel.SetText('');
				terrIds[tpe] = terr.ID;
				btn.SetText(terr.Name);
			else
				btn.SetText('(Select territory)');
				btn.SetInteractable(true);
			end
		end);
	end

	fromBtn.SetOnClick(function()
		terrBtnClicked(fromBtn, fromError, 'from', function(terrStanding, terrDetails)
			if terrStanding.OwnerPlayerID ~= game.Us.ID then
				fromError.SetText('From must be one of your territories');
				return;
			end

			toBtn.SetInteractable(true);
			return true;
		end);
	end);

	toBtn.SetOnClick(function()
		terrBtnClicked(toBtn, toError, 'to', function(terrStanding, terrDetails)
			if not terrDetails.ConnectedTo[terrIds.from] then
				toError.SetText('To must connect to From');
				return;
			end

			if terrStanding.OwnerPlayerID == game.Us.ID then
				toError.SetText('To must not be one of your territories');
				return;
			end

			if terrStanding.OwnerPlayerID == WL.PlayerID.Neutral then
				toError.SetText('To must not be Neutral');
				return;
			end

			makeArmiesSelector();
			doneBtn.SetInteractable(true);
			return true;
		end);
	end);

	function makeArmiesSelector()
		local from = game.LatestStanding.Territories[terrIds.from];

		local minGiftableArmies = game.Settings.OneArmyMustStandGuardOneOrZero;
		local maxGiftableArmies = from.NumArmies.NumArmies - game.Settings.OneArmyMustStandGuardOneOrZero;

		if minGiftableArmies > from.NumArmies.NumArmies then
			minGiftableArmies = 0;
		end

		if maxGiftableArmies < 0 then
			maxGiftableArmies = 0;
		end

		actualArmiesSlider.SetSliderMinValue(minGiftableArmies);
		actualArmiesSlider.SetSliderMaxValue(maxGiftableArmies);
		actualArmiesSlider.SetValue(maxGiftableArmies);

		if maxGiftableArmies > 0 then
			actualArmiesSlider.SetInteractable(true);
		end

		for _, unit in pairs(from.NumArmies.SpecialUnits) do
			if unit.proxyType == 'CustomSpecialUnit' then
				if unit.OwnerID == game.Us.ID and unit.CanBeTransferredToTeammate then
					local checkbox = Checkbox(specialUnitsContainer).SetIsChecked(true);
					checkbox.SetText((unit.IncludeABeforeName and 'A ' or '') .. unit.Name .. ((unit.TextOverHeadOpt and #unit.TextOverHeadOpt > 0) and ' ' .. unit.TextOverHeadOpt or '') .. ' (' .. unit.ImageFilename .. ' from mod ' .. unit.ModID .. ')');

					specialUnitsInputs[unit.ID] = checkbox;
					availableSpecialUnits[unit.ID] = unit;
				end
			end
		end
	end

	doneBtn.SetOnClick(function()
		doneBtn.SetInteractable(false);
		actualArmiesSlider.SetInteractable(false);

		print('about to set armies');
		local armies = WL.Armies.Create(tonumber(actualArmiesSlider.GetValue()));
		print('set armies');

		for unitId, input in pairs(specialUnitsInputs) do
			input.SetInteractable(false);

			if input.GetIsChecked() then
				print('about to add special unit');
				armies = armies.Add(WL.Armies.Create(0, {availableSpecialUnits[unitId]}));
				print('added special unit');
			end
		end

		local terrs = game.Map.Territories;
		local toTerrOwner = game.LatestStanding.Territories[terrIds.to].OwnerPlayerID;
		local message = 'Gift ' .. messagifyArmies(armies) .. ' from ' .. terrs[terrIds.from].Name .. ' to ' .. terrs[terrIds.to].Name;
		local payload = 'giftarmies3_' .. terrIds.from .. '_' .. terrIds.to .. '_' .. toTerrOwner .. '_' .. stringifyArmies(armies);
		local order = WL.GameOrderCustom.Create(game.Us.ID, message, payload, nil, WL.TurnPhase.Attacks);

		print('order = ');
		tblprint(order);

		game.SendGameCustomMessage('Adding Gift Armies 3 order...', {terrId = terrIds.from}, function()
			placeOrderInCorrectPosition(game, order);
			close();
		end);
	end);
end
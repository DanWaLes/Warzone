function Client_PresentMenuUI(game, setMaxSize, setScrollable, game, close)
end

function PlayDoubleTapCard(vert, wz, card)
	local phase = WL.TurnPhase.Attacks;

	CustomCardHelpButton(card, Horz(vert), Vert(vert));

	local vert2 = Vert(vert);
	local vert3;
	local fromTerrDetails;
	local toTerrDetails;

	function clearSelectionMenu()
		if not UI.IsDestroyed(vert3) then
			UI.Destroy(vert3);
		end

		vert3 = Vert(vert2);
	end

	function selectFromTerr()
		local terrValidation = {
			displayTerrSelectionWarning = function(wz, vert)
				Label(vert).SetText('Select a territory to attack/transfer from');
				Label(vert)
					.SetText('You must own the territory at the time of the card being played')
					.SetColor('#FF7D00');
			end,
			isValidTerr = function(terrDetails, wz)
				-- trying to do order validation to make sure card isnt useless can be unpredictable
				-- partly because of playing of other cards by players who arent on the same team
				-- partly because of happening during attacks
				-- so just allow any

				return true;
			end,
			onValidTerr = function(terrDetails)
				fromTerrDetails = terrDetails;
				selectToTerr();
			end
		};

		clearSelectionMenu();
		TerritorySelectionMenu(vert3, terrValidation, wz);
	end

	function selectToTerr()
		local terrValidation = {
			displayTerrSelectionWarning = function(wz, vert)
				local horz = Horz(vert);

				Label(horz).SetText('Issuing attack/transfer from');
				HighlightTerrBtn(wz.game, fromTerrDetails.ID, horz);

				local horz2 = Horz(vert);

				Label(horz2).SetText('Select connected territory to issue attack/transfer to');
			end,
			isValidTerr = function(terrDetails, wz)
				-- must connect to fromTerrDetails
			end,
			onValidTerr = function(terrDetails)
				toTerrDetails = terrDetails;
				enterOrderDetails();
			end,
			onInvalidTerr = function(terrDetails, wz, vert)
				-- TODO
			end
		};

		clearSelectionMenu();
		TerritorySelectionMenu(vert3, terrValidation, wz);
	end

	function enterOrderDetails()
		clearSelectionMenu();

		local attackTransferType = WL.AttackTransferEnum.AttackOrTransfer;
		local attackTeammates = false;

		local attackWithAllNormalArmies = true;
		local attackWithAllSpecialUnitsApartFromCommanders = true;
		local attackWithAbsolutlyAllSpecialUnits = false;
		local maxNormalArmiesAttacking = nil;
		local maxNormalArmiesAttackingIsPercent = false;

		function getModData()
			local ordering = {
				fromTerrDetails.ID,
				toTerrDetails.ID,
				attackTransferType,
				attackTeammates,
				attackWithAllNormalArmies,
				attackWithAllSpecialUnitsApartFromCommanders,
				attackWithAbsolutlyAllSpecialUnits,
				maxNormalArmiesAttacking,
				maxNormalArmiesAttackingIsPercent
			};

			local modData = '';

			for _, item in pairs(ordering) do
				modData = modData .. tostring(item) .. '_';
			end

			-- having trailing _ might be useful if doing character by character processing
			-- when it comes to parsing the mod data
			modData = modData:gsub('_$', '');

			return modData;
		end

		local playCardBtn = Btn(vert3).SetText('Play Card');

		playCardBtn.SetOnClick(function()
			wz.close();

			local msg = 'Play ' .. aAn(card.Name, true) .. ' from ' .. fromTerrDetails.Name .. ' to ' .. toTerrDetails.Name;
			-- TODO add more msg details

			wz.playCard(msg, getModData(), phase);
		end);
	end
end
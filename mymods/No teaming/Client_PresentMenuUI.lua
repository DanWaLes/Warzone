require '_util';
require '_ui';

function Client_PresentMenuUI(RootParent, setMaxSize, setScrollable, Game, close)
	-- print('init Client_PresentMenuUI');

	rootParent = RootParent;
	game = Game;

	if game.Settings.SinglePlayer then
		Label(rootParent).SetText('This mod is designed to only be used in multiplayer games.');
		return;
	end

	if not game.Us then
		Label(rootParent).SetText('You must have joined the game to access the menu of this mod.');
		return;
	end

	if game.Game.State ~= WL.GameState.Playing then
		Label(rootParent).SetText('The menu of this mod can only be accessed after distribution and before the game ends.');
		return;
	end

	makeMenu();
end

function playerIsNotTeamed(player)
	if player.Team == -1 then
		return true;
	end

	return Mod.PubicGameData.teams[player.Team] == 1;
end

function makeMenu(stored, vert)
	-- print('init makeMenu');

	if not stored then
		stored = Mod.PlayerGameData;
	end

	-- tblprint(stored);

	if not UI.IsDestroyed(vert) then
		UI.Destroy(vert);
	end

	vert = Vert(rootParent);

	local weAreHost = game.Us.ID == game.Settings.StartedBy;
	local weAreNotTeamed = 

	if weAreHost and playerIsNotTeamed(game.Us) then
		makeHostMenu(stored, vert);
	elseif weAreHost then
		Label(vert).SetText('You can only use this mod if you are not teamed up with anyone else, otherwise your team would get an unfair advantage by seeing everything.');
	else
		if game.Settings.StartedBy then
			local host = game.Game.Players[game.Settings.StartedBy];

			if playerIsNotTeamed(host) then
				Label(vert).SetText('The host can eliminate any player they like whenever they want. The host also spies on everyone (and neutral depending on Spy Card settings. This to do discourage making alliances in games that are meant to be actual FFAs for example.');
				Label(vert).SetText('If the host abuses this mod, you should avoid joining their games in future.');
			else
				Label(vert).SetText('This mod would allow the host to eliminate players whenever they want and spy on everyone if the host was not in a team themselves.');
			end
		else
			Label(vert).SetText('Nobody can use this mod because the game was created by the Warzone servers.');
		end
	end
end

function makeHostMenu(stored, vert)
	-- print('init makeHostMenu');

	Label(vert).SetText('Eliminate:');

	for playerId in pairs(game.Game.PlayingPlayers) do
		if playerId ~= game.Us.ID then
			displayPlayer(stored, vert, playerId);
		end
	end
end

function displayPlayer(stored, vert, playerId)
	local player = game.Game.PlayingPlayers[playerId];
	local horz = Horz(vert);

	local checkbox = Checkbox(horz)
		.SetText('')
		.SetIsChecked(not not stored.eliminating[playerId]);
	checkbox.SetOnValueChanged(function()
		checkbox.SetInteractable(false);
		game.SendGameCustomMessage('Updating...', {
			toEliminate = playerId,
			shouldEliminate = checkbox.GetIsChecked()
		}, function(newStorage)
			makeMenu(newStorage, vert);
		end);
	end);

	Label(horz)
		.SetText(player.DisplayName(nil, false))
		.SetColor(player.Color.HtmlColor);

	local terrsBtn = Btn(horz).SetText('Territories');
	terrsBtn.SetOnClick(function()
		terrsBtn.SetInteractable(false);
		selectTerritoriesOwnedBy(playerId);
		terrsBtn.SetInteractable(true);
	end);
end

function selectTerritoriesOwnedBy(playerId)
	local terrs = {};

	for terrId, terr in pairs(game.LatestStanding.Territories) do
		if terr.OwnerPlayerID == playerId then
			table.insert(terrs, terrId);
		end
	end

	game.HighlightTerritories(terrs);
end
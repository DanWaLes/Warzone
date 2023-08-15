require 'version';
require '_ui';
require '_settings';
require '_util';

local rootParent = nil;
local game = nil;
local mainVert = nil;
local stored = nil;

function Client_PresentMenuUI(_rootParent, setMaxSize, setScrollable, _game, close)
	game = _game;

	if not game.Us or game.Us.State ~= WL.GamePlayerState.Playing then
		return;
	end

	if not canRunMod() then
		return;
	end

	setMaxSize(400, 200);

	rootParent = _rootParent;
	main({
		PlayerGameData = Mod.PlayerGameData,
		PublicGameData = Mod.PublicGameData
	}, 1);
end

function main(_stored, i)
	if not UI.IsDestroyed(mainVert) then
		UI.Destroy(mainVert);
	end
	mainVert = Vert(rootParent);

	stored = _stored;

	local tabs = {'Cards', 'Preferences'};
	local clicks = {cardsClicked, preferencesClicked}
	local tabData = Tabs(mainVert, Horz, tabs, clicks);
	tabData.tabClicked(tabs[i], clicks[i]);
end

function cardsClicked(tabData)
	local tabs = {};
	for _, cardName in pairs(Mod.PublicGameData.cardNames) do
		if getSetting('Enable' .. cardName) then
			table.insert(tabs, cardName);
		end
	end

	local clicks = {};
	for _, cardName in pairs(tabs) do
		table.insert(clicks, function(tabData2)
			cardNameClicked(tabData2, cardName);
		end);
	end

	local tabData2 = Tabs(tabData.tabContents, Vert, tabs, clicks);
	tabData2.tabClicked(tabs[1], clicks[1]);
end

function cardNameClicked(tabData, cardName)
	-- cant know for sure how much cards each player has used

	local piecesInCard = getSetting(cardName .. 'PiecesInCard');
	local teamType = game.Us.Team == -1 and 'noTeam' or 'teammed';
	local teamId = game.Us.Team == -1 and game.Us.ID or game.Us.Team;
	local myPieces = Mod.PublicGameData.cardPieces[teamType][teamId].currentPieces[cardName];

	Label(tabData.tabContents).SetText('Whole cards: ' .. math.floor(myPieces / piecesInCard));
	Label(tabData.tabContents).SetText('Pieces: ' .. (myPieces % piecesInCard));

	-- https://stackoverflow.com/questions/1791234/lua-call-function-from-a-string-with-function-name
	local fnName = 'useCard' .. string.gsub(cardName, '[^%w_]', '');
	local btn = Btn(tabData.tabContents).SetText('Use card');
	local vert = Vert(tabData.tabContents);

	btn.SetOnClick(function()
		_G[fnName](tabData, cardName, btn, vert, nil, {});
	end);

	local isBuyable = getSetting(cardName .. 'IsBuyable') and game.Settings.CommerceGame;

	if isBuyable then
		local cost = getSetting(cardName .. 'Cost');
		local btn = Btn(tabData.tabContents);

		btn.SetText('Buy a whole card for ' .. cost .. ' gold');
		btn.SetOnClick(function()
			local msg = 'Buy a ' .. cardName .. ' Card';
			local payload = 'CCP2_buyCard_' .. game.Us.ID .. '_<' .. cardName .. '=[]>';
			local costOpt = {[WL.ResourceType.Gold] = cost};
			local order = WL.GameOrderCustom.Create(game.Us.ID, msg, payload, costOpt);

			placeOrderInCorrectPosition(game, order);
		end);
	end
end

function createSelectTerritoryMenu(parent, selectedTerr, newTerrSelectedCallback)
	local selectTerritoryHorz = Horz(parent);
	Label(selectTerritoryHorz).SetText('Selected: ');
	local selectTerritoryBtn = Btn(selectTerritoryHorz);
	selectTerritoryBtn.SetText(selectedTerr and selectedTerr.Name or 'None');
	selectTerritoryBtn.SetOnClick(function()
		selectTerritoryBtn.SetText('(Selecting)');
		selectTerritoryBtn.SetInteractable(false);

		local isCanceled = false;
		local cancelBtn = Btn(selectTerritoryHorz);
		cancelBtn.SetText('Cancel');
		cancelBtn.SetOnClick(function()
			isCanceled = true;
			UI.Destroy(cancelBtn);
			selectTerritoryBtn.SetText(selectedTerr and selectedTerr.Name or 'None');
			selectTerritoryBtn.SetInteractable(true);
		end);

		UI.InterceptNextTerritoryClick(function(terrDetails)
			if isCanceled then
				return WL.CancelClickIntercept;
			end

			UI.Destroy(cancelBtn);
			selectTerritoryBtn.SetText(terrDetails and terrDetails.Name or 'None');
			selectTerritoryBtn.SetInteractable(true);
			newTerrSelectedCallback(terrDetails);
		end);
	end);
end

function useCardReconnaissance(tabData, cardName, btn, vert, vert2, data)
	btn.SetInteractable(false);

	if not UI.IsDestroyed(vert2) then
		UI.Destroy(vert2);
	end

	local vert2 = Vert(vert);

	Label(vert2).SetText('Select a territory that you want to play a ' .. cardName .. ' Card on');
	createSelectTerritoryMenu(vert2, data.selectedTerr, function(selectedTerr)
		data.selectedTerr = selectedTerr;
		useCardReconnaissance(tabData, cardName, btn, vert, vert2, data);
	end);

	local horz = Horz(vert2);
	local doneBtn = Btn(horz);
	local cancelBtn = Btn(horz);

	doneBtn.SetText('Done');
	doneBtn.SetOnClick(function()
		if not data.selectedTerr then
			return;
		end

		local playerId = game.Us.ID;
		local msg = 'Play ' .. cardName .. ' Card on ' .. data.selectedTerr.Name;
		local payload = 'CCP2_useCard_' .. playerId .. '_<' .. cardName .. '=[' .. data.selectedTerr.ID .. ']>';
		local order = WL.GameOrderCustom.Create(playerId, msg, payload, nil, WL.TurnPhase.SpyingCards);

		placeOrderInCorrectPosition(game, order);
		tabData.clickTab(cardName);
	end);

	cancelBtn.SetText('Cancel');
	cancelBtn.SetOnClick(function()
		tabData.clickTab(cardName);
	end);
end

function preferencesClicked(tabData)
	local preferences = {
		prefShowReceivedCardsMsg = 'Show received cards dialog'
	};

	for pref, label in pairs(preferences) do
		Label(tabData.tabContents).SetText(label .. ': ');
		local btn = Btn(tabData.tabContents);
		btn.SetText(tostring(stored.PlayerGameData[pref]))
		btn.SetOnClick(function()
			btn.SetInteractable(false);

			game.SendGameCustomMessage('Updating preferences...', {
				PlayerGameData = {
					[pref] = not stored.PlayerGameData[pref]
				}
			}, function(_stored)
				main(_stored, 2);
			end);
		end);
	end
end
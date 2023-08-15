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
	local tabData = Tabs(mainVert, tabs, clicks);
	tabData.tabClicked(tabs[i], clicks[i]);
end

function cardsClicked(tabData)
	-- need to list who used which card
	-- need to be able to buy cards

	local teamType = game.Us.Team == -1 and 'noTeam' or 'teammed';
	local teamId = game.Us.Team == -1 and game.Us.ID or game.Us.Team;

	local tbl = Table(tabData.tabContents);
	tbl.Td(1, 1, 'Card name');
	tbl.Td(1, 2, 'Whole cards');
	tbl.Td(1, 3, 'Pieces');
	tbl.Td(1, 4, 'Use card');

	if game.Settings.CommerceGame then
		tbl.Td(1, 5, 'Buy card');
	end

	local rowNo = 2;
	for _, cardName in pairs(Mod.PublicGameData.cardNames) do
		local piecesInCard = getSetting(cardName .. 'PiecesInCard');
		local myPieces = Mod.PublicGameData.cardPieces[teamType][teamId].currentPieces[cardName];

		tbl.Td(rowNo, 1, cardName);
		tbl.Td(rowNo, 2, math.floor(myPieces / piecesInCard));
		tbl.Td(rowNo, 3, myPieces % piecesInCard);
		tbl.Td(rowNo, 4, 'useCard');
		tbl.Td(rowNo, 5, 'buy card');

		rowNo = rowNo + 1;
	end

	-- Label(tabData.tabContents).SetText('cardsClicked');
	-- just for testing add a play card order
	-- local playerId = game.Us.ID;
	-- local terrId = nil;
	-- for tId in pairs(game.Map.Territories) do
		-- terrId = tId;
		-- break;
	-- end
	-- local order = WL.GameOrderCustom.Create(playerId, 'Play Recon+ Card', 'CCP2_useCard_' .. playerId .. '_<Reconnaissance+=[' .. terrId .. ']>', nil, WL.TurnPhase.SpyingCards);
	-- placeOrderInCorrectPosition(game, order);
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
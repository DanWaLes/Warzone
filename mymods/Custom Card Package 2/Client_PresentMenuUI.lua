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
	Label(tabData.tabContents).SetText('cardsClicked todo');
	-- need to display full cards and card pieces for each card
	-- need a play card button for full cards
	-- need to list who used which card
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
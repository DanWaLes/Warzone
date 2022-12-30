require 'ui'

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	local playerIsPlaying = (game.Us ~= nil) and (game.Us.State == WL.GamePlayerState.Playing);
	local distributionOver = game.Game.TurnNumber > 0;

	if not playerIsPlaying or not distributionOver then
		return;
	end

	local WIDTH = 400;
	local HEIGHT = 250;
	setMaxSize(WIDTH, HEIGHT);

	local vert = Vert(rootParent);
	local uiElements = {
		vert = vert
	};

	makeMenu(game, uiElements, Mod.PublicGameData.votes, nil);
end

function makeMenu(game, uiElements, votes)
	local container = Vert(uiElements.vert);
	local vtfBtn = Btn(container);
	local votesList = Vert(container);
	local hasVoted = votes[game.Us.ID];

	function destroyContainer()
		if not UI.IsDestroyed(container) then
			print('this line is needed');
			UI.Destroy(container);
		end
	end

	if hasVoted then
		vtfBtn.SetText('Un-vote to decide random winner');
		vtfBtn.SetOnClick(function()
			UI.Destroy(container);
			game.SendGameCustomMessage('Un-voting...', {vote = false}, function(votes)
				destroyContainer();
				makeMenu(game, uiElements, votes);
			end);
		end);
	else
		vtfBtn.SetText('Vote to decide random winner');
		vtfBtn.SetOnClick(function()
			UI.Destroy(container);
			game.SendGameCustomMessage('Voting...', {vote = true}, function(votes)
				destroyContainer();
				makeMenu(game, uiElements, votes);
			end);
		end);
	end

	local playersVoted = nil;

	for playerId, voted in pairs(votes) do
		local player = game.Game.Players[playerId];
		if not player.IsAIOrHumanTurnedIntoAI and player.State == WL.GamePlayerState.Playing then
			if voted then
				local name = player.DisplayName(nil, false);

				if playersVoted then
					playersVoted = playersVoted .. ', ' .. name;
				else
					playersVoted = name;
				end
			end
		end
	end

	if playersVoted then
		Label(votesList).SetText('The following players have voted to decide a random winner: ' .. playersVoted);
	else
		Label(votesList).SetText('Nobody has voted to decide a random winner');
	end
end

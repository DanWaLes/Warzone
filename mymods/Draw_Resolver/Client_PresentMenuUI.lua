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

	makeMenu(game, uiElements, Mod.PublicGameData.votes, close);
end

function makeMenu(game, uiElements, votes, close)
	local container = Vert(uiElements.vert);
	local vtfContainer = Vert(container);
	local vtfBtn = Btn(vtfContainer);
	local votesList = Vert(vtfContainer);
	local votesContainer = Vert(container);

	local hasVoted = votes[game.Us.ID];

	if hasVoted then
		vtfBtn.SetText('Un-vote to decide a random winner');
		vtfBtn.SetOnClick(function()
			close();
			game.SendGameCustomMessage('Un-voting...', {vote = false}, function() end);
		end);
	else
		vtfBtn.SetText('Vote to decided a random winner');
		vtfBtn.SetOnClick(function()
			close();
			game.SendGameCustomMessage('Voting...', {vote = true}, function() end);
		end);
	end

	Label(votesContainer).SetText('The following players have voted to decide a random winner:');

	for playerId, voted in pairs(votes) do
		local player = game.Game.Players[playerId];

		if player.State == WL.GamePlayerState.Playing and (votes[playerId] or player.IsAIOrHumanTurnedIntoAI) then
			Label(votesContainer).SetText(player.DisplayName(nil, true));
		end
	end
end
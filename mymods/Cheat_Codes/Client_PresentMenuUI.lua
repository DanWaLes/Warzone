require 'ui'

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(400,250);

	local playerIsPlaying = (game.Us ~= nil) and (game.Us.State == WL.GamePlayerState.Playing);
    local distributionOver = game.Game.TurnNumber > 0;

	if not playerIsPlaying or not distributionOver then
		return;
	end

	local vert = Vert(rootParent);
	local guessHorz = Horz(vert);

	UI.CreateLabel(guessHorz).SetText('Guess cheat code');

	local guessedCheatCodeInput = UI.CreateTextInputField(guessHorz)
		.SetPreferredWidth(40)
		.SetCharacterLimit(Mod.Settings.CheatCodeLength)
		.SetPlaceholderText('0000');

	local submitCheatCodeGuessBtn = UI.CreateButton(guessHorz);

	UI.CreateLabel(vert).SetText('You are allowed to make up to ' .. Mod.Settings.CheatCodeGuessesPerTurn .. ' guesses per turn');

	local guessesList = UI.CreateLabel(vert);

	function submitCheatCodeGuessBtnClicked()
		submitCheatCodeGuessBtn.SetInteractable(false);

		game.SendGameCustomMessage('Submitting guess...', {guess = guessedCheatCodeInput.GetText()}, updateGuessesUsedThisTurn);
	end

	function updateGuessesUsedThisTurn()
		submitCheatCodeGuessBtn.SetInteractable(false);

		local guessNo = #Mod.PlayerGameData.guessesSentThisTurn + 1;

		if guessNo < Mod.Settings.CheatCodeGuessesPerTurn then
			submitCheatCodeGuessBtn.SetInteractable(true);
			submitCheatCodeGuessBtn.SetText('Send guess #' .. guessNo);
		else
			if not UI.IsDestroyed(guessHorz) then
				UI.Destroy(guessHorz);
			end

			if runOutOfGuessesLabel then
				return;
			end

			runOutOfGuessesLabel = UI.CreateLabel(vert).SetText('You have used all your guesses for this turn');
		end

		populateGuessesList();
	end

	function populateGuessesList()
		local guesses = Mod.PlayerGameData.guessesSentThisTurn;
		local str = '';

		for i, guess in pairs(guesses) do
			str = str .. guess;

			if i < #guesses then
				str = str .. ', ';
			end
		end

		print('all client guesses = ' .. str);
	end

	--submitCheatCodeGuessBtnClicked();
	-- somehow the button label isnt correct if the 'fake click' isnt called first
	updateGuessesUsedThisTurn();
	submitCheatCodeGuessBtn.SetOnClick(submitCheatCodeGuessBtnClicked);

	if #Mod.PlayerGameData.solvedCheatCodes < 1 then
		return;
	end

	UI.CreateLabel(vert).SetText('Use cheat code:');

	local useCodeHorz = Horz(vert);

	for cheatCode in pairs(Mod.PlayerGameData.solvedCheatCodes) do
		local useCheatCodeBtn = UI.CreateButton(useCodeHorz)
			.SetText(cheatCode)
			.SetOnClick(function()
				useCheatCodeBtn.SetInteractable(false);
				-- todo send msg to server
			end);
	end
end
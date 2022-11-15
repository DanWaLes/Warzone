require 'ui'
require 'util'

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(400, 250);

	local playerIsPlaying = (game.Us ~= nil) and (game.Us.State == WL.GamePlayerState.Playing);
    local distributionOver = game.Game.TurnNumber > 0;

	if not playerIsPlaying or not distributionOver then
		return;
	end

	local vert = Vert(rootParent);
	local guessHorz = Horz(vert);

	UI.CreateLabel(guessHorz).SetText('Guess cheat code');

	local guessedCheatCodeInput = UI.CreateTextInputField(guessHorz)
		.SetPreferredWidth(Mod.Settings.CheatCodeLength * 10 + 10)
		.SetCharacterLimit(Mod.Settings.CheatCodeLength)
		.SetPlaceholderText(generateCheatCodePlaceholderText());

	local submitCheatCodeGuessBtn = UI.CreateButton(guessHorz);

	UI.CreateLabel(vert).SetText('You are allowed to make up to ' .. Mod.Settings.CheatCodeGuessesPerTurn .. ' guesses per turn');

	local invalidGuess = UI.CreateLabel(vert).SetColor('#FF0000');
	local guessesList = UI.CreateLabel(vert);
	local ranOutOfGuessesLabel;

	function submitCheatCodeGuessBtnClicked()
		invalidGuess.SetText('');
		submitCheatCodeGuessBtn.SetInteractable(false);

		local guess = guessedCheatCodeInput.GetText();
		local isValidGuess = string.len(guess) == Mod.Settings.CheatCodeLength and not string.match(guess, '[^%d]');
		-- https://www.lua.org/pil/20.2.html

		if isValidGuess then
			game.SendGameCustomMessage('Submitting guess...', {guess = guess}, updateGuessesUsedThisTurn);
		else
			invalidGuess.SetText(guess .. ' is not a valid cheat code');
			submitCheatCodeGuessBtn.SetInteractable(true);
		end
	end

	function updateGuessesUsedThisTurn(guesses)
		submitCheatCodeGuessBtn.SetInteractable(false);

		local guessNo = #guesses + 1;

		if guessNo < Mod.Settings.CheatCodeGuessesPerTurn + 1 then
			submitCheatCodeGuessBtn.SetInteractable(true);
			submitCheatCodeGuessBtn.SetText('Send guess #' .. guessNo);
		else
			if not UI.IsDestroyed(guessHorz) then
				UI.Destroy(guessHorz);
			end

			if ranOutOfGuessesLabel then
				return;
			end

			ranOutOfGuessesLabel = UI.CreateLabel(vert).SetText('You have used all your guesses for this turn');
		end

		guessesList.SetText('Guesses: ' .. arrayToStrList(guesses));
	end

	updateGuessesUsedThisTurn(Mod.PlayerGameData.guessesSentThisTurn);
	submitCheatCodeGuessBtn.SetOnClick(submitCheatCodeGuessBtnClicked);

	if not Mod.PlayerGameData.solvedCheatCodes then
		-- print('no solved cheat codes');
		return;
	end

	UI.CreateLabel(vert).SetText('Use cheat code:');

	local useCodeHorz = Horz(vert);

	for cheatCode, _ in pairs(Mod.PlayerGameData.solvedCheatCodes) do
		local useCheatCodeBtn = UI.CreateButton(useCodeHorz)
			.SetText(cheatCode);
		local useCheatCodeBtnClicked = function()
			useCheatCodeBtn.SetInteractable(false);
			game.SendGameCustomMessage('Acknowledging cheat code usage ...', {useCode = cheatCode}, function() end);
		end;

		useCheatCodeBtn.SetOnClick(useCheatCodeBtnClicked);
	end
end

function generateCheatCodePlaceholderText()
	local placeholder = '';
	local i = 0;

	while true do
		if i == Mod.Settings.CheatCodeLength then
			break;
		end

		placeholder = placeholder .. i;
		i = i + 1;
	end

	return placeholder;
end
require 'ui'
require 'util'

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	local playerIsPlaying = (game.Us ~= nil) and (game.Us.State == WL.GamePlayerState.Playing);
    local distributionOver = game.Game.TurnNumber > 0;

	if not playerIsPlaying or not distributionOver then
		return;
	end

	local WIDTH = 400;
	local HEIGHT = 250;
	setMaxSize(WIDTH, HEIGHT);
	local CHEAT_CODE_SIZE = Mod.Settings.CheatCodeLength * 10 + 10;

	local vert = Vert(rootParent);
	local guessVert = Vert(vert);

	UI.CreateLabel(guessVert).SetText('Enter cheat code');
	local guessHorz = Horz(guessVert);

	local guessedCheatCodeInput = UI.CreateTextInputField(guessHorz)
		.SetPreferredWidth(CHEAT_CODE_SIZE)
		.SetCharacterLimit(Mod.Settings.CheatCodeLength)
		.SetPlaceholderText(generateCheatCodePlaceholderText());

	local submitCheatCodeGuessBtn = UI.CreateButton(guessHorz);
	local invalidGuess = UI.CreateLabel(guessVert).SetColor('#FF0000');
	local ranOutOfGuessesLabel = UI.CreateLabel(vert).SetText('');
	local guessesList = UI.CreateLabel(vert);
	local unlockedAllCodesLabel;

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

		if tbllen(Mod.PlayerGameData.solvedCheatCodes) == Mod.PublicGameData.numCheatCodes then
			if not UI.IsDestroyed(guessVert) then
				UI.Destroy(guessVert);
			end
			if not UI.IsDestroyed(ranOutOfGuessesLabel) then
				UI.Destroy(ranOutOfGuessesLabel);
			end

			if unlockedAllCodesLabel then
				return
			end

			unlockedAllCodesLabel = UI.CreateLabel(vert).SetText('You have solved all the cheat codes!');
		else
			local guessNo = #guesses + 1;

			if guessNo < Mod.Settings.CheatCodeGuessesPerTurn + 1 then
				submitCheatCodeGuessBtn.SetInteractable(true);
				submitCheatCodeGuessBtn.SetText('Send guess #' .. guessNo);
			else
				if not UI.IsDestroyed(guessVert) then
					UI.Destroy(guessVert);
				end

				if ranOutOfGuessesLabel.GetText() ~= '' then
					return;
				end

				ranOutOfGuessesLabel.SetText('You have used all your guesses for this turn');
			end

			guessesList.SetText('Guesses: ' .. arrayToStrList(guesses));
		end
	end

	updateGuessesUsedThisTurn(Mod.PlayerGameData.guessesSentThisTurn);
	submitCheatCodeGuessBtn.SetOnClick(submitCheatCodeGuessBtnClicked);

	if not Mod.PlayerGameData.solvedCheatCodes then
		-- print('no solved cheat codes');
		return;
	end

	UI.CreateLabel(vert).SetText('Use cheat code:');

	local MAX_BTNS_PER_ROW = math.floor(WIDTH / CHEAT_CODE_SIZE) - 1;
	local i = MAX_BTNS_PER_ROW;
	local currentHorz;

	for cheatCode, _ in pairs(Mod.PlayerGameData.solvedCheatCodes) do
		if i == MAX_BTNS_PER_ROW then
			currentHorz = Horz(vert);
			i = 0;
		end

		local useCheatCodeBtn = UI.CreateButton(currentHorz)
			.SetText(cheatCode);
		local useCheatCodeBtnClicked = function()
			useCheatCodeBtn.SetInteractable(false);
			game.SendGameCustomMessage('Acknowledging cheat code usage ...', {useCode = cheatCode}, function() end);
		end;

		useCheatCodeBtn.SetOnClick(useCheatCodeBtnClicked);

		i = i + 1;
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
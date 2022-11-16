require 'ui'
require 'util'

local SendGameCustomMessage;
local deleteGuessBtnsContainer;

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	local playerIsPlaying = (game.Us ~= nil) and (game.Us.State == WL.GamePlayerState.Playing);
    local distributionOver = game.Game.TurnNumber > 0;

	if not playerIsPlaying or not distributionOver then
		return;
	end

	SendGameCustomMessage = game.SendGameCustomMessage;
	local WIDTH = 400;
	local HEIGHT = 250;
	setMaxSize(WIDTH, HEIGHT);
	local CHEAT_CODE_SIZE = Mod.Settings.CheatCodeLength * 10 + 12;
	local MAX_BTNS_PER_ROW = math.ceil(WIDTH / CHEAT_CODE_SIZE);

	makeMenu(rootParent, Mod.PlayerGameData.guessesSentThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
end

function makeMenu(rootParent, guessesSentThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
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
	local guessesListVert = Vert(vert);
	UI.CreateLabel(guessesListVert).SetText('Guesses: (click guess to delete it)');
	local unlockedAllCodesLabel = UI.CreateLabel(vert).SetText('');

	local uiElements = {
		rootParent = rootParent,
		vert = vert,
		guessVert = guessVert,
		invalidGuess = invalidGuess,
		guessedCheatCodeInput = guessedCheatCodeInput,
		submitCheatCodeGuessBtn = submitCheatCodeGuessBtn,
		ranOutOfGuessesLabel = ranOutOfGuessesLabel,
		guessesListVert = guessesListVert,
		unlockedAllCodesLabel = unlockedAllCodesLabel
	};
	
	updateGuessesUsedThisTurn(uiElements, guessesSentThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);

	submitCheatCodeGuessBtn.SetOnClick(function()
		submitCheatCodeGuessBtnClicked(uiElements, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
	end);

	makeUseCheatCodeBtns(vert);
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

function submitCheatCodeGuessBtnClicked(uiElements, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
	uiElements.invalidGuess.SetText('');
	uiElements.submitCheatCodeGuessBtn.SetInteractable(false);

	local guess = uiElements.guessedCheatCodeInput.GetText();
	local isValidGuess = string.len(guess) == Mod.Settings.CheatCodeLength and not string.match(guess, '[^%d]');
	-- https://www.lua.org/pil/20.2.html

	if isValidGuess then
		local sentGuessIndex = indexOf(Mod.PlayerGameData.guessesSentThisTurn, guess);
		local hasSolvedIndex = indexOf(Mod.PlayerGameData.solvedCheatCodes, guess);

		if sentGuessIndex == -1 and hasSolvedIndex > -1 then
			SendGameCustomMessage('Submitting guess...', {guess = guess}, function(guesses)
				uiElements.guessedCheatCodeInput.SetText('');
				updateGuessesUsedThisTurn(uiElements, guesses, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
			end);
		else
			uiElements.invalidGuess.SetText('You have already guessed ' .. guess);
			uiElements.submitCheatCodeGuessBtn.SetInteractable(true);
		end
	else
		uiElements.invalidGuess.SetText(guess .. ' is not a valid cheat code');
		uiElements.submitCheatCodeGuessBtn.SetInteractable(true);
	end
end

function updateGuessesUsedThisTurn(uiElements, guesses, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
	uiElements.submitCheatCodeGuessBtn.SetInteractable(false);

	if tbllen(Mod.PlayerGameData.solvedCheatCodes) == Mod.PublicGameData.numCheatCodes then
		if not UI.IsDestroyed(uiElements.guessVert) then
			UI.Destroy(uiElements.guessVert);
		end
		if not UI.IsDestroyed(uiElements.ranOutOfGuessesLabel) then
			UI.Destroy(uiElements.ranOutOfGuessesLabel);
		end

		if uiElements.unlockedAllCodesLabel.GetText() ~= '' then
			return;
		end

		uiElements.unlockedAllCodesLabel.SetText('You have solved all the cheat codes!');
	else
		local guessNo = #guesses + 1;

		if guessNo < Mod.Settings.CheatCodeGuessesPerTurn + 1 then
			uiElements.submitCheatCodeGuessBtn.SetInteractable(true);
			uiElements.submitCheatCodeGuessBtn.SetText('Send guess #' .. guessNo);
		else
			if not UI.IsDestroyed(uiElements.guessVert) then
				UI.Destroy(uiElements.guessVert);
			end

			if uiElements.ranOutOfGuessesLabel.GetText() ~= '' then
				return;
			end

			uiElements.ranOutOfGuessesLabel.SetText('You have used all your guesses for this turn');
		end

		makeDeleteGuessBtns(uiElements, guesses, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
	end
end

function makeDeleteGuessBtns(uiElements, guesses, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
	if not UI.IsDestroyed(deleteGuessBtnsContainer) then
		UI.Destroy(deleteGuessBtnsContainer);
	end

	deleteGuessBtnsContainer = Vert(uiElements.guessesListVert);

	local i = MAX_BTNS_PER_ROW;
	local currentHorz;

	for _, guess in ipairs(guesses) do
		if i == MAX_BTNS_PER_ROW then
			currentHorz = Horz(deleteGuessBtnsContainer);
			i = 0;
		end

		local deleteGuessBtn = UI.CreateButton(currentHorz)
			.SetText(guess);
		deleteGuessBtn.SetOnClick(function()
			UI.Destroy(uiElements.vert);
			SendGameCustomMessage('Deleting guess...', {deleteGuess = guess}, function(guessesSentThisTurn)
				makeMenu(uiElements.rootParent, guessesSentThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
			end);
		end);

		i = i + 1;
	end
end

function makeUseCheatCodeBtns(vert)
	if not Mod.PlayerGameData.solvedCheatCodes then
		-- print('no solved cheat codes');
		return;
	end

	UI.CreateLabel(vert).SetText('Use cheat code:');

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
			SendGameCustomMessage('Acknowledging cheat code usage ...', {useCode = cheatCode}, function() end);
		end;

		useCheatCodeBtn.SetOnClick(useCheatCodeBtnClicked);

		i = i + 1;
	end
end

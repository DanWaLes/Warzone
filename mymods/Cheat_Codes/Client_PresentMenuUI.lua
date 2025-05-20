require 'ui'
require 'util'

local SendGameCustomMessage;
local deleteCodeBtnsContainer = nil;

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
	local MAX_BTNS_PER_ROW = math.floor(WIDTH / CHEAT_CODE_SIZE) - 1;-- fine for 6, 7, 8

	if (Mod.Settings.CheatCodeLength < 6) then
		MAX_BTNS_PER_ROW = MAX_BTNS_PER_ROW - 1;-- fine for 4, 5
	end
	if (Mod.Settings.CheatCodeLength < 4) then
		MAX_BTNS_PER_ROW = MAX_BTNS_PER_ROW - 1;-- fine for 3
	end
	if (Mod.Settings.CheatCodeLength == 2) then
		MAX_BTNS_PER_ROW = MAX_BTNS_PER_ROW - 1;-- fine for 2
	end

	makeMenu(rootParent, Mod.PlayerGameData.codesEnteredThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
end

function makeMenu(rootParent, codesEnteredThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
	local vert = Vert(rootParent);
	local codesVert = Vert(vert);

	UI.CreateLabel(codesVert).SetText('Enter cheat code');
	local codesHorz = Horz(codesVert);

	local codesEnteredInput = UI.CreateTextInputField(codesHorz)
		.SetPreferredWidth(CHEAT_CODE_SIZE + 2)
		.SetCharacterLimit(Mod.Settings.CheatCodeLength)
		.SetPlaceholderText(generateCheatCodePlaceholderText());

	local submitCheatCodeBtn = UI.CreateButton(codesHorz);
	local invalidCode = UI.CreateLabel(codesVert).SetColor('#FF0000');
	local ranOutOfCodesLabel = UI.CreateLabel(vert).SetText('');
	local codesListVert = Vert(vert);
	local codesLabel = UI.CreateLabel(codesListVert).SetText('Codes: (click to delete)');

	local uiElements = {
		rootParent = rootParent,
		vert = vert,
		codesVert = codesVert,
		invalidCode = invalidCode,
		codesEnteredInput = codesEnteredInput,
		submitCheatCodeBtn = submitCheatCodeBtn,
		ranOutOfCodesLabel = ranOutOfCodesLabel,
		codesListVert = codesListVert
	};

	updateCodesEnteredThisTurn(uiElements, codesEnteredThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);

	submitCheatCodeBtn.SetOnClick(function()
		submitCheatCodeBtnClicked(uiElements, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
	end);
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

function submitCheatCodeBtnClicked(uiElements, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
	uiElements.invalidCode.SetText('');
	uiElements.submitCheatCodeBtn.SetInteractable(false);

	local code = uiElements.codesEnteredInput.GetText();
	local isValidGuess = string.len(code) == Mod.Settings.CheatCodeLength and not string.match(code, '[^%d]');
	-- https://www.lua.org/pil/20.2.html

	if isValidGuess then
		if Mod.PlayerGameData.codesEnteredThisTurn[code] then
			uiElements.invalidCode.SetText('You have already entered ' .. code);
			uiElements.submitCheatCodeBtn.SetInteractable(true);
		else
			local codesUsedWithinLimit = true;

			if Mod.Settings.LimitCheatCodesUsedPerTurn and Mod.PlayerGameData.solvedCheatCodes[code] then
				codesUsedWithinLimit = (tbllen(Mod.PlayerGameData.codesToUseThisTurn) + 1) <= Mod.Settings.CodesUsedPerTurnLimit;
			end

			if codesUsedWithinLimit then
				SendGameCustomMessage('Submitting code...', {enterCode = code}, function(codes)
					uiElements.codesEnteredInput.SetText('');
					updateCodesEnteredThisTurn(uiElements, codes, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
				end);
			else
				uiElements.invalidCode.SetText('You have reached the limit of cheat codes you can use per turn');
				uiElements.submitCheatCodeBtn.SetInteractable(true);
			end
		end
	else
		uiElements.invalidCode.SetText(code .. ' is not a valid cheat code');
		uiElements.submitCheatCodeBtn.SetInteractable(true);
	end
end

function updateCodesEnteredThisTurn(uiElements, codes, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
	uiElements.submitCheatCodeBtn.SetInteractable(false);

	local codeNo = tbllen(codes) + 1;

	if codeNo < Mod.Settings.CheatCodeGuessesPerTurn + 1 then
		uiElements.submitCheatCodeBtn.SetInteractable(true);
		uiElements.submitCheatCodeBtn.SetText('Send code #' .. codeNo);
	else
		if not UI.IsDestroyed(uiElements.codesVert) then
			UI.Destroy(uiElements.codesVert);
		end

		if uiElements.ranOutOfCodesLabel.GetText() ~= '' then
			return;
		end

		uiElements.ranOutOfCodesLabel.SetText('You have entered all cheat codes for this turn');
	end

	makeDeleteCodeBtns(uiElements, codes, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
end

function makeDeleteCodeBtns(uiElements, codes, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW)
	if not UI.IsDestroyed(deleteCodeBtnsContainer) then
		UI.Destroy(deleteCodeBtnsContainer);
	end

	deleteCodeBtnsContainer = Vert(uiElements.codesListVert);

	local i = MAX_BTNS_PER_ROW;
	local currentHorz;

	for code, _ in pairs(codes) do
		if i == MAX_BTNS_PER_ROW then
			currentHorz = Horz(deleteCodeBtnsContainer);
			i = 0;
		end

		local deleteCodeBtn = UI.CreateButton(currentHorz)
			.SetText(code);
		deleteCodeBtn.SetOnClick(function()
			UI.Destroy(uiElements.vert);
			SendGameCustomMessage('Deleting code...', {deleteCode = code}, function(codesEnteredThisTurn)
				makeMenu(uiElements.rootParent, codesEnteredThisTurn, CHEAT_CODE_SIZE, MAX_BTNS_PER_ROW);
			end);
		end);

		i = i + 1;
	end
end

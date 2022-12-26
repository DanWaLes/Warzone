require 'ui'
require 'util'
require 'payloadTypes'

function Client_PresentCommercePurchaseUI(rootParent, game, close)
	Game = game;
	Close = close;

	local vert = Vert(rootParent);

	if Mod.PlayerGameData.doneAllCombos then
		local tabData = Tabs(vert, {'Use cheat code'}, {useCheatCodeClicked});

		tabData.tabClicked('Use cheat code', useCheatCodeClicked);
	else
		local tabData = Tabs(vert, {'Offices', 'Hackers', 'Use cheat code'}, {officesClicked, hackersClicked, useCheatCodeClicked});

		if hasToBuyOfficeBeforeBuyingHacker() then
			tabData.tabClicked('Offices', officesClicked);
		else
			tabData.tabClicked('Hackers', hackersClicked);
		end
	end
end

function countNumHackersAndOffices()
	local ret = {
		numOffices = Mod.PlayerGameData.numOffices,
		numHackers = {
			total = Mod.PlayerGameData.hackers.length,
			fromOrders = 0
		}
	};

	for _, order in pairs(Game.Orders) do
		if order.proxyType == 'GameOrderCustom' then
			if order.Payload == PAYLOAD_TYPES.office.buy then
				ret.numOffices = ret.numOffices + 1;
			elseif order.Payload == PAYLOAD_TYPES.hacker.buy then
				ret.numHackers.total = ret.numHackers.total + 1;
				ret.numHackers.fromOrders = ret.numHackers.fromOrders + 1;
			end
		end
	end

	return ret;
end

function officesClicked(tabData)
	local tabContents = tabData.tabContents;

	UI.CreateLabel(tabContents).SetText('Each Office costs ' .. Mod.Settings.OfficeCost .. ' gold and has enough space for ' .. Mod.Settings.HackersPerOffice .. ' hackers to work.');

	local officesAndHackersCount = countNumHackersAndOffices();
	
	if (Mod.Settings.HackersPerOffice * officesAndHackersCount.numOffices) < (officesAndHackersCount.numHackers.total + 1) then
		UI.CreateButton(tabContents).SetText('Buy an office').SetOnClick(function()
			local orders = Game.Orders;
			table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, 'Buy an office', PAYLOAD_TYPES.office.buy, {[WL.ResourceType.Gold] = Mod.Settings.OfficeCost}));
			Game.Orders = orders;
			Close();
		end);
	else
		UI.CreateLabel(tabContents).SetText('You have enough offices for the amount of hackers you have');
	end
end

function hackersClicked(tabData)
	local tabContents = tabData.tabContents;

	UI.CreateLabel(tabContents).SetText('Hackers guess cheat codes and require a office to work from');

	local subTab = Tabs(tabContents, {'Buy hacker', 'Upgrade hackers'}, {buyHackerClicked, upgradeHackersClicked});

	if noHackersAround() then
		subTab.tabClicked('Upgrade hackers', upgradeHackersClicked);
	else
		subTab.tabClicked('Buy hacker', buyHackerClicked);
	end
end

function noHackersAround()
	local turnNo = Game.Game.NumberOfTurns;
	local turnHackerCanBeBought;
	if Mod.PlayerGameData.hackers.lastBoughtOnTurn == -1 then
		turnHackerCanBeBought = turnNo;
	else
		local numTurnsHackerCanBeBought = round(Mod.Settings.SpeedH1 / Mod.Settings.HackersPerOffice);
		turnHackerCanBeBought =  Mod.PlayerGameData.hackers.lastBoughtOnTurn + numTurnsHackerCanBeBought
	end

	local officesAndHackersCount = countNumHackersAndOffices();

	return officesAndHackersCount.numHackers.fromOrders >= 1 or turnHackerCanBeBought ~= turnNo;
end

function hasToBuyOfficeBeforeBuyingHacker()
	local officesAndHackersCount = countNumHackersAndOffices();

	return (Mod.Settings.HackersPerOffice * officesAndHackersCount.numOffices) < (officesAndHackersCount.numHackers.total + 1);
end

function buyHackerClicked(tabData)
	local tabContents = tabData.tabContents;

	-- no new hackers around, check back later
	if noHackersAround() then
		UI.CreateLabel(tabContents).SetText('There are currently no more hackers around, check back later');
	elseif hasToBuyOfficeBeforeBuyingHacker() then
		UI.CreateLabel(tabContents).SetText('You can not buy any hackers until you buy a new office');
	else
		local trainee = Mod.PublicGameData.hackerTypes[1];

		UI.CreateLabel(tabContents).SetText('A ' .. trainee.name .. ' hacker makes ' .. trainee.guessesPerTurn .. ' cheat code guesses per turn (CCGPT) and costs ' .. trainee.cost .. ' gold');
		UI.CreateButton(tabContents).SetText('Buy a Trainee hacker').SetOnClick(function()
			local orders = Game.Orders;
			table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, 'Buy a hacker', PAYLOAD_TYPES.hacker.buy, {[WL.ResourceType.Gold] = Mod.Settings.HackerBaseCost}));
			Game.Orders = orders;
			Close();
		end);
	end
end

function upgradeHackersClicked(tabData)
	local tabContents = tabData.tabContents;

	if Mod.PlayerGameData.hackers.length < 1 then
		UI.CreateLabel(tabContents).SetText('You have no hackers');
		return;
	end

	UI.CreateLabel(tabContents).SetText('It takes 1 turn for a hacker to be trained to the next level');

	local subSubTabs = Tabs(tabContents, {'List', 'Upgrade'}, {viewUpgradesListClicked, upgradeHackerClicked});
	subSubTabs.tabClicked('List', viewUpgradesListClicked);
end

function viewUpgradesListClicked(tabData)
	local tbl = Table(tabData.tabContents);

	tbl.Td(1, 1, '#');
	tbl.Td(1, 2, 'Type');
	tbl.Td(1, 3, 'CCGPT');
	tbl.Td(1, 4, '');

	for hackerNo, hkr in pairs(Mod.PlayerGameData.hackers.list) do
		local rowNo = hackerNo + 1;
		local hackers = Mod.PublicGameData.hackerTypes;
		local hacker = hackers[hkr.upgradeNo];
		local canUpgrade = hkr.upgradeNo < 5;

		tbl.Td(rowNo, 1, hackerNo);
		tbl.Td(rowNo, 2, hacker.name);
		tbl.Td(rowNo, 3, hacker.guessesPerTurn);

		if canUpgrade then
			local upgraded = hackers[hkr.upgradeNo + 1];
			local txt = 'Upgrade';
			if getOrderIndexFromPayload(PAYLOAD_TYPES.hacker.upgrade .. hackerNo) > -1 then
				txt = 'Undo upgrade';
			end

			local upgradeBtn = tbl.Td(rowNo, 4, {func = 'CreateButton', txt = txt});

			upgradeBtn.SetOnClick(function()
				tabData._ = {
					hackerNo = hackerNo,
					hacker = hacker,
					upgraded = upgraded
				};
				tabData.tabClicked('Upgrade', upgradeHackerClicked);
			end);
		else
			tbl.Td(rowNo, 4, '(Maxed)');
		end
	end
end

function upgradeHackerClicked(tabData)
	local tabContents = tabData.tabContents;

	if not tabData._ then
		UI.CreateLabel(tabContents).SetText('Click a View button from the List tab to perform an upgrade');
		return;
	end

	local upgradeMsg = 'Promote hacker #' .. tabData._.hackerNo .. ' from ' .. tabData._.hacker.name .. ' to ' .. tabData._.upgraded.name;
	local payload = PAYLOAD_TYPES.hacker.upgrade .. tabData._.hackerNo;
	local newUpgradeOrder = WL.GameOrderCustom.Create(Game.Us.ID, upgradeMsg, payload, {[WL.ResourceType.Gold] = tabData._.upgraded.cost});

	UI.CreateLabel(tabContents).SetText('Upgrade hacker #' .. tabData._.hackerNo .. ' from ' .. tabData._.hacker.name .. ' to ' .. tabData._.upgraded.name);

	local btnsContainer = Vert(tabContents);
	local undoBtn = nil;
	local buyBtn = nil;

	function makeUpgradeOrUnupgradeBtns()
		if not UI.IsDestroyed(alreadyBought) then
			UI.Destroy(alreadyBought);
		end
		if not UI.IsDestroyed(undoBtn) then
			UI.Destroy(undoBtn);
		end
		if not UI.IsDestroyed(buyBtn) then
			UI.Destroy(buyBtn);
		end

		local orderIndex = getOrderIndexFromPayload(payload);
		local hasBoughtUpgrade = orderIndex > -1;
		local orders = Game.Orders;

		if hasBoughtUpgrade then
			if UI.IsDestroyed(undoBtn) then
				undoBtn = UI.CreateButton(btnsContainer).SetText('Undo upgrade');
				undoBtn.SetOnClick(function()
					table.remove(orders, orderIndex);
					Game.Orders = orders;

					makeUpgradeOrUnupgradeBtns();
				end);
			end
		else
			if UI.IsDestroyed(buyBtn) then
				buyBtn = UI.CreateButton(btnsContainer).SetText('Buy upgrade');
				buyBtn.SetOnClick(function()
					table.insert(orders, newUpgradeOrder);
					Game.Orders = orders;

					makeUpgradeOrUnupgradeBtns();
				end);
			end;
		end
	end

	makeUpgradeOrUnupgradeBtns();
	UI.CreateLabel(tabContents).SetText(tabData._.hacker.name .. ' hackers do ' .. tabData._.hacker.guessesPerTurn .. ' cheat code guesses per turn (CCGPT)');
	UI.CreateLabel(tabContents).SetText('Upgrading to ' .. tabData._.upgraded.name .. ' hacker will do ' .. tabData._.upgraded.guessesPerTurn .. ' cheat code guesses per turn (CCGPT) and cost ' .. tabData._.upgraded.cost .. ' gold');

	tabData._ = nil;
end

function getOrderIndexFromPayload(payload)
	for i, order in pairs(Game.Orders) do
		if order.proxyType == 'GameOrderCustom' then
			if order.Payload == payload then
				return i;
			end
		end
	end

	return -1;
end

function useCheatCodeClicked(tabData)
	local tabContents = tabData.tabContents;

	UI.CreateLabel(tabContents).SetText('Any cheat codes that you and your teammates hackers solve will be listed here.');

	local useBtnColor = '#00FF05';
	local unuseBtnColor = '#FF0000';

	UI.CreateLabel(tabContents).SetText('If a button is this color, the cheat code will be used').SetColor(useBtnColor);
	UI.CreateLabel(tabContents).SetText('If a button is this color, the cheat code will not be used').SetColor(unuseBtnColor);
	UI.CreateLabel(tabContents).SetText('Clicking a button switches from not using to using or the opposite');

	local codesContainer = Vert(tabContents);

	Game.SendGameCustomMessage('Loading your team\'s unlocked codes...', {getTeamSolvedCodes = true}, function(solved)
		local btnSize = (uiConstants.textSize * Mod.Settings.CheatCodeLength) + (uiConstants.padding * 2) + uiConstants.left;
		local MAX_USE_CODE_BTNS_PER_ROW = math.floor((uiConstants.pcpuiWidth + uiConstants.left) / btnSize);
		local i = MAX_USE_CODE_BTNS_PER_ROW;
		local currentHorz;

		function setBtnColor(btn, cheatCodesToUse)
			if cheatCodesToUse[btn.GetText()] then
				btn.SetColor(useBtnColor);
			else
				btn.SetColor(unuseBtnColor);
			end
		end

		function btnClicked(btn)
			if Mod.PlayerGameData.cheatCodesToUse[btn.GetText()] then
				Game.SendGameCustomMessage('Unusing cheat code...', {unuseCode = btn.GetText()}, function(cheatCodesToUse)
					setBtnColor(btn, cheatCodesToUse);
				end);
			else
				Game.SendGameCustomMessage('Using cheat code...', {useCode = btn.GetText()}, function(cheatCodesToUse)
					setBtnColor(btn, cheatCodesToUse);
				end);
			end
		end

		for code, _ in pairs(solved) do
			if i == MAX_USE_CODE_BTNS_PER_ROW then
				currentHorz = Horz(codesContainer);
				i = 0;
			end

			local btn = UI.CreateButton(currentHorz).SetText(code);
			setBtnColor(btn, Mod.PlayerGameData.cheatCodesToUse);
			btn.SetOnClick(function()
				btnClicked(btn);
			end);

			i = i + 1;
		end
	end);
end

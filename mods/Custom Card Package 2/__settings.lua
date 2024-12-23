-- modified from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('settings');
require('ui');

local function Card(cardName, p1, p2, p3)
	local isNewCard = p1 and type(p1) == 'boolean';
	local help;
	local extraSubsettings;

	if isNewCard then
		help = p2;
		extraSubsettings = p3 or {};
	else
		help = p1;
		extraSubsettings = p2 or {};
	end

	if not extraSubsettings then
		extraSubsettings = {};
	end

	local card = addSetting('Enable' .. cardName, 'Enable ' .. cardName .. ' cards', 'bool', false, {
		subsettings = {
			addSetting(cardName .. 'PiecesInCard', 'Number of pieces to divide the card into', 'int', 5, {
				minValue = 1,
				maxValue = 10,
				absoluteMax = 100
			}),
			addSetting(cardName .. 'WonByChance', 'Award pieces based on random chance', 'bool', false, {
				bkwrds = false,
				help = function(parent)
					Label(parent).SetText('If enabled, all pieces from "Minimum pieces awarded per turn" are given first then chance applies to the upper limit of number of card pieces to award on piece by piece basis');
				end,
				subsettings = {
					addSetting(cardName .. 'PiecesPerTurnMaxLimit', 'Maximum pieces awarded per turn', 'int', 1, {
						minValue = 1,
						maxValue = 10,
						absoluteMax = 100,
						help = function(parent)
							Label(parent).SetText('If "Minimum pieces awarded per turn" is higher than this setting, then the value for that setting is used for this setting');
						end
					}),
					addSetting(cardName .. 'WonByChancePercent', 'Chance of a piece being awarded (%)', 'int', 10, {
						minValue = 0,
						maxValue = 100
					}),
				}
			}),
			addSetting(cardName .. 'PiecesPerTurn', 'Minimum pieces awarded per turn', 'int', 1, {
				minValue = 0,
				maxValue = 10,
				absoluteMax = 100
			}),
			addSetting(cardName .. 'StartPieces', 'Pieces given to each player at the start', 'int', 0, {
				minValue = 0,
				maxValue = 10,
				absoluteMax = 100
			}),
			addSetting(cardName .. 'IsBuyable', 'Can be bought', 'bool', false, {
				help = function(parent)
					Label(parent).SetText('Must be a commerce game to be bought');
				end,
				subsettings = {
					addSetting(cardName .. 'Cost', 'Cost (gold)', 'int', 5, {
						minValue = 1,
						maxValue = 20,
						absoluteMax = 10000
					})
				}
			}),
			addSetting(cardName .. 'NeedsSuccessfulAttackToEarnPiece', 'Needs successful attack to award pieces', 'bool', true)
		}
	});

	card.help = help;

	if isNewCard then
		card.bkwrds = false;
	end

	for _, subsetting in ipairs(extraSubsettings) do
		table.insert(card.subsettings, subsetting);
	end

	return card;
end

local function addDurationSetting(cardName, defaultValue)
	return addSetting(cardName .. 'Duration', 'Duration (turns)', 'int', defaultValue, {
		bkwrds = 1,
		minValue = 1,
		maxValue = 10,
		absoluteMax = 100000
	});
end

function getSettings()
	return {
		Card('Reconnaissance+', function(parent)
			Label(parent).SetText('Like normal Reconnaissance Cards but with a range and lasts for 1 turn');--no param instance is 1 turn
			Label(parent).SetText('Reconnaissance Cards must be included for the card to work');
		end, {
			addDurationSetting('Reconnaissance+', 1),
			addSetting('Reconnaissance+Range', 'Range', 'int', 2, {
				minValue = 1,
				maxValue = 5
			}),
			addSetting('Reconnaissance+RandomAutoplay', 'Automatically randomly play this card', 'bool', false, {
				bkwrds = false,
				help = function(parent)
					Label(parent).SetText('If enabled, players will not be able to play this card through the menu')
					Label(parent).SetText('Instead the card will automatically be played anywhere');
				end
			})
		}),
		Card('Recycle', function(parent)
			Label(parent).SetText('Sets the number armies on a territory to be the amount that was on it on the first turn and changes the owner to neutral');
			Label(parent).SetText('The armies that used to be on the territory get added to your income');
			Label(parent).SetText('Can only be played on one of your own territories');
		end, {
			addSetting('RecycleEliminateIfCommander', 'Recycling Commander causes elimination', 'bool', false, {
				bkwrds = false,
				help = function(parent)
					Label(parent).SetText('If a Recycle Card was played on a territory with a Commander, should the player be eliminated?');
				end
			})
		}),
		Card('Immobilize', function(parent)
			Label(parent).SetText('Prevents all army movement (including airlifts) to and from a territory that is next to or is one of yours');
		end, {
			addDurationSetting('Immobilize', 2)
		}),
		Card('Trap', function(parent)
			Label(parent).SetText('Similar to Blockade Cards except they are triggered by the enemy capturing where the card was played');
			Label(parent).SetText('Traps must be played on one of your own territories');
		end, {
			addSetting('TrapMultiplier', 'Multiplier', 'float', 4, {
				help = function(parent)
					Label(parent).SetText('Armies attacking become neutral and are multiplied by this much');
				end,
				dp = 2,
				minValue = 0,
				maxValue = 8
			}),
			addSetting('TrapEliminateIfCommander', 'Trapping Commander causes elimination', 'bool', true, {
				bkwrds = false,
				help = function(parent)
					Label(parent).SetText('If one of the armies taking over the territory (where a Trap Card was played) was a Commander, should the player be eliminated?');
				end
			})
		}),
		Card('Double Tap', function(parent)
			Label(parent).SetText('Allows you to make a second attack/transfer from a territory that you already issued an attack/transfer from');
			Label(parent).SetText('If one of your attacks fails but you played a Double Tap Card, a new order will be created using all armies and any special units that are on the territory at the time the card is played');
			Label(parent).SetText('If using multi-attack and the double tap attack is successful, the multi-attack chain will only continue if it was played before the next attack of the chain');
		end),
		Card('Rushed Blockade', true, function(parent)
			Label(parent).SetText('Like normal Blockade Cards but happen during the attacks phase - attack one territory then blockade it during the same turn');
			Label(parent).SetText('You must own the territory at the time of the card being played');
		end, {
			addSetting('Rushed BlockadeMultiplier', 'Multiplier', 'float', 3, {
				dp = 2,
				minValue = 0,
				maxValue = 8
			}),
		}),
		addSetting('LimitMaxCards', 'Limit maximum cards each player or team can hold', 'bool', true, {
			bkwrds = false,
			subsettings = {
				addSetting('MaxCardsLimit', 'Limit', 'int', 3, {
					minValue = 0,
					maxValue = 15,
					absoluteMax = 600
				})
			}
		})--,
		-- addSetting('HumanPlayCardOnTeamAITerritories', 'Let humans play cards on their AI teammates behalf', 'bool', true, {
			-- bkwrds = false
		-- }),
		-- addSetting('AIsPlayCards', 'Let AIs play cards', 'bool', false, {
			-- bkwrds = false,
			-- help = function(parent)
				-- Label(parent).SetText('If enabled, AIs will play cards as long as there are no humans on their team');
			-- end
		-- }),
		-- addSetting('HostOnlyOptionsEnabled', 'Enable host-only options', 'bool', false, {
			-- bkwrds = false,
			-- help = function(parent)
				-- Label(parent).SetText('Allows the game host to add card pieces to players or teams and remove all their cards');
			-- end
		-- })
	};
end

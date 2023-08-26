require '_settings'
require '_ui'

local function Card(cardName, help, extraSubsettings)
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
			addSetting(cardName .. 'PiecesPerTurn', 'Pieces awarded per turn', 'int', 1, {
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
						absoluteMax = 100
					})
				}
			}),
			addSetting(cardName .. 'NeedsSuccessfulAttackToEarnPiece', 'Needs successful attack to award pieces', 'bool', true)
		}
	});

	card.help = help;

	for _, subsetting in ipairs(extraSubsettings) do
		table.insert(card.subsettings, subsetting);
	end

	return card;
end

function getSettings()
	return {
		Card('Reconnaissance+', function(parent)
			Label(parent).SetText('Like normal Reconnaissance Cards but with a range and lasts for 1 turn');--no param instance is 1 turn
			Label(parent).SetText('Reconnaissance Cards must be included for the card to work');
		end, {
			addSetting('Reconnaissance+Range', 'Range', 'int', 2, {
				minValue = 1,
				maxValue = 5
			})
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
			})
		}),
		Card('Immobilize', function(parent)
			Label(parent).SetText('Prevents all army movement (including airlifts) to and from a territory that is next to or is one of yours');
		end, {
			addSetting('ImmobilizeDuration', 'Duration (turns)', 'int', 2, {
				minValue = 1,
				maxValue = 10
			})
		}),
		Card('Recycle', function(parent)
			Label(parent).SetText('Sets the number armies on a territory to be the amount that was on it on the first turn and changes the owner to neutral');
			Label(parent).SetText('The armies that used to be on the territory get added to your income');
			Label(parent).SetText('Can only be played on one of your own territories');
		end),
		Card('Double Tap', function(parent)
			Label(parent).SetText('Allows you to make a second attack/transfer from a territory that you already issued an attack/transfer from');
			Label(parent).SetText('If one of your attacks fails but you played a Double Tap Card, a new order will be created using all armies and any special units that are on the territory at the time the card is played');
			Label(parent).SeText('If using multi-attack and the double tap attack is successful, the multi-attack chain will only continue if it was played before the next attack of the chain');
		end)
	};
end
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
			addSetting(cardName .. 'MinPiecesPerTurn', 'Min pieces awarded per turn', 'int', 1, {
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
			Label(parent).SetText('Like normal reconnaissance cards but with a range');
			Label(parent).SetText('Reconnaissance cards must be included for the card to work');
			Label(parent).SetText('Duration is the same as normal reconnaissance cards');
		end, {
			addSetting('Reconnaissance+Range', 'Range', 'int', 2, {
				minValue = 1,
				maxValue = 5
			})
		})
	};
end
-- modified from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('settings');
require('_ui');

function getSettings()
	return {
		newCardSetting('Reinforcement', 'Reinforcement'),
		newCardSetting('Spy', 'Spy'),
		newCardSetting('Abandon', 'Emergency Blockade'),
		newCardSetting('OrderPriority', 'Order Priority'),
		newCardSetting('OrderDelay', 'Order Delay'),
		newCardSetting('Airlift', 'Airlift'),
		newCardSetting('Gift', 'Gift'),
		newCardSetting('Diplomacy', 'Diplomacy'),
		newCardSetting('Sanctions', 'Sanctions'),
		newCardSetting('Blockade', 'Blockade'),
		newCardSetting('Reconnaissance', 'Reconnaissance'),
		newCardSetting('Surveillance', 'Surveillance'),
		newCardSetting('Bomb', 'Bomb')
	};
end

function newCardSetting(cardName, cardNameReadable)
	return addSetting('Enable' .. cardName, 'Give ' .. cardNameReadable .. ' Card pieces', 'bool', false, {
		subsettings = {
			addSetting('Pieces' .. cardName, 'Number of pieces given to each player', 'int', 1, {
				minValue = 1,
				maxValue = 10,
				absoluteMax = 100
			}),
			addSetting('Freq' .. cardName, 'Frequency (turns)', 'int', 1, {
				minValue = 1,
				maxValue = 10,
				absoluteMax = 100
			}),
			addSetting('GetDiff' .. cardName, 'Only give card pieces out if they have not been given already', 'bool', true, {
				bkwrds = false,
				help = function(parent)
					Label(parent).SetText('Takes the total card pieces for each card piece received order and reduces it from the "Number of pieces given to each player" setting. Any remaining pieces will be given.');
				end
			})
		}
	});
end

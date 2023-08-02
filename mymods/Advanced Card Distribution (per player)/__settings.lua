require '_settings'
require '_ui'

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
			addSetting('Pieces' .. cardName, 'Number of free pieces given to each player', 'int', 1, {
				minValue = 1,
				maxValue = 10,
				absoluteMax = 100
			}),
			addSetting('Freq' .. cardName, 'Frequency (turns)', 'int', 1, {
				minValue = 1,
				maxValue = 10,
				absoluteMax = 100
			})
		}
	});
end
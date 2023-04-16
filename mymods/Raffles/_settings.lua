require 'z_settings'
require 'z_ui'

function getSettings()
	return {
		addSetting('RaffleChance', 'Chance of raffle happening (per turn)', 'int', 40, {
			minValue = 0,
			maxValue = 100
		}),
		addSetting('RaffleReward', 'Raffle reward (gold/armies)', 'int', 5, {
			minValue = 1,
			maxValue = 10
		}),
		addSetting('RaffleRewardRand', 'Raffle reward +/- random', 'int', 0, {
			minValue = 0,
			maxValue = 10
		}),
		addSetting('MegaRaffleEnabled', 'Enable mega raffles', 'bool', false, {
			help = function(parent)
				Label(parent).SetText('Mega raffles are like normal raffles but with higher gain');
			end,
			subsettings = {
				addSetting('MegaRaffleChance', 'Chance of raffle being a mega raffle', 'int', 10, {
					minValue = 1,
					maxValue = 25
				}),
				addSetting('MegaRaffleMulti', 'Mega raffle multiplier', 'float', 5, {
					dp = 2,
					minValue = 1,
					maxValue = 5,
					help = function(parent)
						Label(parent).SetText('The reward gets multiplied by this much');
					end
				})
			}
		})
	};
end
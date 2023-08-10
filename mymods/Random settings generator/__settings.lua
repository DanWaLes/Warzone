require '_settings'
require '_ui'

function getSettings()
	return {
		addSetting('UseRandomLuckMod', 'Randomize luck modifier', 'bool', false, {
			subsettings = {
				addSetting('LuckStrat', 'Use strategic luck modifier (0 or 16%)', 'bool', true, {
					help = function(parent)
						Label(parent).SetText('If disabled, any luck modifier value will be used');
					end
				})
			}
		}),
		addSetting('UseRandomKillRates', 'Randomize kill rates', 'bool', false),
		addSetting('RandomiseArmiesStandGuard', 'Randomize one army stands guard', 'bool', false),
		addSetting('UseRandomCommerce', 'Randomize commerce settings', 'bool', false),
		addSetting('UseRandomDistMode', 'Randomize distribution mode', 'bool', false, {
			help = function(parent)
				Label(parent).SetText('If enabled distribution mode will be random between full distribution, random warlords and random cities');
			end
		})
	};
end
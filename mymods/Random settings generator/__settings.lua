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
		}),
		addSetting('AllowHeavierFogs', 'Allow use of heavier fogs', 'bool', false, {
			bkwrds = true,
			help = function(parent)
				Label(parent).SetText('By default, fog is randomly decided to be no fog, light fog or normal fog');
				Label(parent).SetText('Enabling allows dense fog, heavy fog and complete fog to be included');
			end,
			subsettings = {
				addSetting('ForceHeavierFogCards', 'Force inclusion of Reconnaissance, Surveillance and or Spy cards', 'bool', true, {
					bkwrds = false,
					help = function(parent)
						Label(parent).SetText('These cards will only be included by force if the fog level is higher than normal fog');
					end
				})
			}
		}),
		addSetting('RandomiseCardsHeldVisibility', 'Randomize cards held and received visibility', 'bool', false, {
			bkwrds = false
		}),
		addSetting('RandomiseCardsPlayedVisibility', 'Randomize played visibility', 'bool', false, {
			bkwrds = false
		})
	};
end
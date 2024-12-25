require '_settings'
require '_ui'

function getSettings()
	return {
		addSetting('EnableTransfers', 'Allow AIs to make transfers', 'bool', true),
		addSetting('EnableAttackOtherAIs', 'Allow AIs to attack other AIs', 'bool', true),
		addSetting('EnableAttackNeutrals', 'Allow AIs to attack neutrals', 'bool', true)
	};
end

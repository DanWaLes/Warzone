require '_settings'
require '_ui'

function getSettings()
	return {
		addSetting('MaxTerrs', 'Cards can not be played on bonuses with more than this much territories', 'int', 10, {
			minValue = 2,
			maxValue = 50,
			absoluteMax = 4000-- current wz max terrs allowed in map
		})
	};
end

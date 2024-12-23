-- modified from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('settings');

function getSettings()
	return {
		addSetting('MaxTerrs', 'Cards can not be played on bonuses with more than this much territories', 'int', 10, {
			minValue = 2,
			maxValue = 50,
			absoluteMax = 4000-- current wz max terrs allowed in map
		})
	};
end
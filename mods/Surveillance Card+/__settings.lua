-- modified from https://github.com/DanWaLes/Warzone/tree/main/mods/libs/AutoSettingsFiles

require('settings');

function getSettings()
	return {
		addSetting('MaxTerrs', 'Surveillance Cards can not be played on bonuses with more than this many territories', 'int', 10, {
			minValue = 2,
			maxValue = 50,
			absoluteMax = 4000-- current wz max terrs allowed in map
		})
	};
end

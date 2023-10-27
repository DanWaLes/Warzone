require '_settings';

function getSettings()
	return {
		addSetting('RevoltChance', 'Chance of territories swapping (%)', 'int', 50, {
			minValue = 0,
			maxValue = 100
		});
	};
end
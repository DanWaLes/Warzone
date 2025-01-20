-- modified from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/AutoSettingsFiles

require('settings');

function getSettings()
	return {
		addSetting('intsetting', 'int setting', 'int', 3, {
			minValue = 1,
			maxValue = 5
		}),
		addSetting('floatsetting', 'float setting', 'float', 5.33, {
			dp = 2,
			minValue = 1,
			maxValue = 10,
			absoluteMin = -1,
			absoluteMax = 11,
			labelColor = '#555555',
			help = function(parent)
				UI.CreateLabel(parent).SetText('float setting help: lowest value allowed is -1, highest value allowed is 11');
			end
		}),
		addSetting('boolsetting', 'bool setting', 'bool', true, {
			labelColor = '#ff0000',
			help = function(parent)
				UI.CreateLabel(parent).SetText('bool setting help: can only be enabled or disabled');
			end
		}),
		addSetting('textsetting', 'text setting', 'text', 'ffdgs', {
			placeholder = 'placeholder',
			charLimit = 15,
			labelColor = '#0000ff',
			help = function(parent)
				UI.CreateLabel(parent).SetText('text setting help: text can only be upto 15 characters long');
			end
		}),
		addSetting('boolsettingwithsubsettings', 'bool setting with sub settings', 'bool', false, {
			labelColor = '#00ff00',
			help = function(parent)
				UI.CreateLabel('this setting has sub settings. sub settings will be displayed if enabled');
			end,
			subsettings = {
				addSetting('boolsettingwithsubsettingsint1', 'int sub setting 1', 'int', 5, {
					minValue = 5,
					maxValue = 10,
					absoluteMin = 0,
					labelColor = '#0000ff',
					help = function(parent)
						UI.CreateLabel('int sub setting 1 help: lowest allowed value is 0')
					end
				}),
				addSetting('boolsettingwithsubsettingsint2', 'int sub setting 2', 'int', 10, {
					minValue = 5,
					maxValue = 10,
					absoluteMax = 15,
					labelColor = '#0000ff',
					help = function(parent)
						UI.CreateLabel('int sub setting 2 help: highest allowed value is 15');
					end
				}),
				addSetting('boolsettingwithsubsettingsbool', 'bool sub setting', 'bool', true, {
					help = function(parent)
						UI.CreateLabel('bool sub setting help: this should automatically be enabled and show its sub settings');
					end,
					subsettings = {
						addSetting('sssInt', 'bool sub setting int', 'int', 6, {
							minValue = 0,
							maxValue = 10
						})
					}
				})
			}
		})
	};
end

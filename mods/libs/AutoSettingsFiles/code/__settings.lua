-- This file is part of an implementation of https://github.com/DanWaLes/Warzone/tree/main/mods/libs/AutoSettingsFiles
-- Having a getSettings function is necessary for correct functionality
-- Using the module "settings" is for convenience/error checking

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
				UI.CreateLabel(parent).SetText('this setting has sub settings. sub settings will be displayed if enabled, defaults to disabled');
			end,
			subsettings = {
				addSetting('boolsettingwithsubsettingsint1', 'int sub setting 1', 'int', 5, {
					minValue = 5,
					maxValue = 10,
					absoluteMin = 0,
					labelColor = '#0000ff',
					help = function(parent)
						UI.CreateLabel(parent).SetText('int sub setting 1 help: lowest allowed value is 0')
					end
				}),
				addSetting('boolsettingwithsubsettingsint2', 'int sub setting 2', 'int', 10, {
					minValue = 5,
					maxValue = 10,
					absoluteMax = 15,
					labelColor = '#0000ff',
					help = function(parent)
						UI.CreateLabel(parent).SetText('int sub setting 2 help: highest allowed value is 15');
					end
				}),
				addSetting('boolsettingwithsubsettingsbool', 'bool sub setting', 'bool', true, {
					help = function(parent)
						UI.CreateLabel(parent).SetText('bool sub setting help: this should automatically be enabled and show its sub settings');
					end,
					subsettings = {
						addSetting('sssInt', 'bool sub setting int', 'int', 6, {
							minValue = 0,
							maxValue = 10
						})
					}
				})
			}
		}),
		addSetting('radioinput', 'Mode', 'radio', 3, {
			labelColor = '#012345',
			help = function(parent)
				UI.CreateLabel(parent).SetText('radio button help: you can only choose one, defaults to easy');
			end,
			controls = {
				'easy',
				{
					label = 'medium',
					help = function(parent)
						UI.CreateLabel(parent).SetText('radio button medium help');
					end
				},
				{
					label = 'hard',
					labelColor = '#fedcba',
					help = function(parent)
						UI.CreateLabel(parent).SetText('radio button hard help: hard, as opposed to easy');
					end
				}
			}
		}),
		addSettingTemplate('extraWasteland', 'Add new wasteland group', nil, function(n)
			return {
				label = 'Enable extra wastelands' .. tostring(n),
				settings = {
					addSetting('W' .. tostring(n) .. 'Num', 'Number of wastelands', 'int', 5, {
						minValue = 1,
						maxValue = 15,
						absoluteMax = 4000
					})
				}
			};
		end)
	};
end
-- an example
require 'ui'

function getSettings()
	return {
		{
			name = 'SettingOne',
			inputType = 'int',
			defaultValue = 5,
			minValue = 1,
			maxValue = 10,
			label = 'setting one desc',
			help = function(parent)
				Label(parent).SetText('enter help here');
			end,
		},
		{
			name = 'SettingTwo',
			inputType = 'bool',
			defaultValue = false,
			label = 'setting two',
			help = function(parent)
				Label(parent).SetText('this has some subsettings');
			end,
			subsettings = {
				{
					name = 'SettingTwoss1',
					inputType = 'float',
					defaultValue = 1.5,
					minValue = 0,
					maxValue = 2,
					dp = 2,
					label = 'setting two ss1 desc'
				},
				{
					name = 'SettingTwoss2',
					inputType = 'bool',
					defaultValue = true,
					label = 'setting two ss2 desc',
					help = function(parent)
						Label(parent).SetText('if checked this happens');
					end
				}
			}
		},
		{
			name = 'SettingTemplate',
			isTemplate = true,
			btnText = 'add setting template group',
			get = function(n)
				return {
					name = 'SettingTemplate_' .. n,
					inputType = 'bool',
					defaultValue = true,
					label = 'enable setting template group ' .. n,
					subsettings = {
						{
							name = 'SettingTemplate_' .. n .. 'ss1',
							inputType = 'int',
							defaultValue = 5,
							minValue = 5,
							maxValue = 10,
							label = 'ss1'
						},
						{
							name = 'SettingTemplate_' .. n .. 'ss2',
							inputType = 'float',
							defaultValue = 5,
							minValue = 5,
							maxValue = 10,
							dp = 2,
							label = 'ss2'
						}
					}
				};
			end
		}
	};
end

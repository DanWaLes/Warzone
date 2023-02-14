require 'ui'

function getSettings()
	templates = {
		extraWasteland = {
			btnText = 'Add new wasteland group',
			bkwrds = 5
		}
	};

	for name in pairs(templates) do
		templates[name].name = name;
		templates[name].isTemplate = true;
	end

	templates.extraWasteland.get = function(id)
		return {
			name = 'EnabledW' .. id,
			inputType = 'bool',
			defaultValue = true,
			label = 'Enable extra wastelands ' .. id,
			subsettings = {
				{
					name = 'W' .. id .. 'Num',
					inputType = 'int',
					defaultValue = 5,
					minValue = 1,
					maxValue = 15,
					absoluteMax = 4000,-- 4000 is max territories a map can have
					label = 'Number of wastelands'
				},
				{
					name = 'W' .. id .. 'Size',
					inputType = 'int',
					defaultValue = 5,
					minValue = 0,
					maxValue = 100,
					absoluteMax = 100000,-- highest allowed in custom scenario
					label = 'Wasteland size'
				},
				{
					name = 'W' .. id .. 'Rand',
					inputType = 'int',
					defaultValue = 0,
					minValue = 0,
					maxValue = 15,
					absoluteMax = 100000,
					label = 'Random +/- amount',
					help = function(parent)
						Label(parent).SetText('Wastelands will have their size increased or lowered by up to this much');
					end
				},
				{
					name = 'W' .. id .. 'Type',
					inputType = 'int',
					defaultValue = 1,
					minValue = 1,
					maxValue = 3,
					label = 'Wasteland type',
					help = function(parent)
						Label(parent).SetText('1 = distribution wasteland');
						Label(parent).SetText('2 = runtime wasteland');
						Label(parent).SetText('3 = both');
					end
				}
			}
		};
	end;

	return {
		{
			name = 'CreateDistributionWastelandsAfterPicks',
			inputType = 'bool',
			defaultValue = false,
			label = 'Create distribution wastelands after picks',
			help = function(parent)
				Label(parent).SetText('Takes affect on all distribution wastelands');
				Label(parent).SetText('Only does a difference in manual distribution games');
			end
		},
		{
			name = 'UseMaxTerrs',
			inputType = 'bool',
			defaultValue = true,
			label = 'Prevent wastelands from reducing max territory limit',
			help = function(parent)
				Label(parent).SetText('If there is no territory limit then all players will have at least one spawn');
				Label(parent).SetText('Applies to normal wastelands and extra distribution wastelands');
			end
		},
		{
			name = 'OverlapsEnabled',
			inputType = 'bool',
			defaultValue = false,
			bkwrds = true,
			label = 'Enable wasteland overlaps',
			help = function(parent)
				Label(parent).SetText('Wastelands occpy as many neutral or pickable territories as possable before replacing an existing wasteland');
				Label(parent).SetText('The "Overlap mode" will decide how overlaps are dealt with');
			end,
			subsettings = {
				{
					name = 'OverlapMode',
					inputType = 'int',
					defaultValue = 1,
					minValue = 1,
					maxValue = 4,
					label = 'Overlap mode',
					help = function(parent)
						Label(parent).SetText('In the event of wastelands randomly getting placed on top of each other, what should happen?');
						Label(parent).SetText('1 = randomly choose which gets used');
						Label(parent).SetText('2 = newest overrides');
						Label(parent).SetText('3 = use smallest wasteland');
						Label(parent).SetText('4 = use largest wasteland');
					end
				},
				{
					name = 'TreatAllNeutralsAsWastelands',
					inputType = 'bool',
					defaultValue = true,
					label = 'Treat all neutrals as wastelands',
					help = function(parent)
						Label(parent).SetText('If enabled the runtime wastelands will follow the wasteland overlap mode for all neutral territories');
						Label(parent).SetText('If disabled the new wasteland will always replace the territory');
						Label(parent).SetText('If "Max overlaps per turn" is 1 then no new wastelands will be created');
						Label(parent).SetText('Applies to runtime wastelands only');
					end
				},
				{
					name = 'MaxOverlaps',
					inputType = 'int',
					defaultValue = 0,
					minValue = 0,
					maxValue = 3,
					bkwrds = 0,
					label = 'Max overlaps per turn',
					help = function(parent)
						Label(parent).SetText('This setting is only here for performance reasons');
						Label(parent).SetText('Fewer overlaps is faster; 0 = unlimited');
						Label(parent).SetText('Existing wastelands are decided first then lowest to highest wasteland group number are created');
					end
				}
			}
		},
		templates.extraWasteland
	};
end
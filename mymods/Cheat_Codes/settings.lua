function getSettings()
	return {
		CheatCodeLength = {
			inputType = 'int',
			defaultValue = 2,
			minValue = 1,
			maxValue = 3,
			label = 'Cheat code length'
		},
		CheatCodeGuessesPerTurn = {
			inputType = 'int',
			defaultValue = 20,
			minValue = 1,
			maxValue = 200,
			label = 'Max unique cheat codes entered per turn'
		},
		LimitCheatCodesUsedPerTurn = {
			inputType = 'bool',
			defaultValue = false,
			label = 'Limit number of unique cheat codes used per turn',
			subsettings = {
				CodesUsedPerTurnLimit = {
					inputType = 'int',
					defaultValue = 1,
					minValue = 1,
					maxValue = 13,
					label = 'Limit'
				}
			}
		},
		CheatCodeGuessVisibiltyIsTeamOnly = {
			inputType = 'bool',
			defaultValue = true,
			label = 'Cheat code guess visibility is team-only'
		},
		CheatCodeSolvedVisibiltyIsTeamOnly = {
			inputType = 'bool',
			defaultValue = true,
			label = 'Cheat code solved visibility is team-only'
		}
	};
end

-- number of cards currently available in core game is 13
-- card mods replace existing cards
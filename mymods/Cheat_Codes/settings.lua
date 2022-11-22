function getSettings()
	return {
		CheatCodeLength = {
			inputType = 'int',
			defaultValue = 4,
			minValue = 2,
			maxValue = 8,
			label = 'Cheat code length'
		},
		CheatCodeGuessesPerTurn = {
			inputType = 'int',
			defaultValue = 5,
			minValue = 1,
			maxValue = 15,
			label = 'Max unique cheat codes entered per turn'
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
function getSettings()
	return {
		{
			name = 'CheatCodeLength',
			inputType = 'int',
			defaultValue = 3,
			minValue = 1,
			maxValue = 8,
			label = 'Cheat code length'
		},
		{
			name = 'MaxCheatCodesUsedPerTurn',
			inputType = 'int',
			defaultValue = 2,
			minValue = 1,
			maxValue = 13,
			label = 'Max unique cheat codes used per turn'
		},
		{
			name = 'SellPerCent',
			inputType = 'int',
			defaultValue = 125,
			minValue = 0,
			maxValue = 500,
			label = 'Sell %'
		},
		{
			name = 'OfficeCost',
			inputType = 'int',
			defaultValue = 15,
			minValue = 10,
			maxValue = 20,
			label = 'Office cost'
		},
		{
			name = 'HackersPerOffice',
			inputType = 'int',
			defaultValue = 2,
			minValue = 1,
			maxValue = 3,
			label = 'Hackers per office'
		},
		{
			name = 'SpeedH1',
			inputType = 'int',
			defaultValue = 20,
			minValue = 15,
			maxValue = 30,
			label = 'Turns taken for a single Trainee to guess all cheat codes'
		},
		{
			name = 'HackerBaseCost',
			inputType = 'int',
			defaultValue = 3,
			minValue = 2,
			maxValue = 6,
			label = 'Trainee hacker cost'
		},
		{
			name = 'CheatCodeGuessVisibiltyIsTeamOnly',
			inputType = 'bool',
			defaultValue = true,
			label = 'Cheat code guess visibility is team-only'
		},
		{
			name = 'CheatCodeSolvedVisibiltyIsTeamOnly',
			inputType = 'bool',
			defaultValue = true,
			label = 'Cheat code solved visibility is team-only'
		}
	};
end

-- number of cards currently available in core game is 13
-- card mods replace existing cards
-- modified from https://github.com/DanWaLes/Warzone/tree/main/mods/libs/AutoSettingsFiles

require('settings');
require('ui');

function getSettings()
	return {
		Card('Sacrifice Card', {NumPieces = 1, MinimumPiecesPerTurn = 0, InitialPieces = 1, Weight = 0}, 'Eliminates the player that played the card, adds their total income and the total value of armies to the income to a teammate of their choice. This card only takes affect in team games.')
	};
end
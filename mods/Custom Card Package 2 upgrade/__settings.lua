-- This file is part of the implementation of https://github.com/DanWaLes/Warzone/tree/main/mods/libs/AutoSettingsFiles
-- Having a `getSettings` function is necessary for correct functionality
-- Using the module `settings` is for convenience/error checking
-- Using the module `ui` is for convenience

require('settings');
require('ui');

local MAX_INT_VALUE = 2147483647;

local function Card(cardName, hasDuration, defaults, cardDesc, extraSettings)
	-- absoluteMax values tested against game card settings while maxing single player game

	if type(defaults) ~= 'table' then
		defaults = {NumPieces = defaults};
	end

	if type(extraSettings) ~= 'table' then
		extraSettings = {};
	end

	local cardGameSettingsMap = {
		NumPieces = cardName .. 'NumPieces',
		MinimumPiecesPerTurn = cardName .. 'MinimumPiecesPerTurn',
		InitialPieces = cardName .. 'InitialPieces',
		Weight = cardName .. 'Weight'
	};

	local settings = {
		addSetting(cardName .. 'NumPieces', 'Number of pieces to divide the card into', 'int', defaults.NumPieces, {
			minValue = 1,
			maxValue = 20,
			absoluteMax = MAX_INT_VALUE
		}),
		addSetting(cardName .. 'Weight', 'Weight', 'float', defaults.Weight or 1, {
			dp = 10,
			minValue = 0,
			maxValue = 5,
			absoluteMax = 8999999488,
			help = function(parent)
				Label(parent).SetText('How common the card is');
			end
		}),
		addSetting(cardName .. 'MinimumPiecesPerTurn', 'Minimum pieces awarded per turn', 'int', defaults.MinimumPiecesPerTurn or 1, {
			minValue = 0,
			maxValue = 5,
			absoluteMax = 1000
		}),
		addSetting(cardName .. 'InitialPieces', 'Pieces given to each player at the start', 'int', defaults.InitialPieces or 0, {
			minValue = 0,
			maxValue = 5,
			absoluteMax = 50
		})
	};

	if hasDuration then
		local durationSetting = addSetting(
			cardName .. 'ActiveOrderDuration',
			'Number of turns that the card will last',
			'int',
			defaults.ActiveOrderDuration or 1,
			{
				minValue = 1,
				maxValue = 10,
				absoluteMax = MAX_INT_VALUE
			}
		);

		cardGameSettingsMap.ActiveOrderDuration = durationSetting.name;
		cardGameSettingsMap.ActiveCardExpireBehavior = defaults.ActiveCardExpireBehavior or WL.ActiveCardExpireBehaviorOptions.EndOfTurn;

		table.insert(settings, durationSetting);
	end

	for _, extraSetting in ipairs(extraSettings) do
		table.insert(settings, extraSetting);
	end

	return addSetting(cardName .. 'sEnabled', 'Enable ' .. cardName .. 's', 'bool', false, {
		help = function(parent)
			Label(parent).SetText(cardDesc);
		end,
		subsettings = {
			addCustomCard(
				cardName .. 'ID',
				cardName,
				cardDesc,
				cardName .. '.png',
				cardGameSettingsMap,
				settings
			)
		}
	});
end

function getSettings()
	local start = WL.ActiveCardExpireBehaviorOptions.BeginningOfNextTurn;

	return {
		Card('Immobilize Card', true, {NumPieces = 6, ActiveOrderDuration = 1, ActiveCardExpireBehavior = start}, 'Prevents attacks/transfers and airlifts to and from a territory. The territory must be one of yours or connected to one of yours.'),
		Card('Reconnaissance+ Card', true, {NumPieces = 3, ActiveCardExpireBehavior = start}, 'Like a Reconnaissance Cards, but with a customizable range.', {
			addSetting('Reconnaissance+ CardRange', 'Range', 'int', 1, {
				minValue = 0,
				maxValue = 5-- capped at 5 for performance reasons
			}),
			addSetting('Reconnaissance+ CardRandomAutoplay', 'Automatically randomly play this card', 'bool', false, {
				help = function(parent)
					Label(parent).SetText('If enabled, the card will be be played by Neutral and a random territory will be chosen to play the card on');
					Label(parent).SetText('All players will be able to see the territories made visible');
					Label(parent).SetText('Players will not be able to play the card themselves');
					Label(parent).SetText('Discarding the card can be used to stay within the maximum cards held limit');
					-- not possible to prevent discard unless ignore all discard card orders
					-- or use a very hacky workaround
					Label(parent).SetText('As the turn advances, discarding the card will prevent Neutral from playing the card');
					Label(parent).SetText('Note that when Neutral plays the card, the name of the card owner is mentioned in order details');
				end
			})
		}),
		Card('Recycle Card', false, 7,'Sets the number armies on a territory of your choice that belongs to you to be the amount that was on it on the first turn, and changes the owner to neutral. The armies that used to be on the territory get added to your income.', {
			addSetting('Recycle CardEliminateIfCommander', 'Recycling Commander causes elimination', 'bool', false, {
				help = function(parent)
					Label(parent).SetText('If a Recycle Card was played on a territory with at least one Commander, should the players owning the Commanders on the territory be eliminated?');
				end
			})
		}),
		Card('Rushed Blockade Card', false, 10, 'Similar to Blockade Cards but happen during the attacks phase. Allows you to attack a territory then blockade it during the same turn. Can also be used like a regular Blockade Card.', {
			addSetting('Rushed Blockade CardMultiplier', 'Multiplier', 'float', 3, {
				dp = 2,
				minValue = 0,
				maxValue = 500
			}),
			addSetting('Rushed Blockade CardEliminateIfCommander', 'Rush blockading Commander causes elimination', 'bool', true, {
				help = function(parent)
					Label(parent).SetText('If a Rushed Blockade Card was played on a territory with at least one Commander, should the players owning the Commanders on the territory be eliminated?');
				end
			})
		}),
		-- having a duration for Trap Card would be nice. they're like opposites in activation
		Card('Trap Card', false, 13, 'Similar to Blockade Cards but triggered by an enemy capturing the territory where the card was played. Trap Cards must be played on one of your own territories.', {
			addSetting('Trap CardMultiplier', 'Multiplier', 'float', 3, {
				help = function(parent)
					Label(parent).SetText('Surviving attacking armies are multiplied by this number and the territory becomes neutral');
				end,
				dp = 2,
				minValue = 0,
				maxValue = 8,
				absoluteMax = 500
			}),
			addSetting('Trap CardEliminateIfCommander', 'Trapping Commander causes elimination', 'bool', true, {
				help = function(parent)
					Label(parent).SetText('If any armies taking over a territory where a Trap Card was played were Commanders, should the players owning them be eliminated?');
				end
			})
		})
	};
end
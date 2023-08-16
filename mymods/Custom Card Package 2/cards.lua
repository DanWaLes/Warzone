local function requireCards()
	local cardNames = getCardNames();

	for _, cardName in pairs(cardNames) do
		require(cardName);
	end
end

function getCardNames()
	return {
		'Reconnaissance+',
		'Trap'
	};
end

function getCardsThatCanBeActive()
	return {
		Trap = true
	};
end

requireCards();
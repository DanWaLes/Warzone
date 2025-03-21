function sanitizeCardName(cardName)
	-- for when _G is used to call card-related functions

	return string.gsub(cardName, '[^%w_]', '');
end

function addDuration(card)
	local duration = card.ActiveOrderDuration;

	if not (duration and duration > 0) then
		return '';
	end

	local str = ' for ' .. ((isHackyDuration and 'up to ') or '') .. duration .. ' turn';

	if duration > 1 then
		str = str .. 's';
	end

	return str;
end
function round(n, dp)
	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end

function indexOf(array, toFind)
	if not array then
		return 0;
	end

	for i, value in ipairs(array) do
		if value == toFind then
			return i;
		end
	end

	return -1;
end
require('tblprint');

function Client_GameRefresh(game)
	if not game.Us then
		return;
	end

	if game.Us.State == WL.GamePlayerState.Playing then
		return;
	end
end

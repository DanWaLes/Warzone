-- list territories that have been done and on which turn. let territories be clickable
require '_ui';

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(400, 200);

	local vert = Vert(rootParent);

	if not game.Settings.MapTestingGame then
		Label(vert).SetText('This mod can only be used in map testing games');
		return;
	end

	local numTerrs = #Mod.PublicGameData.terrNames;

	Label(vert).SetText('All territory connections will tested by the end of turn ' .. math.ceil(numTerrs / Mod.PublicGameData.numPlayers));
	Label(vert).SetText('By end of this turn tested ' .. Mod.PublicGameData.terrNo - 1 .. ' / ' .. numTerrs .. ' territories');
end
function Client_GameRefresh(game)
	if Mod.PublicGameData.changed then
		require 'Client_PresentMenuUI'

		game.CreateDialog(Client_PresentMenuUI);
	end
end
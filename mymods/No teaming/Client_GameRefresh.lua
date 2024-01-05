function Client_GameRefresh(game)
	if not game.Us or Mod.PlayerGameData.seenWarning then
		return;
	end

	UI.Alert('WARNING - the game creator can:\r\nEliminate players\r\nSpy on all players\r\n\r\nFor more info see Game > Game Settings and Game > Mod: No colluding.');

	game.SendGameCustomMessage('Making WARNING as read...', {markWarningAsRead = true}, function() end);
end
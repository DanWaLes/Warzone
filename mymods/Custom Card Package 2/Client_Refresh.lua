-- require '_util';

function Client_Refresh(game)
	print('init Client_Refresh');
	if not (game.Us and game.Us.State == WL.GamePlayerState.Playing) then
		print('not playing');
		return;
	end

	local playerGD = Mod.PlayerGameData;

	if not playerGD.prefShowReceivedCardsMsg then
		print('not prefShowReceivedCardsMsg');
		return;
	end

	if playerGD.prefShowReceivedCardsMsg and playerGD.shownReceivedCardsMsg) then
		print('shownReceivedCardsMsg already done');
		return;
	end

	print('Showing received cards msg');
	UI.Alert('You' .. (game.Us.Team == -1 and ' have' or 'r team has') .. ' some full card pieces. Go to Game > Mod: Custom Card Package 2 to use them.');
	game.SendGameCustomMessage('Acknowledging received cards message viewed...', {
		PlayerGameData = {
			shownReceivedCardsMsg = true
		}
	});
end
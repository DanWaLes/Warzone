function Client_GameRefresh(game)
	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher('5.22')) then
		UI.Alert('You must update your app to the latest version to use this mod');
	end
end
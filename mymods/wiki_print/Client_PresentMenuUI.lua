require '_util';

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	placeOrderInCorrectPosition(game, WL.GameOrderCustom.Create(game.Us.ID, 'message', 'payload', {[WL.ResourceType.Gold] = 1}));
end
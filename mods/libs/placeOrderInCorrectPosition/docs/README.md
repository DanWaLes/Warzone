This is reusable code for inserting an order into the orders list.

* `placeOrderInCorrectPosition(clientGame, newOrder)`
   * Arguments:
     * `clientGame` - [ClientGame](https://www.warzone.com/wiki/Mod_API_Reference:ClientGame) - the game, which is used to modify the orders list
     * `newOrder` - [GameOrder](https://www.warzone.com/wiki/Mod_API_Reference:GameOrder) - the order to add to the orders list. It is added as the last order in the orders list for its phase, or as the last order in the orders list if the order can occur doing any phase.
   * Returns: void

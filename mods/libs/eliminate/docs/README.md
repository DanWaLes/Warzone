This is reusable code for generating [TerritoryModification orders](https://www.warzone.com/wiki/Mod_API_Reference:TerritoryModification) that turn player territories neutral and the option of removing all special units belonging to them. The territory modifications can later be added to a [GameOrderEvent](https://www.warzone.com/wiki/Mod_API_Reference:GameOrderEvent).

* `eliminate(playerIds, territories, removeSpecialUnits, isSinglePlayer)`
  * Note: this function requires the use of [server version 5.22 or later](https://github.com/DanWaLes/Warzone/tree/master/mods/libs/version) to make territory modifications that remove special units if there are any special units that should be removed
  * Arguments:
    * `playerIds` - array of [PlayerID](https://www.warzone.com/wiki/Mod_API_Reference:PlayerID) - the players to eliminate
    * `territories` - [GameStanding.Territories](https://www.warzone.com/wiki/Mod_API_Reference:GameStanding) - a reference to the territories in the game
    * `removeSpecialUnits` - boolean - decides if all special units belonging to players in `playerIds` can be removed
    * `isSinglePlayer` - boolean - pass [Game](https://www.warzone.com/wiki/Mod_API_Reference:Game).[Settings](https://www.warzone.com/wiki/Mod_API_Reference:GameSettings).SinglePlayer as the value. Used for checking if special units can be removed. Special units will not be removed if the game is single player and the client's app version is less than 5.22. There will not be a crash
  * Returns: array of TerritoryModification
Allows mods to easily to guide players to select territories or bonuses. Players can click on the map and click on listed options. Each listed option has a view territory/bonus button. Players can search in the list. Searching uses a case-insensitive 'fuzzy match' (Levenshtein distance).

* `TerritorySelectionMenu(vert, terrValidation, wz)`
  * Arguments:
    * `vert` - a vertical layout group UI element which is used as the parent element for making the menu
    * `terrValidation` - table - with keys:
      * `displayTerrSelectionWarning` - nil or `function(wz, parent)`
        * Adds a way for any kind of restrictions to be mentioned when selecting a territory
        * Arguments:
        * `wz` - same as `wz` in `TerritorySelectionMenu`
        * `parent` - a vertical layout group UI element
      * `isValidTerr` - `function(terrDetails, wz)`
        * Adds a way for territories not be chosen
        * Arguments:
          * `terrDetails` - [TerritoryDetails](https://www.warzone.com/wiki/Mod_API_Reference:TerritoryDetails) - the territory that was selected
          * `wz` - same as `wz` in `TerritorySelectionMenu`
        * Returns - any - truthy values means the territory can be chosen
      * `onValidTerr` - `function(terrDetails, wz)`
        * Adds a way for doing something when a valid territory is selected
        * Arguments:
          * `terrDetails` - [TerritoryDetails](https://www.warzone.com/wiki/Mod_API_Reference:TerritoryDetails) - the territory that was selected
          * `wz` - same as `wz` in `TerritorySelectionMenu`
      * `onInvalidTerr` - `function(terrDetails, wz, parent)`
        * Adds a way for displaying an error message when an invalid territory is selected
        * Displayed underneath the warning message
        * Arguments:
          * `terrDetails` - [TerritoryDetails](https://www.warzone.com/wiki/Mod_API_Reference:TerritoryDetails) - the territory that was selected
          * `wz` - same as `wz` in `TerritorySelectionMenu`
          * `parent` - a vertical layout group UI element
    * `wz` - table - used for giving access to variables for functions in `terrValidation`
      * Must have key:
        * `game` - [ClientGame](https://www.warzone.com/wiki/Mod_API_Reference:ClientGame)
* `BonusSelectionMenu(vert, bonusValidation, wz)`
  * Arguments:
    * `vert` - a vertical layout group UI element which is used as the parent element for making the menu
    * `bonusValidation` - table - with keys:
      * `displayBonusSelectionWarning` - nil or `function(wz, parent)`
        * Adds a way for any kind of restrictions to be mentioned when selecting a bonus
        * Arguments:
        * `wz` - same as `wz` in `BonusSelectionMenu`
        * `parent` - a vertical layout group UI element
      * `isValidBonus` - `function(bonusDetails, wz)`
        * Adds a way for bonuses not be chosen
        * Arguments:
          * `bonusDetails` - [BonusDetails](https://www.warzone.com/wiki/Mod_API_Reference:BonusDetails) - the bonus that was selected
          * `wz` - same as `wz` in `BonusSelectionMenu`
        * Returns - any - truthy values means the bonus can be chosen
      * `onValidTerr` - `function(bonusDetails, wz)`
        * Adds a way for doing something when a valid bonus is selected
        * Arguments:
          * `bonusDetails` - [BonusDetails](https://www.warzone.com/wiki/Mod_API_Reference:BonusDetails) - the bonus that was selected
          * `wz` - same as `wz` in `BonusSelectionMenu`
      * `onInvalidTerr` - `function(bonusDetails, wz, parent)`
        * Adds a way for displaying an error message when an invalid bonus is selected
        * Displayed underneath the warning message
        * Arguments:
          * `bonusDetails` - [BonusDetails](https://www.warzone.com/wiki/Mod_API_Reference:BonusDetails) - the bonus that was selected
          * `wz` - same as `wz` in `BonusSelectionMenu`
          * `parent` - a vertical layout group UI element
    * `wz` - table - used for giving access to variables for functions in `bonusValidation`
      * Must have key:
        * `game` - [ClientGame](https://www.warzone.com/wiki/Mod_API_Reference:ClientGame)

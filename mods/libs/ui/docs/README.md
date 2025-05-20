Defines global shorthand function names for [UI elements](https://www.warzone.com/wiki/Mod_API_Reference:UI#UI_Elements) without needing the UI.* prefix as well as adding utility function(s). In each function, `parent` is a UI element.
# Shorthand UI Element functions
* `Empty(parent)` - returns `UI.CreateEmpty(parent)`
* `Vert(parent)` - returns `UI.CreateVerticalLayoutGroup(parent)`
* `Horz(parent)` - returns `UI.CreateHorizontalLayoutGroup(parent)`
* `Label(parent)` - returns `UI.CreateLabel(parent)`
* `Btn(parent)` - returns `UI.CreateButton(parent)`
* `Checkbox(parent)` - returns `UI.CreateCheckBox(parent)`
* `RadioBtn(parent, group)` - returns `UI.CreateRadioButton(parent).SetGroup(group)`
  * Note: this function requires the use of [version 5.34 or later](https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features) to function correctly
  * If `group` is falsey, `.SetGroup(group)` will not be called
* `RadioBtnGroup(parent)` - returns `UI.CreateRadioButtonGroup(parent)`
  * Note: this function requires the use of [version 5.34 or later](https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features) to function correctly
* `TextInput(parent)` - returns `UI.CreateTextInputField(parent)`
* `NumInput(parent)` - returns `UI.CreateNumberInputField(parent)`
# Utility Functions
* `Tabs(parent, dir, tabLabels, tabsClicked)`
  * Note: this function requires the use of [version 5.21 or later](https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features) to function correctly
  * Arguments:
    * `parent` - UI element - the parent element
    * `dir` - UI element - should be a reference to `Vert` or `Horz`. Used to decide the direction of tab, like horizontal or vertical alignment
    * `tabLabels` - array of string (where ordering must be same as `tabsClicked`) - which is the text to display as the tab name, for each tab. The text is displayed on a button
    * `tabsClicked` - array of `function(tabData)` (where ordering must be same as `tabLabels`) - an event handler for when a `tabLabel` is clicked. When a tab is clicked, its button's interactable state is changed to match if the current tab of `tabLabels` is the selected tab. When a tab is selected, its content is created using the function defined in the array. When a tab is not selected, its content is destroyed
  * Returns: `tabData`
  * `tabData` - table - with the following fields:
    * `tabsContainer` - UI element - set to `dir(container)`. `container` is `parent` or `Horz(parent)` if `dir` is `Vert`
    * `tabBtns` - table - indexed by `tabLabel` - refers to the tab button for that tab label
    * `selectedTab` - nil or string - a `tabLabel`, no default
    * `tabContents` - UI element - set to `Vert(container)`. `container` is `parent` or `Horz(parent)` if `dir` is `Vert`
* `HighlightTerrBtn(game, terrId, parent)`
  * Note: this function requires the use of [version 5.21 or later](https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features) to function correctly
  * Arguments:
    * `game` - ClientGame
    * `terrId` - TerritoryID - ID of the territory to highlight
    * `parent` - UI element - the parent element
* `HighlightBonusBtn(game, bonusId, parent)`
  * Note: this function requires the use of [version 5.21 or later](https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features) to function correctly
  * Arguments:
    * `game` - ClientGame
    * `bonusId` - BonusID - ID of the bonus to highlight
    * `parent` - UI element - the parent element
* `CustomCardHelpButton(card, btnParent, helpContentParent)`
  * Makes a label with text `card`.Name and a ? help button (on the same line) that, when clicked, shows the custom card description beneath the label and help button
  * Note: this function requires the use of [version 5.32.0.1 or later](https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features) to function correctly
  * Arguments:
    `card` - CardGameCustom
    `btnParent` - UI element
<<<<<<< HEAD
    `helpContentParent` - UI element
=======
    `helpContentParent` - UI element
>>>>>>> origin/main

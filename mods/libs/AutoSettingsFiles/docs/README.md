The goal of this is to automatically generate the Client_PresentConfigureUI, Client_SaveConfigureUI and Client_PresentSettingsUI Lua files. All files other than __settings.lua are not meant to be edited. __settings.lua is where to define settings.
# __settings.lua
The file must have a `getSetting` function. returns array of `setting`. `setting` is a table which is generated from the `addSetting`, `addSettingTemplate` and `addSettingGroup` functions
## addSetting
* `name` - string - name of the setting. all names must be unique to function correctly
* `label` - string - summery of what the setting does
* `inputType` - string - one of `'int'`, `'float'`, `'bool'`, `'text'` or `'radio'`
* `defaultValue` - same type as `inputType` - the default value for the setting's value in Client_PresentConfigureUI
* `otherProps` - table or nil - if table then these keys are optional:
  * `help` - `function(parent)` - gives a more detailed explanation of what the setting does when a help button (?) is clicked
  * `labelColor` - string - color of the setting's label
  * `bkwards` - same type as what is used in `defaultValue` or nil - the value to use in setting menus if Mod.Settings\[`name`\] is `nil`
### inputType
Depending on the `inputType` certain keys on `otherProps` are forced and some become optional
#### int
Forced keys:
* `minValue` - number - the lowest the setting's value can be
* `maxValue` - number - the highest the setting's value can be while using the setting slider
Optional keys:
* `absoluteMax` - number - allows user to enter a higher number than `maxValue`
* `absoluteMin` - number - allows user to enter a lower number than `minValue`
#### float
Forced keys:
* `dp` - number - the number of decimal places to round the setting's value when saving the settings
* `minValue` - number - the lowest the setting's value can be
* `maxValue` - number - the highest the setting's value can be while using the setting slider
Optional keys:
* `absoluteMax` - number - allows user to enter a higher number than `maxValue`
* `absoluteMin` - number - allows user to enter a lower number than `minValue`
#### bool
Optional keys:
* `subsettings` - table or nil. if table then is an array of `setting`
#### text
Optional keys:
* `placeholder` - string - the placeholder text
* `charLimit` - number - the maximum number of characters that can be entered
### radio
This makes a group of checkboxes where only one checkbox can be checked at any time. `defaultValue` and `otherProps.bkwards` (if specified) must be a number index that can be indexed by `controls`. `defaultValue` becomes the initial checkbox to check. The value of the setting  is saved as the index of the currently selected `control`.

Forced keys:
* `controls` - array of `control` - details about the checkbox listed under `label`

`control` - string (treated as table with key `label`) or table with keys:
* `label` - string - summary of what the radio button does
* `labelColor` - string or nil - color of `label` text
* `labelHelp` - `function(parent)` or nil - gives a more detailed explanation of what the control does when a help button (?) is clicked
## addSettingTemplate
In the event of wanting to have infinite groups of settings, setting templates can be used.

Arguments:
* `name` - string - name of the setting. all names must be unique to function correctly
* `btnText` - string - text that goes on a button that user presses to add a new group of settings
* `options` - nil or table with keys:
  * `btnColor` - nil or string - color of the button; nil = #00FF05
  * `btnTextColor` - nil or string - color of `btnText`; nil = wz default
  * `bkwrds` - nil or int - for if the mod is public and goes from limited to unlimited amounts of setting groups. `bkwrds` number of setting groups will be generated. to avoid nil in Client_PresentSettingsUI
* `get(n)` - function - `n` starts at 1. `get` must return table with keys:
  * `label` - string - description of the setting group
  * `labelColor` - nil or string - color of the label; nil = wz default
  * `settings` - array of `setting`
## addSettingGroup
Makes a button that, when clicked, shows or hides `settings`. Similar to using `addSetting` with `inputType` `'bool'` which has `subsettings`, but is a button rather than a checkbox.`
* `btnTxt` - string - the text to show on the button
* `options` - nil or table - has optional fields which are not applied unless they are truthy:
  * `btnColor` - string - sets the color of the button itself
  * `btnTextColor` - string - sets the color of `btnTxt`
  * `onExpand` - nil or function(btn, parent) - called whenever the contents of the button is shown. `btn` is the button itself. `parent` is a new vertical layout group, which is shown just above rendered `settings`.
* `settings` - array of `setting`
# Accessing setting values
Each setting is written to Mod.Settings\[`name`\]. `name` in `addSettingTemplate` is altered to only apply to the correct setting group. Use the `getSetting(name, template)` function defined in `settings.lua`, which returns the value stored in Mod.Settings.

Arguments:
* `name` - string - name of the setting, same as what was used in `addSetting` or `addSettingTemplate`
* `template` - nil or table - containing the following keys:
  * `n` - number - setting group number
  * `name` - string - the name of the setting template
# Examples
* [code/__settings.lua](https://github.com/DanWaLes/Warzone/blob/master/mods/libs/AutoSettingsFiles/code/__settings.lua)
* [AIs don't attack](https://github.com/DanWaLes/Warzone/tree/master/mymods/AIs%20dont%20attack/__settings.lua)
* [Advanced Card Distribution (per player)](https://github.com/DanWaLes/Warzone/tree/master/mymods/Advanced%20Card%20Distribution%20per%20player/__settings.lua)
* [Custom Card Package 2](https://github.com/DanWaLes/Warzone/tree/master/mymods/Custom%20Card%20Package%202/__settings.lua)
* [Random settings generator](https://github.com/DanWaLes/Warzone/tree/master/mymods/Random%20settings%20generator/__settings.lua)
* [Surveillance Card+](https://github.com/DanWaLes/Warzone/tree/master/mymods/Surveillance%20Card%2B/__settings.lua)
* [Swap Territories 2](https://github.com/DanWaLes/Warzone/tree/master/mymods/Swap%20Territories%203/__settings.lua)
* [Wastelands+](https://github.com/DanWaLes/Warzone/tree/master/mymods/Wastelands%2B)
## Screenshots
### Client_PresentConfigureUI.lua
![Start](imgs/Client_PresentConfigureUI.lua/1_start.png)
![Setting two checked](imgs/Client_PresentConfigureUI.lua/2_setting_two_checked.png)
![Add new setting template group clicked](imgs/Client_PresentConfigureUI.lua/3_add_new_setting_template_group_clicked.png)
![Help button clicked](imgs/Client_PresentConfigureUI.lua/4_help_button_clicked.png)
![Same help button clicked](imgs/Client_PresentConfigureUI.lua/5_same_help_button_clicked.png)
### Client_PresentSettingsUI.lua
![Start](imgs/Client_PresentSettingsUI.lua/1_start.png)
![Help button clicked](imgs/Client_PresentSettingsUI.lua/2_help_button_clicked.png)
![Same help button clicked](imgs/Client_PresentSettingsUI.lua/3_same_help_button_clicked.png)
![Expand collapse button clicked](imgs/Client_PresentSettingsUI.lua/4_expand_collapse_button_clicked.png)
![Same expand collapse button clicked](imgs/Client_PresentSettingsUI.lua/5_same_expand_collapse_button_clicked.png)
![Expand collapse button clicked](imgs/Client_PresentSettingsUI.lua/6_expand_collapse_button_clicked.png)

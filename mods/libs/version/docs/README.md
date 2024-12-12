The purpose of this is to correctly check that the mod will be able to run. The Mod API has been chanced since it was introduced (see the [Wiki](https://www.warzone.com/wiki/Mod_API_Reference#Newer_API_features) for details), so to prevent errors, check if the client can run the mod.

This has two files: __mod.lua and version.lua.
# __mod.lua
This file is used to get details about the mod so that a consistent error message can be displayed. It defines a global variable called <code>MOD</code> with three properties:
* `name` - string - name of the mod
* `clientVersion` - string - which version of Warzone the end-user needs to run to use the mod in Client_* hooks
* `serverVersion` - string - same as `clientVersion` but for Server_* hooks. Server_* hooks are ran on the end-user's device rather than on the Warzone servers in single player games, making this check necessary
# version.lua
This file has two callable functions:
* `canRunMod()` - returns boolean - use something like this at the start of every client hook: `if not canRunMod() then return end`
* `serverCanRunMod(game)` - `game` is a [https://www.warzone.com/wiki/Mod_API_Reference:ServerGame](ServerGame) - returns boolean - use something like this at the start of every server hook: `if not serverCanRunMod(game) then return end`

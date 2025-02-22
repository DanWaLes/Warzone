This adds a collection of reusable functions that can be used in any Lua project. There are no Warzone-specific utility functions included. Which files to include should be done on an as-needed basis to reduce overheads.

There are currently two files:
* number_util.lua
* string_util.lua

# number_util.lua
* `round(n, dp)`
  * Rounds a number (`n`) to `dp` decimal places
  * Arguments:
    * `n` - number - the number to round
    * `dp` - number - the amount of decimal places to round to
  * Returns: number

# string_util.lua
* `startsWith(str, sub)`
  * Checks if a string begins with another string (not a [pattern](https://www.lua.org/pil/20.2.html))
  * Arguments:
    * `str` - string - the full string to compare against the substring
    * `sub` - string - the substring to compare against the full string
  * Returns: boolean

* `split(str, separator)`
  * Globally matches parts of a string that do not match a separator then returns an array of the results
  * Arguments:
    * `str` - string - the string to split
    * `separator` - string or falsey - the [pattern](https://www.lua.org/pil/20.2.html) to split the string using. If this is falsey then `'%s'` is used.
  * Returns: array of string

* `escapePattern(str)`
  * Escapes special characters used in patters so that they can be used as a plain character with no special meaning
  * Arguments:
    * `str` - string - the [pattern](https://www.lua.org/pil/20.2.html) to escape
  * Returns: string

* `toCaseInsensitivePattern(str)`
  * Makes a [pattern](https://www.lua.org/pil/20.2.html) case-insensitive by replacing `'%a'` characters with their lowercase and uppercase form
  * Arguments:
    * `str` - string - the pattern to make case-insensitive
  * Returns: string

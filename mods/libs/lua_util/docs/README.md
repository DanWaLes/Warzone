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

* `aAn(str, join)`
  * Decides if a word should be refereed to as 'a' or 'an' because of the word starting with a consonant or vowel
  * Arguments:
    * `str` - string - the text for checking if it should be referred to as 'a' or 'an'
    * `join` - boolean - if truthy a space and `str` will be appended to 'a' or 'an'
<<<<<<< HEAD
  * Returns: string
=======
  * Returns: string
>>>>>>> origin/main

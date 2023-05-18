# exTcl 0.1 documentation

- **locjoin** - Joins lists for localized messages.

  **Syntax:**
  `locjoin list word`

  **Examples:**
  `locjoin { foo bar baz } and`
  returns "foo, bar and baz"

  `locjoin { yes no } or`
  returns "yes or no"

  it supports commas in separator words
  `locjoin { 1 2 3 } ", or"`
  returns "1, 2, or 3"


- **getopt** - Parses options in arguments

  **Syntax:**
  `getopt optOutputVarName opts ?arg...`

  `optOutputVarName` is the variable name that will store options parsed from given arguments. The variable it points to can be either an array or a dictionary.

  `opts` is a dictionary where key is the option name and value is a list of value types accepted by that option (an empty list is supported). Elements of such lists need to be: string classes, "string"/"any" values or nested lists starting with "enum"/"glob"/"regexp" value followed by allowed values. "enum"/"glob"/"regexp" all act as enums, but they differ how values are compared: they use -exact, -glob, -regexp comparisons, respectively.

  The arguments that are parsed are given after `optOutputVarName` and `opts`.
  Returned value is a list of arguments with options left out.
  If the input is invalid (whether opts or parsed args are invalid) it throws appropriate error.

  Boolean options are saved as `true` in the array/dictionary pointed by `optOutputVarName`.

  **Examples:**
  ```Tcl
  proc llast args {
    array set flags { index false }
    set args        [getopt flags { index {} } {*}$args]

    if { [llength $args] != 1 } {
      error "wrong # args: should be \"llast ?-index? listValue\""
    }

    set listValue [lindex $args 0]
    set i         [expr {[llength $listValue] - 1}]

    if { !$flags(index) } {
      return [lindex $listValue $i]
    }

    if { $i < 0 } {
      return 0
    }

    return $i
  }
  ```

  The example above creates a function with `llast ?-index? listValue` syntax. When `-index` is provided the function returns the last index that can be set by `lset`. Otherwise it will return the last element of a list.

  Examples of opts:
  ```Tcl
  {
    foo {}
    bar { any any }
    baz { { enum 1 2 } }
  }
  ```

  It means that accepted options are: `?-foo? ?-bar value1 value2? ?-baz 1/2?`

  `{ n integer }`

  ...is interpreted as `?-n integerValue?`

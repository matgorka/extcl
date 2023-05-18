# exTcl 0.1 documentation

- ***lingjoin*** - Linguistic join. Joins lists for user messages.

  **Syntax:**

  `lingjoin list word`

  **Examples:**

  `lingjoin { foo bar baz } and`

  returns "foo, bar and baz".

  `lingjoin { yes no } or`

  returns "yes or no".

  It supports commas in separator words:

  `lingjoin { 1 2 3 } ", or"`

  returns "1, 2, or 3".


- ***getopt*** - Parses options in arguments.

  **Syntax:**

  `getopt optOutputVarName opts ?arg...`

  `optOutputVarName` is the variable name that will store options parsed from given arguments. The variable it points to can be either an array or a dictionary.

  `opts` is a dictionary where key is the option name and value is a list of value types accepted by that option (an empty list is supported). Elements of such lists need to be: string classes, "string"/"any" values, or nested lists starting with "enum"/"glob"/"regexp" value followed by allowed values. "enum"/"glob"/"regexp" all act as enums, but they differ in how values are compared: they use -exact, -glob, and -regexp comparisons, respectively.

  The arguments that are parsed are given after `optOutputVarName` and `opts`.
  The returned value is a list of arguments with options left out.
  If the input is invalid (whether opts or parsed args are invalid), it throws an appropriate error.

  Boolean options are saved as `true` in the array/dictionary pointed to by `optOutputVarName`.

  **Examples:**

  ```Tcl
  proc llast args {
    array set flags { index false }
    set args        [getopt flags { index {} } {*}$args]

    if { [llength $args] != 1 } {
      error "wrong # args: should be \"llast ?-index? listValue\""
    }

    set listValue [lindex $args 0]

    if { !$flags(index) } {
      return [lindex $listValue end]
    }

    set i [expr {[llength $listValue] - 1}]

    if { $i < 0 } {
      return 0
    }

    return $i
  }
  ```

  The example above creates a command with the `llast ?-index? listValue` syntax. By default, it returns the last element of a list. When `-index` is provided, the command returns the index of the last element that can be replaced by `lset`.

  Examples of opts:
  ```Tcl
  {
    foo {}
    bar { any any }
    baz { { enum 1 2 } }
  }
  ```

  It means that accepted options are: `?-foo? ?-bar value1 value2? ?-baz 1/2?`.

  `{ n integer }`

  ...is interpreted as `?-n integerValue?`.


- ***lpopl*** - Pops value(s) from the beginning of a list.

  ***lpopr*** - Pops value(s) from the end of a list.

  **Syntax:**

  `lpopl listVarName ?n?`

  `lpopr listVarName ?n?`

  `lpopl` and `lpopr` delete `n` elements from the beggining/end of a list pointed by `listVarName` and return these deleted elements. If the `n` value isn't specified, it defaults to 1 element.

  **Examples:**

  ```Tcl
  set foo [list 1 2 3]
  puts [lpopl foo]     ;# displays 1
  puts $foo            ;# displays 2 3
  ```

  ```Tcl
  set foo [list 1 2 3]
  puts [lpopr foo]     ;# displays 3
  puts $foo            ;# displays 1 2
  ```


- ***ldelete*** - Deletes values from a given range of a list.

  **Syntax:**

  `ldelete list first last`

  `ldelete` accepts the same arguments as `lrange` but has a functionally reversed behavior. It deletes the specified range and returns the remaining part of a list.

  ```Tcl
  set foo [list A B C]
  puts [lrange $foo 1 1]  ;# displays B
  puts [ldelete $foo 1 1] ;# displays A C
  ```


- ***ldelete!***

  ***lrange!***

  ***linsert!***

  ***Syntax:***

  `ldelete! listVarName first last`

  `lrange! listVarName first last`

  `linsert! listVarName index ?element...`

  These are sister commands to exTcl's `ldelete` and Tcl standard commands: `lrange` and `linsert`. Their syntax is almost the same as their original counterparts, with a slight change: the first argument isn't a list but a variable name of a list. These commands with *bang* mutate the variable (their naming convention is inspired by Scheme).

  They are shorthands for already existing functionality:

  ```Tcl
  set foo [list B C]
  set foo [linsert $foo 0 A]
  ```

  vs

  ```Tcl
  set foo [list B C]
  linsert! foo 0 A
  ```

  etc...

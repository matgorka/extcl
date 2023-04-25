proc locjoin { listValue word } {
  set listValue [join $listValue ", "]
  set commaI    [string last , $listValue]

  if { [string index $word 0] != "," } {
    set word " $word"
  }

  return [string replace $listValue $commaI $commaI $word]
}

proc getopt { optOutputVarName opts args } {
  upvar $optOutputVarName optOutput

  if [array exists optOutput] {
    set setCommand { array set optOutput "{$key} {$value}" }
  } else {
    set setCommand { dict set optOutput $key $value }
  }

  if { [llength $opts] > 0 } {
    set validOpts [lmap optKey [dict keys $opts] {expr {"-$optKey"}}]
    set validOpts "must be [locjoin $validOpts or]"
  } else {
    set validOpts "no options supported"
  }

  set result    ""
  set key       ""
  set value     ""
  set optArgs   ""
  set i         0
  set n         1

  foreach arg $args {
    if { $i == $n } {
      if { $n == 0 } {
        set value true
      }

      eval $setCommand
      set key   ""
      set value ""
      set i     0
      set n     1      ;# 1 because we don't want this code to be executed
                        # on every iteration of the loop, this dummy value will
                        # be replaced when an option is given
    }

    if { $key != "" } {
      set optArg [lindex $optArgs $i]

      switch [llength $optArg] {
        0 {
          error "bad class: cannot be an empty string"
        }

        1 {
          if {
            $optArg != "string" &&
            $optArg != "any" &&
            ![string is $optArg $arg]
          } {
            error "bad -$key value \"$arg\": must be of $optArg class"
          }
        }

        default {
          set firstArg [lindex $optArg 0]

          switch $firstArg {
            enum {
              set lsearchOpt -exact
            }

            glob -
            regexp {
              set lsearchOpt -$firstArg
            }

            default {
              error "bad class: list was unexpected"
            }
          }

          set optValues [lrange $optArg 1 end]

          if { [lsearch $lsearchOpt $optValues $arg] == -1 } {
            error "bad -$key value \"$arg\": must be [locjoin $optValues or]"
          }
        }
      }

      lappend value $arg
      incr i
      continue
    }

    if { [string index $arg 0] == "-" } {
      set key [string range $arg 1 end]

      if [catch { dict get $opts $key } optArgs] {
        error "bad option \"$arg\": $validOpts"
      }

      set n [llength $optArgs]
      continue
    }

    lappend result $arg
  }

  if { $key != "" } {
    if { $i == $n } {
      eval $setCommand
    } else {
      if [expr { $n - $i > 1 }] {
        set s s
      } else {
        set s ""
      }

      error "value$s for \"-$key\" missing"
    }
  }

  return $result
}

proc linsert! { listVarName args } {
  upvar $listVarName list
  set list [linsert $list {*}$args]
}

proc ldelete { list first last } {
  if { $last < $first } {
    return $list
  }

  return [concat [lrange $list 0 $first-1] [lrange $list $last+1 end]]
}

proc ldelete! { listVarName args } {
  upvar $listVarName list
  set list [ldelete $list {*}$args]
}

proc lrange! { listVarName args } {
  upvar $listVarName list
  set list [lrange $list {*}$args]
}

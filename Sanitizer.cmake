# compiles with sanitizer:
#   cmake -DSANITIZER=Thread .

include(CMakeUtils)
include(AddCXXFlags)

if (NOT SANITIZER)
 return()
endif()

string(TOLOWER SANITIZER ${SANITIZER})

add_cxx_flags_checked(-fsanitize=${SANITIZER} VARNAME _var REQUIRED)
move_to_parent(${_var})

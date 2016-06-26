function(listx_append_prefix _outvar _prefix)

  foreach(_e ${ARGN})
  	list(APPEND _new "${_prefix}${_e}")
  endforeach()
  
  set(${_outvar} ${_new} PARENT_SCOPE)

endfunction()

function(listx_append_suffix _outvar _suffix)

  foreach(_e ${ARGN})
  	list(APPEND _new "${_e}${_suffix}")
  endforeach()
  
  set(${_outvar} ${_new} PARENT_SCOPE)

endfunction()


# feature detection

check_cxx_compiler_flags(_HAS_COMPILER_LTO FLAGS -flto)
if (NOT HAS_LTO_COMPILER)
  message(WARNING "Compiler has no link-time-optimization support")
  return()
endif()

execute_process(
    COMMAND ${CMAKE_AR} --help
    OUTPUT_VARIABLE _CMAKE_AR_HELP_OUTPUT
)
if (NOT _CMAKE_AR_HELP_OUTPUT MATCHES "plugin")
  message(WARNING "${CMAKE_AR} has no plugin support needed for link-time-optimization")
  unset(HAS_LTO_COMPILER)
  return()
endif()

execute_process(
    COMMAND ${CMAKE_LD} --help
    OUTPUT_VARIABLE _CMAKE_LD_HELP_OUTPUT
)
if (NOT _CMAKE_LD_HELP_OUTPUT MATCHES "plugin")
  message(WARNING "${CMAKE_LD} has no plugin support needed for link-time-optimization")
  return()
endif()

set(HAS_LTO_SUPPORT 1)

function(enable_lto _name)
  set(oneValueArgs CONFIG)
  set(multiValueArgs )
  set(prefix _enable_lto)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  if (NOT HAS_LTO_SUPPORT)
    return()
  endif()
  
  # build type
  
  if (${prefix}_CONFIG)
    set(_build_type_arg CONFIG ${${prefix}_CONFIG})
    set(_variant _${${prefix}_CONFIG})
  endif()
  
  # enable lto
  
  add_flags(
    C -flto
    CXX -flto
    LD -flto
    ${_build_type_arg}
  )
  
endfunction()

# enable function

function(enable_lto _name)
  set(oneValueArgs CONFIG)
  set(multiValueArgs )
  set(options REQUIRE)
  set(prefix _enable_lto)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  if (NOT HAS_LTO_SUPPORT)
    if (${prefix}_REQUIRE)
      message(ERROR "compiler or toolchain has no link-time-optimization support")
    endif()  
    return()
  endif()
  
  # build type
  
  if (${prefix}_CONFIG)
    set(_build_type_arg CONFIG ${${prefix}_CONFIG})
  endif()
  
  # enable lto
  
  add_flags(
    C -flto
    CXX -flto
    LD -flto
    ${_build_type_arg}
  )
  
endfunction()

# feature detection

check_cxx_compiler_flags(_HAS_COMPILER_LTO FLAGS -flto)
if (NOT _HAS_COMPILER_LTO)
  message(WARNING "Compiler has no link-time-optimization support")
  return()
endif()

execute_process(
    COMMAND ${CMAKE_AR} --help
    OUTPUT_VARIABLE _CMAKE_AR_HELP_OUTPUT
)
if (NOT _CMAKE_AR_HELP_OUTPUT MATCHES "-plugin")
  message(WARNING "${CMAKE_AR} has no plugin support needed for link-time-optimization")
  unset(_HAS_COMPILER_LTO)
  return()
endif()

execute_process(
    COMMAND ${CMAKE_LINKER} --help
    OUTPUT_VARIABLE _CMAKE_LD_HELP_OUTPUT
)
if (NOT _CMAKE_LD_HELP_OUTPUT MATCHES "-plugin")
  message(WARNING "${CMAKE_LINKER} has no plugin support needed for link-time-optimization")
  unset(_HAS_COMPILER_LTO)
  return()
endif()

set(HAS_LTO_SUPPORT 1)

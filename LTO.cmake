# 
# Copyright (c) 2016 R1tschY
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 


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

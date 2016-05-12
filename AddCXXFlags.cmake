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

include(CheckCXXCompilerFlag)
include(CMakeParseArguments)
include(CMakeUtils)

# add_cxx_flags("flag ..." [variant])
# adds flags to CMAKE_CXX_FLAGS or CMAKE_CXX_FLAGS_VARIANT
function(add_cxx_flags _flags)
  set(_variant ${ARGV1})
  if(_variant)
    string(TOUPPER "_${_variant}" _variant)
  endif()
  set(CMAKE_CXX_FLAGS${_variant} "${CMAKE_CXX_FLAGS${_variant}} ${_flags}" PARENT_SCOPE)
endfunction()

# check_cxx_compiler_flags(<var>
#   [FLAGS "-flag ..."]
#   [DEFINITIONS -DFOO=bar ...]
#   [INCLUDES <dir> ...]
#   [LIBRARIES <lib> ...]
#   [QUIET]
# )
# sets CMAKE_REQUIRED_* and calls check_cxx_compiler_flag
function(check_cxx_compiler_flags _var)

  # options
  set(options QUIET)
  set(oneValueArgs FLAGS)
  set(multiValueArgs DEFINITIONS INCLUDES LIBRARIES)
  set(prefix CMAKE_REQUIRED)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # check
  check_cxx_compiler_flag("" ${_var})

  # move _var to parent scope
  move_to_parent(${_var})

endfunction()

# add_cxx_flag_checked("flag ..." [build_type] [REQUIRED])
# add c++ compiler flag if compiler support it.
#
# if the flag is supported CMAKE_CXX_FLAGS is updated and HAVE_CXX_FLAG_<flag ...> is set
# if variant is set CMAKE_CXX_FLAGS_VARIANT is updated.
# if REQUIRED is set: an error is show when the flag is not supported
function(add_cxx_flag_checked _flag)
  string(TOUPPER "HAVE_CXX_FLAG_${_flag}" _haveFlagDef)
  string(REPLACE "+" "X" _haveFlagDef ${_haveFlagDef})
  string(REGEX REPLACE "[^A-Za-z0-9]+" "_" _haveFlagDef ${_haveFlagDef})

  set(prefix _add_cxx_flag_checked)
  cmake_parse_arguments(${prefix} "REQUIRED" "" "" ${ARGN})

  check_cxx_compiler_flags(${_haveFlagDef} FLAGS "${_flag}")
  if(${_haveFlagDef})
    set(VARIANT ${ARGV1})
    if(ARGV1)
      string(TOUPPER "_${VARIANT}" VARIANT)
    endif()
    set(CMAKE_CXX_FLAGS${VARIANT} "${CMAKE_CXX_FLAGS${VARIANT}} ${_flag}" PARENT_SCOPE)

  elseif(${prefix}_REQUIRED)
    message(ERROR "required flag `${_flag}' is not supported by c++ compiler")
  endif()

  move_to_parent(${_haveFlagDef})
endfunction()

# add_flags(
#   [CXX "-flag ..."]
#   [C "-flag ..."]
#   [CPP "-DDEFINE=0 ..."]
#   [LD "-flag ..."]
#   [BUILD_TYPE build_type]
# )
function(add_flags)

  # options

  set(options )
  set(oneValueArgs CXX C CPP LD BUILD_TYPE)
  set(multiValueArgs )
  set(prefix _add_flags)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # build type

  set(${prefix}_variant ${${prefix}_BUILD_TYPE})
  if(${prefix}_variant)
    string(TOUPPER "_${${prefix}_variant}" ${prefix}_variant)
  endif()

  # flags

  if (${prefix}_C)
    append(CMAKE_C_FLAGS${${prefix}_variant} " ${${prefix}_C}")
  endif()

  if (${prefix}_CXX)
    append(CMAKE_CXX_FLAGS${${prefix}_variant} " ${${prefix}_CXX}")
  endif()

  if (${prefix}_CPP)
    append(CMAKE_C_FLAGS${${prefix}_variant} " ${${prefix}_CPP}")
  	append(CMAKE_CXX_FLAGS${${prefix}_variant} " ${${prefix}_CPP}")
  endif()

  if (${prefix}_LD)
  	append(CMAKE_EXE_LINKER_FLAGS${${prefix}_variant} " ${${prefix}_LD}")
  	append(CMAKE_SHARED_LINKER_FLAGS${${prefix}_variant} " ${${prefix}_LD}")
  	append(CMAKE_MODULE_LINKER_FLAGS${${prefix}_variant} " ${${prefix}_LD}")
  endif()

  # scope

  move_to_parent(CMAKE_C_FLAGS${${prefix}_variant})
  move_to_parent(CMAKE_CXX_FLAGS${${prefix}_variant})
  move_to_parent(CMAKE_EXE_LINKER_FLAGS${${prefix}_variant})
  move_to_parent(CMAKE_SHARED_LINKER_FLAGS${${prefix}_variant})
  move_to_parent(CMAKE_MODULE_LINKER_FLAGS${${prefix}_variant})

endfunction()




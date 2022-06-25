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

include(CMakeParseArguments)
include(AddCXXFlags)

# set flags when using glibcxx
# glibcxx_flags(
#           [CONCEPT_CHECKS] [ASSERTIONS] [DEBUG] [DEBUG_PEDANTIC] [PARALLEL]
#           [PROFILE]
# )
# 
# see https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_macros.html
# 
function(glibcxx_flags)
    
  # options
    
  set(options CONCEPT_CHECKS ASSERTIONS DEBUG DEBUG_PEDANTIC PARALLEL PROFILE)
  set(oneValueArgs BUILD_TYPE)
  set(multiValueArgs )
  set(prefix _glibcxx_flags)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
 
  # build type
  
  if (${prefix}_BUILD_TYPE)
    set(_build_type_arg BUILD_TYPE ${${prefix}_BUILD_TYPE})
  endif()
  
  # flags
 
  foreach(flag ${options})
      if(${prefix}_${flag})
        add_flags(CPP "-D_GLIBCXX_${flag}" ${_build_type_arg})
      endif()
  endforeach()
 
  # scope

  move_to_parent(CMAKE_C_FLAGS)
  move_to_parent(CMAKE_CXX_FLAGS)
  move_to_parent(CMAKE_EXE_LINKER_FLAGS)
  move_to_parent(CMAKE_SHARED_LINKER_FLAGS)
  move_to_parent(CMAKE_MODULE_LINKER_FLAGS)
endfunction()
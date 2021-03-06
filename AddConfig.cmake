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
include(CMakeUtils)

function(add_config _name)
  set(oneValueArgs COPY_FROM C_FLAGS CXX_FLAGS LINKER_FLAGS EXE_LINKER_FLAGS SHARED_LINKER_FLAGS MODULE_LINKER_FLAGS STATIC_LINKER_FLAGS)
  set(prefix _add_config)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  string(TOUPPER "${_name}" _nameUpper)
  
  # copy flags from config from argument
  if (${prefix}_COPY_FROM)
    string(TOUPPER "${${prefix}_COPY_FROM}" _copyFrom)
    set(CMAKE_C_FLAGS_${_nameUpper} "${CMAKE_C_FLAGS_${_copyFrom}}")
    set(CMAKE_CXX_FLAGS_${_nameUpper} "${CMAKE_CXX_FLAGS_${_copyFrom}}")
    set(CMAKE_EXE_LINKER_FLAGS_${_nameUpper} "${CMAKE_EXE_LINKER_FLAGS_${_copyFrom}}")
    set(CMAKE_SHARED_LINKER_FLAGS_${_nameUpper} "${CMAKE_SHARED_LINKER_FLAGS_${_copyFrom}}")
    set(CMAKE_MODULE_LINKER_FLAGS_${_nameUpper} "${CMAKE_MODULE_LINKER_FLAGS_${_copyFrom}}")
    set(CMAKE_STATIC_LINKER_FLAGS_${_nameUpper} "${CMAKE_STATIC_LINKER_FLAGS_${_copyFrom}}") 
  else()
    set(CMAKE_C_FLAGS_${_nameUpper} "")
    set(CMAKE_CXX_FLAGS_${_nameUpper} "")
    set(CMAKE_EXE_LINKER_FLAGS_${_nameUpper} "")
    set(CMAKE_SHARED_LINKER_FLAGS_${_nameUpper} "")
    set(CMAKE_MODULE_LINKER_FLAGS_${_nameUpper} "")
    set(CMAKE_STATIC_LINKER_FLAGS_${_nameUpper} "") 
  endif()
  
  # set flags from arguments
  macro(_add_flags _flagsName _flags)
  	set(CMAKE_${_flagsName}_${_nameUpper} "${CMAKE_${_flagsName}_${_nameUpper}} ${_flags}")
  endmacro()
  macro(_optional_add_flags _flagsName)
  	if (${prefix}_${_flagsName})
			_add_flags(${_flagsName} "${${prefix}_${_flagsName}}")
		endif()
  endmacro()
  
  _optional_add_flags(C_FLAGS)
  _optional_add_flags(CXX_FLAGS)
  _optional_add_flags(EXE_LINKER_FLAGS)
  _optional_add_flags(SHARED_LINKER_FLAGS)
  _optional_add_flags(MODULE_LINKER_FLAGS)
  _optional_add_flags(STATIC_LINKER_FLAGS)
  
  if (${prefix}_LINKER_FLAGS)
  	_add_flags(EXE_LINKER_FLAGS "${${prefix}_LINKER_FLAGS}")
  	_add_flags(SHARED_LINKER_FLAGS "${${prefix}_LINKER_FLAGS}")
  	_add_flags(MODULE_LINKER_FLAGS "${${prefix}_LINKER_FLAGS}")
  endif()
  
  move_to_parent(CMAKE_C_FLAGS_${_nameUpper})
  move_to_parent(CMAKE_CXX_FLAGS_${_nameUpper})
  move_to_parent(CMAKE_EXE_LINKER_FLAGS_${_nameUpper})
  move_to_parent(CMAKE_SHARED_LINKER_FLAGS_${_nameUpper})
  move_to_parent(CMAKE_MODULE_LINKER_FLAGS_${_nameUpper})
  move_to_parent(CMAKE_STATIC_LINKER_FLAGS_${_nameUpper})
	
endfunction()

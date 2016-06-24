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

# add flags to compile fo the windows subsystem
# compile_for_windows(
#           [UNICODE] [SCRICT]
#           [VERSION XP|Vista|7|8|10]
# )
# 
# everytime `-Wl,--subsystem,windows` is added.
#
# `UNICODE` option adds `-DUNICODE`, `-D_UNICODE` and `-municode`
# 
# `VERSION`
# 
# `STRICT` enables strict windows types:
# https://msdn.microsoft.com/en-us//library/windows/desktop/aa383731(v=vs.85).aspx
function(compile_for_windows)
	
  # options
	
  set(options UNICODE STRICT)
  set(oneValueArgs VERSION)
  set(multiValueArgs )
  set(prefix _compile_for_windows)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
 
  # subsystem
  
  add_flags(LD "-Wl,--subsystem,windows")  
  
  # unicode
  
  if (${prefix}_UNICODE)
  	add_flags(CPP "-DUNICODE -D_UNICODE" LD "-municode")
  endif()
  
  # strict
  
  if (${prefix}_STRICT)
  	add_flags(CPP "-DSTRICT")
  endif()
  
  # windows version
  
  if (${prefix}_VERSION)
		if (${prefix}_VERSION STREQUAL "XP")
			set(_long_version  0x05010300)
			set(_short_version 0x0501)
			set(_ie_version    0x0800)
		elseif (${prefix}_VERSION STREQUAL "Vista")
			set(_long_version  0x06000100)
			set(_short_version 0x0600)
			set(_ie_version    0x0900)
		elseif (${prefix}_VERSION STREQUAL "7")
			set(_long_version  0x06010000)
			set(_short_version 0x0601)
			set(_ie_version    0x0A00)
		elseif (${prefix}_VERSION STREQUAL "8")
			set(_long_version  0x06020000)
			set(_short_version 0x0602)
			set(_ie_version    0x0A00)
		elseif (${prefix}_VERSION STREQUAL "8.1")
			set(_long_version  0x06030000)
			set(_short_version 0x0603)
			set(_ie_version    0x0A00)
		elseif (${prefix}_VERSION STREQUAL "10")
			set(_long_version  0x0A000000)
			set(_short_version 0x0A00)
			set(_ie_version    0x0A00)
		else()
			message(ERROR "${${prefix}_VERSION} is not a supported value for the VERSION option. Use XP, Vista, 7, 8 or 10.")
		endif()
			
		add_flags(CPP "-DNTDDI_VERSION=${_long_version} -D_WIN32_WINNT=${_short_version} -DWINVER=${_short_version} -D_WIN32_IE=${_ie_version}")
  endif()  
  
  # scope
  
  move_to_parent(CMAKE_C_FLAGS)
  move_to_parent(CMAKE_CXX_FLAGS)
  move_to_parent(CMAKE_EXE_LINKER_FLAGS)
  move_to_parent(CMAKE_SHARED_LINKER_FLAGS)
  move_to_parent(CMAKE_MODULE_LINKER_FLAGS)
endfunction()

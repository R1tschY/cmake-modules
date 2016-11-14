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

set(R1TSCHY_CMAKEMODULES_BITS_DIR "${CMAKE_CURRENT_LIST_DIR}/bits")

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


macro(__match_version version match_var)
  string(REGEX MATCH "^[0-9]+(.[0-9]+)+" ${match_var} "${version}")
endmacro()

function(__version_dots_to_colons dots var_colons)
  # pad 0s 
  string(REPLACE "." ";" FILE_VERSION_LIST "${dots}")
  set(FILE_VERSION_LIST "${FILE_VERSION_LIST};0;0;0")
  list(GET FILE_VERSION_LIST 0 1 2 3 FILE_VERSION)
  
  # list to args
  string(REPLACE ";" "," ${var_colons} "${FILE_VERSION}")
  
  set(${var_colons} "${${var_colons}}" PARENT_SCOPE)
endfunction()

# see https://msdn.microsoft.com/en-us/library/windows/desktop/aa381058(v=vs.85).aspx
# requires CMake 3.1
function(add_windows_versioninfo)

  ##
  # options
  
  set(options DEBUG PATCHED PRERELEASE)
  set(oneValueArgs TARGET 
                   COMPANY_NAME FILE_DESCRIPTION FILE_VERSION 
                     LEGAL_COPYRIGHT PRODUCT_NAME PRODUCT_VERSION
                     COMMENTS INTERNAL_NAME INTERNAL_NAME LEGAL_TRADEMARKS
                   PRIVATEBUILD SPECIALBUILD
                   RC_FILE)
  set(multiValueArgs )
  set(prefix VERSIONINFO)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  if (NOT ${prefix}_TARGET)
    message(FATAL_ERROR "target_set_versioninfo: TARGET argument required")
  endif()
 
  ##
  # vars
  
  set(src "${R1TSCHY_CMAKEMODULES_BITS_DIR}//versioninfo.rc")
  set(dest "${CMAKE_CURRENT_BINARY_DIR}/${${prefix}_TARGET}-versioninfo.rc")
  
  # VERSIONINFO_FILE_TYPE / default_suffix
  get_property(target_type TARGET ${${prefix}_TARGET} PROPERTY TYPE)
  if (${target_type} STREQUAL EXECUTABLE)
    set(VERSIONINFO_FILE_TYPE VFT_APP) 
    set(default_suffix .exe)
  elseif(${target_type} STREQUAL SHARED_LIBRARY)
    set(VERSIONINFO_FILE_TYPE VFT_DLL)
    set(default_suffix .dll)
  else()
    message(FATAL_ERROR "target_set_versioninfo: TARGET has unsupported type `${target_type}`")
  endif()
  
  # target_basename / target_filebase
  get_property(target_outputname TARGET ${${prefix}_TARGET} PROPERTY OUTPUT_NAME)
  get_property(target_suffix TARGET ${${prefix}_TARGET} PROPERTY SUFFIX)
  if (NOT target_outputname)
    set(target_outputname ${${prefix}_TARGET})
  endif()
  if (NOT target_suffix)
    set(target_suffix ${default_suffix})
  endif()
  set(target_basename "${target_outputname}${target_suffix}")
  set(target_filebase "${target_outputname}")
  
  ##
  # helper

  macro(add_value_required key value default)
    if (${value})
      list(APPEND VERSIONINFO_VALUES_LIST "VALUE \"${key}\", \"${${value}}\\0\"")
    else()
      list(APPEND VERSIONINFO_VALUES_LIST "VALUE \"${key}\", \"${default}\\0\"")
    endif()
  endmacro()  
  macro(add_value key value)
    if (${value})
      list(APPEND VERSIONINFO_VALUES_LIST "VALUE \"${key}\", \"${${value}}\\0\"")
    endif()
  endmacro()
  macro(add_header key value)
    if (${value})
      list(APPEND VERSIONINFO_HEADER_LIST "${key} ${${value}}")
    endif()
  endmacro()
  
  ##
  # header
  
  # FILEVERSION
  if (NOT ${prefix}_FILE_VERSION)
    set(${prefix}_FILE_VERSION "${PROJECT_VERSION}")  
  endif()
  
  __match_version("${${prefix}_FILE_VERSION}" FILE_VERSION_VALID)
  if (NOT FILE_VERSION_VALID)
    message(FATAL_ERROR "target_set_versioninfo: FILE_VERSION argument invalid: `${${prefix}_FILE_VERSION}`")
  endif()
  
  __version_dots_to_colons("${FILE_VERSION_VALID}" FILE_VERSION_COLONS)
  add_header(FILEVERSION FILE_VERSION_COLONS)
  
  # PRODUCTVERSION
  if (NOT ${prefix}_PRODUCT_VERSION)
    set(${prefix}_PRODUCT_VERSION "${PROJECT_VERSION}")  
  endif()
  
  __match_version("${${prefix}_PRODUCT_VERSION}" PRODUCT_VERSION_VALID)
  if (NOT PRODUCT_VERSION_VALID)
    message(FATAL_ERROR "target_set_versioninfo: PRODUCT_VERSION argument invalid: `${${prefix}_PRODUCT_VERSION}`")
  endif()
  
  __version_dots_to_colons("${PRODUCT_VERSION_VALID}" PRODUCT_VERSION_COLONS)
  add_header(PRODUCTVERSION PRODUCT_VERSION_COLONS)
  
  ##
  # content
  
  add_value         ("Comments" ${prefix}_COMMENTS)
  add_value_required("CompanyName" ${prefix}_COMPANY_NAME "")
  add_value_required("FileDescription" ${prefix}_FILE_DESCRIPTION "")
  add_value_required("FileVersion" ${prefix}_FILE_VERSION "${PROJECT_VERSION}")
  add_value_required("InternalName" ${prefix}_INTERNAL_NAME "${target_filebase}")
  add_value         ("LegalCopyright" ${prefix}_LEGAL_COPYRIGHT)
  add_value         ("LegalTrademarks" ${prefix}_LEGAL_TRADEMARKS)
  add_value_required("OriginalFilename" ${prefix}_ORIGINAL_FILENAME "${target_basename}")
  add_value_required("ProductName" ${prefix}_PRODUCT_NAME "${PROJECT_NAME}")
  add_value_required("ProductVersion" ${prefix}_PRODUCT_VERSION "${PROJECT_VERSION}")
  
  if (${prefix}_PRIVATEBUILD)
    list(APPEND VERSIONINFO_FILEFLAGS VS_FF_PRIVATEBUILD)
    add_value("PrivateBuild" ${prefix}_PRIVATEBUILD)
  endif()
 
  if (${prefix}_SPECIALBUILD)
    list(APPEND VERSIONINFO_FILEFLAGS VS_FF_SPECIALBUILD)
    add_value("SpecialBuild" ${prefix}_SPECIALBUILD)
  endif()
  
  if (${prefix}_DEBUG)
    list(APPEND VERSIONINFO_FILEFLAGS VS_FF_DEBUG)
  endif()

  if (${prefix}_PATCHED)
    list(APPEND VERSIONINFO_FILEFLAGS VS_FF_PATCHED)
  endif()

  if (${prefix}_PRERELEASE)
    list(APPEND VERSIONINFO_FILEFLAGS VS_FF_PRERELEASE)
  endif()
  
  # join
  string(REPLACE ";" "\n  " VERSIONINFO_HEADER "${VERSIONINFO_HEADER_LIST}")
  string(REPLACE ";" "\n      " VERSIONINFO_VALUES "${VERSIONINFO_VALUES_LIST}")
  
  if (VERSIONINFO_FILEFLAGS)
    string(REPLACE ";" "|" VERSIONINFO_FILEFLAGS "(${VERSIONINFO_FILEFLAGS})")
  else()
    set(VERSIONINFO_FILEFLAGS 0)
  endif()
  
  ##
  # generate
  
  configure_file("${src}" "${dest}" @ONLY NEWLINE_STYLE WIN32)   
  target_sources(${${prefix}_TARGET} PRIVATE "${dest}")
  
  if (${prefix}_RC_FILE)
    set(${${prefix}_RC_FILE} "${dest}" PARENT_SCOPE)
  endif()

endfunction()


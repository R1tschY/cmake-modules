# generate code coverage reports
# include this file in the main CMakeLists.txt.
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

include(AddConfig)
include(AddCXXFlags)

# TODO add is_build_type(<name> <var>) to AddConfig
string(TOUPPER ${CMAKE_BUILD_TYPE} _CMAKE_BUILD_TYPE_UPPER)
if (_CMAKE_BUILD_TYPE_UPPER STREQUAL "COVERAGE")
	set(CMAKE_BUILD_TYPE_COVERAGE ON)
endif()
unset(_CMAKE_BUILD_TYPE_UPPER)

if (CMAKE_BUILD_TYPE_COVERAGE)
	check_cxx_compiler_flags(HAVE_CXX_FLAG_COVERAGE FLAGS -coverage)
	if (HAVE_CXX_FLAG_COVERAGE)

		# new build type

		add_config(Coverage
		  C_FLAGS "-g -O0 -coverage"
		  CXX_FLAGS "-g -O0 -coverage"
		  LINKER_FLAGS "-g -O0 -coverage"
		)

		# the tools

		find_program(GCOV_EXECUTABLE gcov)
		find_program(LCOV_EXECUTABLE lcov)
		find_program(GENHTML_EXECUTABLE genhtml)
		find_program(GCOVR_EXECUTABLE gcovr)

		# default tool flags

		if (UNIX)
		  set(LCOV_EXCLUDE "'/usr/*'" "'/opt/*'")
		endif()

		set(GENHTML_FLAGS "--demangle-cpp --legend")

	else()
		message(WARNING "using unsupported compiler for coverage measuring")
	endif()
endif()

# add target which create coverage report for a command with lcov
# ::
#   add_coverage_target(TARGET target_name
#                       COMMAND command
#                       OUTPUT output_name
#                       EXCLUDE glob1 glob2 ...
#                       INCLUDE glob1 glob2 ...
#   )
# a target `target_name` will be generated that runs `command` and generates
# `output_name.info` and `output_name/index.html`. Files which match the globs
# from `EXCLUDE` arguments and `LCOV_EXCLUDE` list will be excluded from the
# coverage report. If `INCLUDE` is given only files that match the following
# globs are used in the coverage report. Use ``LCOV_FLAGS`` and ``GENHTML_FLAGS``
# for extra arguments for ``lcov`` and ``genhtml``.
function(add_coverage_target)
  if ((NOT HAVE_CXX_FLAG_COVERAGE) OR (NOT CMAKE_BUILD_TYPE_COVERAGE))
    return()
  endif()

  # options

  set(options )
  set(oneValueArgs COMMAND TARGET OUTPUT)
  set(multiValueArgs EXCLUDE INCLUDE)
  set(prefix _add_coverage_for_target)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT ${prefix}_TARGET)
    message(FATAL_ERROR "TARGET parameter is required for add_coverage_target")
  endif()
  if (NOT ${prefix}_COMMAND)
    message(FATAL_ERROR "COMMAND parameter is required for add_coverage_target")
  endif()
  if (NOT ${prefix}_OUTPUT)
    message(FATAL_ERROR "OUTPUT parameter is required for add_coverage_target")
  endif()

  # tools

  if (NOT GCOV_EXECUTABLE)
    message(FATAL_ERROR "gcov executable not found. Set the GCOV_EXECUTABLE variable.")
  endif()
  if (NOT LCOV_EXECUTABLE)
    message(FATAL_ERROR "lcov executable not found. Set the LCOV_EXECUTABLE variable.")
  endif()
  if (NOT GENHTML_EXECUTABLE)
    message(FATAL_ERROR "genhtml executable not found. Set the GENHTML_EXECUTABLE variable.")
  endif()

  # args

  # files
  set(_lcovInfoFile ${${prefix}_OUTPUT}.info)

  # global args
  string(REGEX REPLACE " " ";" _LCOV_FLAGS "${LCOV_FLAGS}")
  string(REGEX REPLACE " " ";" _GENHTML_FLAGS "${GENHTML_FLAGS}")
  set(_lcov ${LCOV_EXECUTABLE} ${_LCOV_FLAGS} --output-file ${_lcovInfoFile})
  set(_genhtml ${GENHTML_EXECUTABLE} ${_GENHTML_FLAGS} )

  # filter runs

  set(_lcovFilterRuns "")

  # extract
  if (${prefix}_INCLUDE)
    list(APPEND _lcovFilterRuns COMMAND
      ${_lcov} "--extract" ${_lcovInfoFile} ${${prefix}_INCLUDE}
    )
  endif()

  message(STATUS "${_lcovFilterRuns}")

  # remove
  if (LCOV_EXCLUDE OR ${prefix}_EXCLUDE})
    list(APPEND _lcovFilterRuns COMMAND
      ${_lcov} "--remove" ${_lcovInfoFile} ${LCOV_EXCLUDE} ${${prefix}_EXCLUDE}
    )
  endif()

  message(STATUS "${_lcovFilterRuns}")

  # targets
  set(cecho cmake -E cmake_echo_color --magenta)
  add_custom_target(
    ${${prefix}_TARGET}

    COMMAND ${cecho} "Reseting coverage counters"
    COMMAND ${LCOV_EXECUTABLE} --directory ${CMAKE_BINARY_DIR} --zerocounters

    COMMAND ${cecho} "Running coverage test"
    COMMAND ${${prefix}_COMMAND} || true


    # collect information
    COMMAND ${cecho} "Processing coverage counters"
    COMMAND ${_lcov} --directory ${CMAKE_BINARY_DIR} --capture --gcov-tool ${GCOV_EXECUTABLE}

    # filter info file
    COMMAND ${cecho} "Processing coverage counters"
    ${_lcovFilterRuns}

    # generate html
    COMMAND ${cecho} "Generating coverage report"
    COMMAND ${_genhtml} -o ${${prefix}_OUTPUT} ${_lcovInfoFile}
    COMMAND ${cecho} "Open the webpage ${${prefix}_OUTPUT}/index.html to view the coverage report"

    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Measure coverage and generate report"
  )

endfunction()


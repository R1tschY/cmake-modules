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

macro(append _var _arg)
	set(${_var} "${${_var}}${_arg}" ${ARGN})
endmacro()

macro(move_to_parent _var)
	set(${_var} "${${_var}}" PARENT_SCOPE)
endmacro()

function(list_dirs result curdir)
  file(GLOB children RELATIVE "${curdir}" "${curdir}/*")
  unset(${result})
  foreach(child ${children})
    if(IS_DIRECTORY "${curdir}/${child}")
      list(APPEND ${result} ${child})
    endif()
  endforeach()
  move_to_parent(${result})
endfunction()


function(default_arguments prefix)
  list(LENGTH ARGN args)
  math(EXPR args "${args} - 1")

  foreach(arg0 RANGE 0 ${args} 2)
    math(EXPR arg1 "${arg0} + 1")
    list(GET ARGN ${arg0} arg)
    list(GET ARGN ${arg1} default)
    
    if (NOT ${prefix}_${arg})
      set(${prefix}_${arg} "${default}" PARENT_SCOPE)
    endif()
  endforeach()

endfunction()


function(color_message style)
  execute_process(COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --${style} "${ARGN}")
endfunction()

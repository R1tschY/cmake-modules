

function(add_isolated_project)

  # options

  set(options ADD_TO_ALL)
  set(oneValueArgs TARGET DIR COMMENT)
  set(multiValueArgs PASSTHROUGH NEW)
  set(prefix add_isolated_project)
  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  if (NOT ${prefix}_TARGET)
    message(FATAL_ERROR "TARGET argument is required for `add_isolated_project`")
  endif()
  
  # DIR
  if (NOT ${prefix}_DIR)
    set(${prefix}_DIR "${PROJECT_BINARY_DIR}/${TARGET}_build")  
  endif()  
  
  if(NOT IS_DIRECTORY "${${prefix}_DIR}")
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E make_directory "${${prefix}_DIR}"
    )
  endif()
  
  # CMAKE
  
  # add_custom_target options
  if (${prefix}_ADD_TO_ALL)
    list(APPEND _options "ALL")
  endif()
  if (${prefix}_COMMENT)
    list(APPEND _options "COMMENT" "${${prefix}_COMMENT}")
  endif()
  
  # cmake options
  foreach(_var ${${prefix}_PASSTHROUGH})
    list(APPEND _cmake_options "-D${_var}=${${_var}}")
  endforeach()
  foreach(_pair ${${prefix}_NEW})
    list(APPEND _cmake_options "-D${_pair}")
  endforeach()
  
  execute_process(
    COMMAND ${CMAKE_COMMAND} ${_cmake_options} "${CMAKE_SOURCE_DIR}"
    WORKING_DIRECTORY "${${prefix}_DIR}"
  )
  
  add_custom_target(
    "${${prefix}_TARGET}" 
    ${_options}
    WORKING_DIRECTORY "${${prefix}_DIR}"
    COMMAND ${CMAKE_COMMAND} "--build" "."
  )

endfunction()
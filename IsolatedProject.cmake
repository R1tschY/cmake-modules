

function(add_isolated_project)

  # options

  set(options ADD_TO_ALL)
  set(oneValueArgs TARGET DIR COMMENT CMAKE GENERATOR)
  set(multiValueArgs PASSTHROUGH NEW CMAKE_EXTRA_ARGS)
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
  
  if (NOT ${prefix}_CMAKE)
    set(${prefix}_CMAKE ${CMAKE_COMMAND})
  endif()
  if (NOT ${prefix}_GENERATOR)
    set(${prefix}_GENERATOR ${CMAKE_GENERATOR})
  endif()
  
  # add_custom_target options
  if (${prefix}_ADD_TO_ALL)
    list(APPEND _options "ALL")
  endif()
  if (${prefix}_COMMENT)
    list(APPEND _options "COMMENT" "${${prefix}_COMMENT}")
  endif()
  
  # cmake options
  list(APPEND _cmake_options ${${prefix}_CMAKE_EXTRA_ARGS})
  list(APPEND _cmake_options "-G${${prefix}_GENERATOR}")
  foreach(_var ${${prefix}_PASSTHROUGH})
    list(APPEND _cmake_options "-D${_var}=${${_var}}")
  endforeach()
  foreach(_pair ${${prefix}_NEW})
    list(APPEND _cmake_options "-D${_pair}")
  endforeach()
  
  execute_process(
    COMMAND ${${prefix}_CMAKE} ${_cmake_options} "${CMAKE_SOURCE_DIR}"
    WORKING_DIRECTORY "${${prefix}_DIR}"
  )
  
  add_custom_target(
    "${${prefix}_TARGET}" 
    ${_options}
    WORKING_DIRECTORY "${${prefix}_DIR}"
    COMMAND ${${prefix}_CMAKE} "--build" "${${prefix}_DIR}"
  )

endfunction()
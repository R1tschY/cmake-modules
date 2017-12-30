get_property(_Qt5_Core_LOCATION TARGET Qt5::Core PROPERTY LOCATION)
get_filename_component(Qt_BIN_DIR "${_Qt5_Core_LOCATION}" PATH)
if(APPLE)
  get_filename_component(Qt_BIN_DIR "${Qt_BIN_DIR}" PATH)
endif()

# from https://gitlab.kitware.com/cmake/cmake/blob/master/Source/QtDialog/CMakeLists.txt
function(install_qt5_plugin _qt_plugin_name _qt_plugins_var _qt_plugin_dir _component)
    if (CMAKE_BUILD_TYPE)
        # TODO: works not for MSVC
        string(TOUPPER ${CMAKE_BUILD_TYPE} _config)
        set(_location_prop LOCATION_${_config})
    else()
        set(_location_prop LOCATION)
    endif()

    get_target_property(_qt_plugin_path "${_qt_plugin_name}" ${_location_prop})
    if(EXISTS "${_qt_plugin_path}")
        get_filename_component(_qt_plugin_file "${_qt_plugin_path}" NAME)
        get_filename_component(_qt_plugin_type "${_qt_plugin_path}" PATH)
        get_filename_component(_qt_plugin_type "${_qt_plugin_type}" NAME)
        set(_qt_plugin_dest "${_qt_plugin_dir}/${_qt_plugin_type}")
        install(FILES "${_qt_plugin_path}"
            DESTINATION "${_qt_plugin_dest}"
            ${_component})
        set(${_qt_plugins_var}
            "${${_qt_plugins_var}};\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${_qt_plugin_dest}/${_qt_plugin_file}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Qt plugin ${_qt_plugin_name} not found")
    endif()
endfunction()


function(install_qt5_executable)

    ##
    # options

    set(options )
    set(oneValueArgs APP COMPONENT)
    set(multiValueArgs QTPLUGINS LIBS DIRS)
    set(prefix _install_qt5_executable)
    cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(component)
        set(component COMPONENT "${${prefix}_COMPONENT}")
    else()
        unset(component)
    endif()

    ##
    # install plugins

    set(libs "${${prefix}_LIBS}")
    if(QT_IS_STATIC)
        message(WARNING "Qt built statically: not installing plugins.")
    else()
        foreach(plugin ${${prefix}_QTPLUGINS})
            install_qt5_plugin("${plugin}" libs "." "${${prefix}_COMPONENT}")
        endforeach()
    endif()

    ##
    # fixup app

    install(CODE "
        include(BundleUtilities)
        set(BU_CHMOD_BUNDLE_ITEMS TRUE)
        fixup_bundle(
            \"${${prefix}_APP}\"
            \"${libs}\"
            \"${Qt_BIN_DIR};${${prefix}_DIRS}\")"
        ${component})

endfunction()

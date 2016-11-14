# cmake-modules

extra modules for *CMake*

## Installation

Add this repository as submodule to your project:
```
git submodule add https://github.com/R1tschY/cmake-modules.git cmake/modules
```

In your main `CMakeLists.txt` add at the top:
```
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
```

Now you can include one of the following modules and use it, e.x.:
```
include(CodeHardening)
hardening(ALL)
```

## AddConfig
```
add_config(<name>
  [COPY_FROM <config>]
  [C_FLAGS "<flags>"]
  [CXX_FLAGS "<flags>"]
  [LINKER_FLAGS "<flags>"]
  [EXE_LINKER_FLAGS "<flags>"]
  [SHARED_LINKER_FLAGS "<flags>"]
  [MODULE_LINKER_FLAGS "<flags>"]
  [STATIC_LINKER_FLAGS "<flags>"]
)
```

Add a new build type (configuration) `<name>`. Use `CMAKE_BUILD_TYPE` to use it:

    cmake -DCMAKE_BUILD_TYPE=<name> <PATH_TO_SOURCE>

If `COPY_FROM` is set, the 
compile flags from the configuration `config` are copied. The `*_FLAGS` 
arguments are appended to `CMAKE_*_FLAGS_<NAME>`. The flags from `LINKER_FLAGS` 
are appended to `CMAKE_EXE_LINKER_FLAGS_<NAME>`, 
`CMAKE_SHARED_LINKER_FLAGS_<NAME>` and `CMAKE_MODULE_LINKER_FLAGS_<NAME>`.

### Example

The command

    add_config(Profile CXX_FLAGS "-g -fno-omit-frame-pointer -O3" LINKER_FLAGS "-g -fno-omit-frame-pointer -O3")
    
sets the following variables:

    CMAKE_CXX_FLAGS_PROFILE = "-g -fno-omit-frame-pointer -O3"
    CMAKE_EXE_LINKER_FLAGS_PROFILE = "-g -fno-omit-frame-pointer -O3"
    CMAKE_SHARED_LINKER_FLAGS_PROFILE = "-g -fno-omit-frame-pointer -O3"
    CMAKE_MODULE_LINKER_FLAGS_PROFILE = "-g -fno-omit-frame-pointer -O3"
    
## AddCXXFlags

### add_cxx_flags
```
add_cxx_flags("flag ..." [variant])
```
adds flags to `CMAKE_CXX_FLAGS` or `CMAKE_CXX_FLAGS_<VARIANT>`


### check_cxx_compiler_flags
```
check_cxx_compiler_flags(<var>
  [FLAGS "-flag ..."]
  [DEFINITIONS -DFOO=bar ...]
  [INCLUDES <dir> ...]
  [LIBRARIES <lib> ...]
  [QUIET]
)
```
Sets `<var>` if `int main() { return 0; }` can be compiled with `FLAGS`, 
`DEFINITIONS`, `INCLUDES` and linked with `FLAGS` and `LIBRARIES`. If `QUIET` is
set, nothing is printed.

(Internally sets `CMAKE_REQUIRED_*` and calls `check_cxx_compiler_flag`.)

### add_cxx_flag_checked
```
add_cxx_flag_checked("flag ..." [variant] [REQUIRED])
```
Add c++ compiler flag if compiler supports it. If the flags are supported, 
`CMAKE_CXX_FLAGS` is updated and `HAVE_CXX_FLAG_<FLAG>` is set.
If `<variant>` is set, `CMAKE_CXX_FLAGS_VARIANT` is updated.
If `REQUIRED` is set, an error is show when the flag is not supported.

### add_flags
```
add_flags(
  [C "--flag ..."] 
  [CXX "--flag ..."] 
  [CPP "-DDEFINE=0 ..."]
  [BUILD_TYPE build_type]
)
```
Adds compiler flags.
`CXX` is added to `CMAKE_CXX_FLAGS`. `C` is added to `CMAKE_C_FLAGS`. `CPP` is 
added to `CMAKE_C_FLAGS` and `CMAKE_CXX_FLAGS`. `LD` is added to 
`CMAKE_EXE_LINKER_FLAGS`, `CMAKE_SHARED_LINKER_FLAGS` and 
`CMAKE_MODULE_LINKER_FLAGS`.

If `BUILD_TYPE` is set, `CMAKE_*_FLAGS_<BUILD_TYPE>` are used.

## CodeCoverage

Include this file in the main CMakeLists.txt. It adds a new configuration (build type) `Coverage`.

### add_coverage_target
add target which create coverage report for a command with *lcov*.
```
add_coverage_target(TARGET <target_name>
                    COMMAND <command>
                    OUTPUT <output_name>
                    [EXCLUDE <glob1> <glob2> ...]
                    [INCLUDE <glob1> <glob2> ...]
)
```

A target `<target_name>` will be generated that runs `<command>` and generates
`<output_name>.info` and `<output_name>/index.html`. Files which match the globs
from `EXCLUDE` and `LCOV_EXCLUDE` will be excluded from the
coverage report. If `INCLUDE` is given, only files that match the following
globs are used in the coverage report. Use the ``LCOV_FLAGS`` and ``GENHTML_FLAGS`` variables
for extra arguments for ``lcov`` and ``genhtml``.

The target is only visable, if the build type is `Coverage`: `CMAKE_BUILD_TYPE=Coverage`.

On a Unix system `LCOV_EXCLUDE` is set to:
```
set(LCOV_EXCLUDE "'/usr/*'" "'/opt/*'")
```

## CodeHardening

Add hardening flags for gcc and clang.
```
hardening([ALL]
          [ENABLE feature ...]
          [DISABLE feature ...]
          [BUILD_TYPE build_type]
)
```

`ALL` adds all supported hardening features. `ENABLE` sets individual features and `DISABLE` unsets they.

The supported features are:
```
FORMAT FORTIFY STACKPROTECTOR PIE RELRO BINDNOW
```

See https://wiki.debian.org/Hardening for a description of the features.

## TODO

- [ ] add_coverage_target: add `DEPENDS`
- [ ] add_coverage_target: support for gcovr: http://gcovr.com/guide.html
- [ ] use add_flags in replacement of add_cxx_flags 
- [ ] rename CodeHadening to Hardening
- [ ] add_config: use CMAKE_CONFIGURATION_TYPES
- [ ] add_cxx_flags_checked: add VARNAME arg
- [ ] rename AddCXXFlags to AddCompilerFlags
- [ ] test and document Sanitizer.cmake
- [ ] test for clang
- [ ] add_coverage_target: surround globs with `'`'s


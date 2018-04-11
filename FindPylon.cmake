# FindPylon
# ---------
#
# Try to find Pylon libraries and include directories. Once done this will
# define:
#
#   Pylon_FOUND            - True if headers and libraries were found
#   Pylon_INCLUDE_DIRS     - Pylon include directories
#   Pylon_LIBRARIES        - Pylon component libraries to be linked
#
#   Pylon_VERSION          - Pylon version
#   Pylon_MAJOR_VERSION    - Pylon major version number (X in X.y.z)
#   Pylon_MINOR_VERSION    - Pylon minor version number (Y in x.Y.z)
#   Pylon_SUBMINOR_VERSION - Pylon subminor version number (Z in x.y.Z)

# The MIT License (MIT)
#
# Copyright (c) 2018 Kim Lindberg Schwaner <kils@mmmi.sdu.dk>
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


# Macro to invoke 'pylon-config'
macro(pylon_config_invoke _var _cleanup_regex)
  set(_result)

  execute_process(
    COMMAND ${Pylon_CONFIG_EXECUTABLE} ${ARGN}
    OUTPUT_VARIABLE _result
    RESULT_VARIABLE _pylon_config_failed
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(_pylon_config_failed)
    set(${_var} "")
  else()
    if(NOT ${_cleanup_regex} STREQUAL "")
      string(REGEX REPLACE ${_cleanup_regex} "\\1" _result ${_result})
    endif()

    separate_arguments(_result)
    set(${_var} ${_result})
  endif()
endmacro()

set(Pylon_SEARCH_PATHS
	${PYLON_ROOT}
	$ENV{PYLON_ROOT}
	"/opt/pylon5"
	"C:/Program Files/Basler/pylon 5/Development")

# Try to find the 'pylon-config' script which acts like 'pkg-config' and can
# tell us about installed Pylon libraries.
find_program(Pylon_CONFIG_EXECUTABLE pylon-config
             PATHS ${Pylon_SEARCH_PATHS}
             PATH_SUFFIXES bin)
mark_as_advanced(Pylon_CONFIG_EXECUTABLE)

if(Pylon_CONFIG_EXECUTABLE)
  pylon_config_invoke(Pylon_MAJOR_VERSION    ""        "--version-major")
  pylon_config_invoke(Pylon_MINOR_VERSION    ""        "--version-minor")
  pylon_config_invoke(Pylon_SUBMINOR_VERSION ""        "--version-subminor")
  # pylon_config_invoke(Pylon_LDFLAGS          ""        "--libs")
  pylon_config_invoke(Pylon_LIB_NAMES        "(^| )-l" "--libs-only-l")
  pylon_config_invoke(Pylon_LIBRARY_DIRS     "(^| )-L" "--libs-only-L")
  # pylon_config_invoke(Pylon_LDFLAGS_OTHER    ""        "--libs-only-other")
  # pylon_config_invoke(Pylon_CFLAGS           ""        "--cflags")
  pylon_config_invoke(Pylon_INCLUDE_DIRS     "(^| )-I" "--cflags-only-I")
  # pylon_config_invoke(Pylon_CFLAGS_OTHER     ""        "--cflags-only-other")

  # Pylon_LIB_NAMES contains only the library names, but Pylon_LIBRARIES should
  # contain full paths
  foreach(lib ${Pylon_LIB_NAMES})
    set(var_name "Pylon_${lib}_LIB")
    find_library(${var_name} ${lib} HINTS ${Pylon_LIBRARY_DIRS})
    list(APPEND Pylon_LIBRARIES ${${var_name}})
    mark_as_advanced(${var_name})
  endforeach()
else()
  find_path(Pylon_INCLUDE_DIR
    NAMES pylon/PylonVersionNumber.h pylon/PylonIncludes.h
    PATHS ${Pylon_SEARCH_PATHS}
    PATH_SUFFIXES include)

  # Determine if compiling 64- or 32-bit target
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(lib_search_suffixes lib64 lib/x64)
  else()
    set(lib_search_suffixes lib lib/Win32)
  endif()

  find_library(Pylon_BASE_LIB
    NAMES pylonbase PylonBase_MD_VC120_v5_0
    PATHS ${Pylon_SEARCH_PATHS}
    PATH_SUFFIXES ${lib_search_suffixes})
  find_library(Pylon_UTILITY_LIB
    NAMES pylonutility PylonUtility_MD_VC120_v5_0
    PATHS ${Pylon_SEARCH_PATHS}
    PATH_SUFFIXES ${lib_search_suffixes})
  find_library(Pylon_GCBASE_LIB
    NAMES GCBase_gcc_v3_0_Basler_pylon_v5_0 GCBase_MD_VC120_v3_0_Basler_pylon_v5_0
    PATHS ${Pylon_SEARCH_PATHS}
    PATH_SUFFIXES ${lib_search_suffixes})
  find_library(Pylon_GENAPI_LIB
    NAMES GenApi_gcc_v3_0_Basler_pylon_v5_0 GenApi_MD_VC120_v3_0_Basler_pylon_v5_0
    PATHS ${Pylon_SEARCH_PATHS}
    PATH_SUFFIXES ${lib_search_suffixes})

  # MS linker complains if not this (Windows-only?) lib is included
  if(WIN32)
    find_library(Pylon_GUI_LIB
      NAMES PylonGUI_MD_VC120_v5_0
      PATHS ${Pylon_SEARCH_PATHS}
      PATH_SUFFIXES ${lib_search_suffixes})
  endif()

  # Parse version number from PylonVersionNumber.h
  file(READ "${Pylon_INCLUDE_DIR}/pylon/PylonVersionNumber.h" VERSION_FILE)
  string(REGEX REPLACE ".*PYLON_VERSION_MAJOR[\t ]+([0-9]+).*" "\\1" Pylon_MAJOR_VERSION ${VERSION_FILE})
  string(REGEX REPLACE ".*PYLON_VERSION_MINOR[\t ]+([0-9]+).*" "\\1" Pylon_MINOR_VERSION ${VERSION_FILE})
  string(REGEX REPLACE ".*PYLON_VERSION_SUBMINOR[\t ]+([0-9]+).*" "\\1" Pylon_SUBMINOR_VERSION ${VERSION_FILE})

  set(Pylon_INCLUDE_DIRS ${Pylon_INCLUDE_DIR})
  set(Pylon_LIBRARIES
    ${Pylon_BASE_LIB}
    ${Pylon_UTILITY_LIB}
    ${Pylon_GCBASE_LIB}
    ${Pylon_GENAPI_LIB}
    ${Pylon_GUI_LIB})
  mark_as_advanced(Pylon_INCLUDE_DIR
    Pylon_BASE_LIB
    Pylon_UTILITY_LIB
    Pylon_GCBASE_LIB
    Pylon_GENAPI_LIB
    Pylon_GUI_LIB)
endif()

set(Pylon_VERSION "${Pylon_MAJOR_VERSION}.${Pylon_MINOR_VERSION}.${Pylon_SUBMINOR_VERSION}")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pylon
  REQUIRED_VARS Pylon_INCLUDE_DIRS Pylon_LIBRARIES
  VERSION_VAR Pylon_VERSION)

# Try to find the Ascension Technology Corporation 3D Guidance libraries
# and API headers.
#
# Once done this will define:
#
#   ATC3DG_FOUND         - System has ATC3DG
#   ATC3DG_INCLUDE_DIRS  - The ATC3DG include directories
#   ATC3DG_LIBRARIES     - The libraries needed to use ATC3DG
#   ATC3DG_DEFINITIONS   - Definitions required for using ATC3DG

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


find_path(ATC3DG_INCLUDE_DIR
  ATC3DG.h
  PATHS /opt/3DGuidance.Rev.E.64/3DGuidanceAPI)

find_library(ATC3DG_LIBRARY
  ATC3DGlib64
  HINTS ${ATC3DG_INCLUDE_DIR})

set(ATC3DG_INCLUDE_DIRS ${ATC3DG_INCLUDE_DIR})
set(ATC3DG_LIBRARIES ${ATC3DG_LIBRARY})

if(APPLE)
  set(ATC3DG_DEFINITIONS -DMAC)
elseif(UNIX)
  set(ATC3DG_DEFINITIONS -DLINUX)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ATC3DG DEFAULT_MSG ATC3DG_INCLUDE_DIR ATC3DG_LIBRARY)

mark_as_advanced(ATC3DG_INCLUDE_DIR ATC3DG_LIBRARY)

# This file is part of the OregonCore Project. See AUTHORS file for Copyright information
#
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# Set projectname (must be done AFTER setting configurationtypes)

project(OregonCore)

# We require CMake >= 3.2
cmake_minimum_required(VERSION 3.2)

# CMake policies (can not be handled elsewhere)
cmake_policy(SET CMP0005 NEW)
if(POLICY CMP0043)
  cmake_policy(SET CMP0043 NEW) # Disable 'Ignore COMPILE_DEFINITIONS_<Config> properties'
endif()

if(POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW) # Only interpret if() arguments as variables or keywords when unquoted - prevents intepreting if (SOME_STRING_VARIABLE MATCHES "MSVC") as if (SOME_STRING_VARIABLE MATCHES "1")
endif()

if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW) # find_package() uses <PackageName>_ROOT variables
endif()

# Set RPATH-handing (CMake parameters)
set(CMAKE_SKIP_BUILD_RPATH 0)
set(CMAKE_BUILD_WITH_INSTALL_RPATH 0)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH 1)

# set macro-directory
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/macros")

# build in preferred mode
if( NOT CMAKE_BUILD_TYPE )
    if (WITH_COREDEBUG)
        set(CMAKE_BUILD_TYPE "Debug")
    else()
        set(CMAKE_BUILD_TYPE "Release")
    endif()
endif()

include(CheckCXXSourceRuns)
include(CheckIncludeFiles)

# some utils for cmake
include(dep/drassil/cmake-utils/utils.cmake)

include(cmake/ac_macros.cmake)

include(cmake/GroupSources.cmake)

# set default buildoptions and print them
include(cmake/options.cmake)

# turn off PCH totally if enabled (hidden setting, mainly for devs)
if( NOPCH )
  set(USE_COREPCH 0)
  set(USE_SCRIPTPCH 0)
endif()

# platform detection
include(CheckPlatform)

# basic package searching and setup
find_package(PCHSupport)
find_package(ACE REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(MySQL REQUIRED)

if( UNIX )
  find_package(Curses)
  find_package(ZLIB)
  find_package(BZip2)
  find_package(Binutils)
endif()

# Find revision ID and hash of the sourcetree
include(cmake/genrev.cmake)

# doxygen support
include(cmake/doxygen.cmake)

# print out the results before continuing
include(cmake/showoptions.cmake)

# add dependencies
add_subdirectory(dep)

#
# Loading dyn modules
#

# add modules and dependencies
CU_SUBDIRLIST(sub_DIRS  "${CMAKE_SOURCE_DIR}/modules" FALSE FALSE)
FOREACH(subdir ${sub_DIRS})

    get_filename_component(MODULENAME ${subdir} NAME)

    if (";${DISABLED_AC_MODULES};" MATCHES ";${MODULENAME};")
       continue()
    endif()

    STRING(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/" "" subdir_rel ${subdir})
    if(EXISTS "${subdir}/CMakeLists.txt")
        message("Loading module: ${subdir_rel}")
        add_subdirectory("${subdir_rel}")
    endif()
ENDFOREACH()
CU_RUN_HOOK("AFTER_LOAD_CONF")

CU_RUN_HOOK("AFTER_LOAD_CMAKE_MODULES")
#
# Loading application sources
#

CU_RUN_HOOK("BEFORE_SRC_LOAD")
# add core sources
add_subdirectory(src)

CU_RUN_HOOK("AFTER_SRC_LOAD")

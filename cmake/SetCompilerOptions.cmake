# verify that we have  c++11
include(cmake/CheckC++11.cmake)
CheckCpp11()

set(EXTRA_FLAGS "")
set(EXTRA_CXX_FLAGS "-std=c++11")
set(EXTRA_C_FLAGS "")
set(EXTRA_FLAGS_DEBUG "")
set(EXTRA_FLAGS_RELEASE "")
set(EXTRA_EXE_LINKER_FLAGS "")
set(EXTRA_EXE_LINKER_FLAGS_DEBUG "")
set(EXTRA_EXE_LINKER_FLAGS_RELEASE "")

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  set(CMAKE_COMPILER_IS_GNUCXX 1)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(CMAKE_COMPILER_IS_CLANGCXX 1)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  message(STATUS "Using Intel compilers")
  set(CMAKE_COMPILER_IS_INTEL 1)
endif()

macro(addExtraCompilerOptions option)
  set(EXTRA_CXX_FLAGS "${EXTRA_CXX_FLAGS} ${option}")
  set(EXTRA_C_FLAGS "${EXTRA_C_FLAGS} ${option}")
endmacro()

macro(addExtraLinkerOption option)
  set(EXTRA_EXE_LINKER_FLAGS "${EXTRA_EXE_LINKER_FLAGS} ${option}")
endmacro()

addExtraCompilerOptions(-W)
addExtraCompilerOptions(-Wall)
addExtraCompilerOptions(-Wextra)
addExtraCompilerOptions(-funroll-loops)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_CLANGCXX)
  addExtraCompilerOptions(-W)
  addExtraCompilerOptions(-Wall)
  addExtraCompilerOptions(-Werror=sequence-point)
  addExtraCompilerOptions(-Wundef)
  addExtraCompilerOptions(-Winit-self)
  addExtraCompilerOptions(-Wpointer-arith)
  addExtraCompilerOptions(-Wsign-promo)
  #Warn whenever a pointer is cast such that the required alignment of the
  #target is increased. For example, warn if a char * is cast to an int * on
  #machines where integers can only be accessed at two- or four-byte boundaries.
  addExtraCompilerOptions(-Wcast-align)
  addExtraCompilerOptions(-fdiagnostics-show-option)
  addExtraCompilerOptions(-ftree-vectorize)
  addExtraCompilerOptions(-pthread)
  addExtraCompilerOptions(-Wabi)

  #addExtraCompilerOptions(-msse4.1)
  #addExtraCompilerOptions(-msse2)
  #addExtraCompilerOptions(-msse)
  #addExtraCompilerOptions(-mavx)
  #addExtraCompilerOptions(-mtune=native)
  #addExtraCompilerOptions(-mfpmath=sse)

  if(CMAKE_COMPILER_IS_GNUCXX)
  	addExtraCompilerOptions(-falign-functions=16)
  	addExtraCompilerOptions(-falign-loops=16)
  	addExtraCompilerOptions(-fabi-version=6)
  endif()

  if(ENABLE_OMIT_FRAME_POINTER)
    addExtraCompilerOptions(-fomit-frame-pointer)
  else()
    addExtraCompilerOptions(-fno-omit-frame-pointer)
  endif()

  if(ENABLE_FAST_MATH)
    addExtraCompilerOptions(-ffast-math)
  endif()

  if(ENABLE_PROFILING)
    addExtraCompilerOptions("-pg -g")
  endif()

endif()

if(CMAKE_COMPILER_IS_INTEL)
  # ICC stuff
  addExtraCompilerOptions(-Wall)
  addExtraCompilerOptions(-Wextra)
  addExtraCompilerOptions(-qopt-report-phase=all)
  addExtraCompilerOptions(-qopt-report=5)
  addExtraCompilerOptions(-ipo)
  addExtraCompilerOptions(-finline)
  addExtraCompilerOptions(-inline-forceinline)
  add_definitions(-DNOALIAS)
endif()

if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
  add_definitions(-DIS_64BIT)
endif()

if(BUILD_STATIC)
  set(LIBRARY_TYPE STATIC)
  if(CMAKE_COMPILER_IS_GNUCXX)
    set(EXTRA_FLAGS "-fPIC ${EXTRA_CXX_FLAGS}")
  endif()
else()
  set(LIBRARY_TYPE SHARED)
endif()


set(EXTRA_FLAGS                     "${EXTRA_FLAGS}"                    CACHE INTERNAL "Extra flags")
set(EXTRA_C_FLAGS                   "${EXTRA_C_FLAGS}"                  CACHE INTERNAL "Extra C flags")
set(EXTRA_CXX_FLAGS                 "${EXTRA_CXX_FLAGS}"                CACHE INTERNAL "Extra CXX flags")
set(EXTRA_FLAGS_DEBUG               "${EXTRA_FLAGS_DEBUG}"              CACHE INTERNAL "Extra debug flags")
set(EXTRA_FLAGS_RELEASE             "${EXTRA_FLAGS_RELEASE}"            CACHE INTERNAL "Extra release flags")
set(EXTRA_EXE_LINKER_FLAGS          "${EXTRA_EXE_LINKER_FLAGS}"         CACHE INTERNAL "Extra linker flags")
set(EXTRA_EXE_LINKER_FLAGS_DEBUG    "${EXTRA_EXE_LINKER_FLAGS_DEBUG}"   CACHE INTERNAL "Extra linker flags debug")
set(EXTRA_EXE_LINKER_FLAGS_RELEASE  "${EXTRA_EXE_LINKER_FLAGS_RELEASE}" CACHE INTERNAL "Extra linker flags release")

set(CMAKE_C_FLAGS                  "${CMAKE_C_FLAGS} ${EXTRA_C_FLAGS} ${EXTRA_FLAGS}")
set(CMAKE_CXX_FLAGS                "${CMAKE_CXX_FLAGS} ${EXTRA_CXX_FLAGS} ${EXTRA_FLAGS}")
set(CMAKE_CXX_FLAGS_RELEASE        "${CMAKE_CXX_FLAGS_RELEASE} ${EXTRA_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_RELEASE          "${CMAKE_C_FLAGS_RELEASE} ${EXTRA_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_DEBUG          "${CMAKE_CXX_FLAGS_DEBUG} ${EXTRA_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_DEBUG            "${CMAKE_C_FLAGS_DEBUG} ${EXTRA_FLAGS_DEBUG}")
set(CMAKE_EXE_LINKER_FLAGS         "${CMAKE_EXE_LINKER_FLAGS} ${EXTRA_EXE_LINKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} ${EXTRA_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG   "${CMAKE_EXE_LINKER_FLAGS_DEBUG} ${EXTRA_EXE_LINKER_FLAGS_DEBUG}")

# they mess up with the flags too much
# and there seems to be an issue with AVX with gcc-4.9
include(cmake/OptimizeForArchitecture.cmake)
include(cmake/UserWarning.cmake)
#set(Vc_AVX_INTRINSICS_BROKEN True)
OptimizeForArchitecture()
list(APPEND "${CMAKE_CXX_FLAGS}" "${Vc_ARCHITECTURE_FLAGS}")
string(REPLACE ";" " " Vc_ARCHITECTURE_FLAGS_STR "${Vc_ARCHITECTURE_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Vc_ARCHITECTURE_FLAGS}")

list(APPEND CMAKE_CXX_FLAGS ${Vc_ARCHITECTURE_FLAGS})
string(REPLACE ";" "  " FLAGS_STR "${CMAKE_CXX_FLAGS}")
message(STATUS "flags ${FLAGS_STR}")
set(CMAKE_CXX_FLAGS "${FLAGS_STR}")


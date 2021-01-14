set(FALCOLIBS_CMAKE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/falcolibs-repo")
set(FALCOLIBS_CMAKE_WORKING_DIR "${CMAKE_BINARY_DIR}/falcolibs-repo")

# this needs to be here at the top
if(USE_BUNDLED_DEPS)
  # explicitly force this dependency to use the bundled OpenSSL
  if(NOT MINIMAL_BUILD)
    set(USE_BUNDLED_OPENSSL ON)
  endif()
  set(USE_BUNDLED_JQ ON)
endif()

file(MAKE_DIRECTORY ${FALCOLIBS_CMAKE_WORKING_DIR})

# The falco-libs git reference (branch name, commit hash, or tag) To update falco-libs version for the next release, change the
# default below In case you want to test against another falco-libs version just pass the variable - ie., `cmake
# -DFALCOLIBS_VERSION=dev ..`
if(NOT FALCOLIBS_VERSION)
  set(FALCOLIBS_VERSION "6e60bb0b8c1ec12da66ab4ecdc4ecb0e5c553992")
  set(FALCOLIBS_CHECKSUM "SHA256=51980053583ad1f0ae399b1e501b1ac7bfd2cabade0c2686350bd8a2ad2cdf99")
endif()
set(PROBE_VERSION "${FALCOLIBS_VERSION}")

# cd /path/to/build && cmake /path/to/source
execute_process(COMMAND "${CMAKE_COMMAND}" -DFALCOLIBS_VERSION=${FALCOLIBS_VERSION} -DFALCOLIBS_CHECKSUM=${FALCOLIBS_CHECKSUM}
                        ${FALCOLIBS_CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${FALCOLIBS_CMAKE_WORKING_DIR})

# todo(leodido, fntlnz) > use the following one when CMake version will be >= 3.13

# execute_process(COMMAND "${CMAKE_COMMAND}" -B ${FALCOLIBS_CMAKE_WORKING_DIR} WORKING_DIRECTORY
# "${FALCOLIBS_CMAKE_SOURCE_DIR}")

execute_process(COMMAND "${CMAKE_COMMAND}" --build . WORKING_DIRECTORY "${FALCOLIBS_CMAKE_WORKING_DIR}")
set(FALCOLIBS_SOURCE_DIR "${FALCOLIBS_CMAKE_WORKING_DIR}/falcolibs-prefix/src/falcolibs")

# jsoncpp
set(JSONCPP_SRC "${FALCOLIBS_SOURCE_DIR}/userspace/libsinsp/third-party/jsoncpp")
set(JSONCPP_INCLUDE "${JSONCPP_SRC}")
set(JSONCPP_LIB_SRC "${JSONCPP_SRC}/jsoncpp.cpp")

# Add driver directory
add_subdirectory("${FALCOLIBS_SOURCE_DIR}/driver" "${PROJECT_BINARY_DIR}/driver")

# Add libscap directory
add_definitions(-D_GNU_SOURCE)
add_definitions(-DHAS_CAPTURE)
add_definitions(-DNOCURSESUI)
if(MUSL_OPTIMIZED_BUILD)
  add_definitions(-DMUSL_OPTIMIZED)
endif()
add_subdirectory("${FALCOLIBS_SOURCE_DIR}/userspace/libscap" "${PROJECT_BINARY_DIR}/userspace/libscap")

# Add libsinsp directory
add_subdirectory("${FALCOLIBS_SOURCE_DIR}/userspace/libsinsp" "${PROJECT_BINARY_DIR}/userspace/libsinsp")
add_dependencies(sinsp tbb b64 luajit)

# explicitly disable the tests of this dependency
set(CREATE_TEST_TARGETS OFF)

if(USE_BUNDLED_DEPS)
  add_dependencies(scap jq)
  if(NOT MINIMAL_BUILD)
    add_dependencies(scap curl grpc)
  endif()
endif()
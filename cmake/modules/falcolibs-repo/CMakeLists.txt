cmake_minimum_required(VERSION 3.5.1)

project(falcolibs-repo NONE)

include(ExternalProject)
message(STATUS "Driver version: ${FALCOLIBS_VERSION}")

ExternalProject_Add(
  falcolibs
  URL "https://github.com/leogr/falco-libs/archive/${FALCOLIBS_VERSION}.tar.gz"
  URL_HASH "${FALCOLIBS_CHECKSUM}"
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  TEST_COMMAND "")
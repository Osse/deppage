cmake_minimum_required(VERSION ${OSSE_VERSION})

project(proj)

set(CMAKE_CXX_STANDARD 20)

add_executable(proj main.cpp)

add_subdirectory(../mylib mylib)

target_link_libraries(proj mylib)

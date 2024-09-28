cmake_minimum_required(VERSION 3.28)

project(mylib)

option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

set(CMAKE_CXX_STANDARD 20)

add_library(mylib mylib.cpp)

target_include_directories(mylib PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include")

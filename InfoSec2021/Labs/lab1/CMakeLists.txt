cmake_minimum_required(VERSION 3.15)
project(lab1)

set(CMAKE_CXX_STANDARD 11)

include_directories(inc)

set(SOURCE_FILES main.cpp src/interface_ssl.cpp)
set(CMAKE_CXX_FLAGS " -L/usr/local/ssl/lib -Wall")

add_executable(lab1 ${SOURCE_FILES})

target_link_libraries(lab1 -lssl)
target_link_libraries(lab1 -lcrypto)


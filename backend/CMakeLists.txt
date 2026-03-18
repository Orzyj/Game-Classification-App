cmake_minimum_required(VERSION 3.15)
project(CppMongoBackend CXX)

# Sterownik MongoDB wymaga zazwyczaj C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Wyszukiwanie paczek pobranych przez vcpkg
find_package(bsoncxx CONFIG REQUIRED)
find_package(mongocxx CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(httplib CONFIG REQUIRED)

# Definicja pliku wykonywalnego
add_executable(my_backend 
    src/main.cpp
    src/Server.cpp)

target_include_directories(my_backend PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/include 
    ${CMAKE_CURRENT_SOURCE_DIR}/models
)

target_link_libraries(my_backend PRIVATE 
    mongo::mongocxx_static 
    mongo::bsoncxx_static
    nlohmann_json::nlohmann_json 
    httplib::httplib
)
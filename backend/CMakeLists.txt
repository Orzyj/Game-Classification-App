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

    controllers/AuditController.cpp
    controllers/CatalogController.cpp
    controllers/GameController.cpp
    controllers/ReportController.cpp
    controllers/UserController.cpp

    repositories/MongoAuditRepository.cpp
    repositories/MongoCatalogRepository.cpp
    repositories/MongoReportsRepository.cpp
    repositories/MongoUserRepository.cpp
    repositories/MongoGameRepository.cpp

    services/AuditService.cpp
    services/CatalogService.cpp
    services/GameService.cpp
    services/ReportService.cpp
    services/UserService.cpp

    src/main.cpp
)

target_include_directories(my_backend PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/include 
    ${CMAKE_CURRENT_SOURCE_DIR}/models
    ${CMAKE_CURRENT_SOURCE_DIR}/repositories
    ${CMAKE_CURRENT_SOURCE_DIR}/services
    ${CMAKE_CURRENT_SOURCE_DIR}/controllers
    ${CMAKE_CURRENT_SOURCE_DIR}/middleware
    ${CMAKE_CURRENT_SOURCE_DIR}/interfaces
)

target_link_libraries(my_backend PRIVATE 
    mongo::mongocxx_static 
    mongo::bsoncxx_static
    nlohmann_json::nlohmann_json 
    httplib::httplib
)
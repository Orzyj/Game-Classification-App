#ifndef PLATFORM_HPP
#define PLATFORM_HPP

#include <string>
#include <nlohmann/json.hpp>

struct Platform {
    std::string name;
    std::string manufacturer;
    int release_year;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Platform, name, manufacturer, release_year)
};

#endif // PLATFORM_HPP
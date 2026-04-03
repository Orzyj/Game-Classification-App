#ifndef DEVELOPER_HPP
#define DEVELOPER_HPP

#include <string>
#include <nlohmann/json.hpp>

struct Developer {
    std::string name;
    std::string country;
    int founded_year;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Developer, name, country, founded_year)
};

#endif // DEVELOPER_HPP
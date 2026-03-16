#ifndef USER_HPP
#define USER_HPP

#include <string>
#include <nlohmann/json.hpp>

struct User {
    std::string name;
    std::string email;
    std::string password;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(User, name, email, password)
};

#endif // USER_HPP
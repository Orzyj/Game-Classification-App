#ifndef USER_HPP
#define USER_HPP

#include <string>
#include <nlohmann/json.hpp>

struct User {
    std::string name;
    std::string email;
    std::string password;
    bool isEnable = true;
    bool isMod = false;

    User() = default;
    User(std::string _name, std::string _email, std::string _password) 
        : name(_name), email(_email), password(_password) {}

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(User, name, email, password, isEnable, isMod)
};

#endif // USER_HPP
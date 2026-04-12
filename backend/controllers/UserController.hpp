#ifndef USERCONTROLLER_HPP
#define USERCONTROLLER_HPP

#include "httplib.h"
#include "UserService.hpp"
#include <nlohmann/json.hpp>
#include <iostream>

class UserController {
private:
    UserService& userService;

public:
    explicit UserController(UserService& service);

    // Odpowiada za POST /api/register
    void registerUser(const httplib::Request& req, httplib::Response& res);

    // Odpowiada za POST /api/login
    void loginUser(const httplib::Request& req, httplib::Response& res);

    // Odpowiada za GET /api/users
    void getAllUsers(const httplib::Request& req, httplib::Response& res);

    // Odpowiada za DELETE /api/users/:email
    void deleteUser(const httplib::Request& req, httplib::Response& res);

    // Odpowiada za PATCH /api/user/:email/:flag
    void modUser(const httplib::Request& req, httplib::Response& res);

    // Odpowiada za PATCH /api/user/:email/:flag
    void changeUserAccountStatus(const httplib::Request& req, httplib::Response& res);
};

#endif // USERCONTROLLER_HPP
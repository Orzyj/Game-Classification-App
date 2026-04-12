#include "UserController.hpp"

UserController::UserController(UserService& service) 
    : userService(service) {

}

// Odpowiada za POST /api/register
void UserController::registerUser(const httplib::Request& req, httplib::Response& res) {
    try {
        auto j = nlohmann::json::parse(req.body);
        User new_user = j.get<User>();

        userService.registerUser(new_user);

        res.status = 201;
        res.set_content(R"({"message": "User registered successfully"})", "application/json");
    } catch (const std::invalid_argument& e) {
        nlohmann::json err_res;
        err_res["error"] = e.what();
        res.status = 400; 
        res.set_content(err_res.dump(), "application/json");
    } catch (const std::exception& e) {
        // Inne nieoczekiwane błędy
        std::cerr << "KRYTYCZNY BŁĄD W REJESTRACJI: " << e.what() << std::endl;
        nlohmann::json err_res;
        err_res["error"] = "Błąd wewnętrzny serwera";
        res.status = 500;
        res.set_content(err_res.dump(), "application/json");
    }
}

// Odpowiada za POST /api/login
void UserController::loginUser(const httplib::Request& req, httplib::Response& res) {
    try {
        auto j = nlohmann::json::parse(req.body);
        std::string email = j.value("email", "");
        std::string password = j.value("password", "");

        bool success = userService.loginUser(email, password);

        if (success) {
            bool isUserMod = userService.isUserMod(email);
            bool isUserEnable = userService.isUserEnable(email);
            std::string token = "session_" + email; 
            
            nlohmann::json response;
            response["status"] = "success";
            response["token"] = token; 
            response["user"] = email;
            response["isMod"] = isUserMod;
            response["isEnable"] = isUserEnable;

            res.set_content(response.dump(), "application/json");
        } else {
            res.status = 401;
            res.set_content(R"({"error": "Błędne dane logowania"})", "application/json");
        }
    } catch (const std::exception& e) {
        res.status = 400; 
        res.set_content(R"({"error": "Niepoprawny format JSON"})", "application/json");
    }
}

// Odpowiada za GET /api/users
void UserController::getAllUsers(const httplib::Request& req, httplib::Response& res) {
    try {
        std::vector<User> users = userService.getAllUsers();
        
        nlohmann::json users_json = nlohmann::json::array();
        for (const auto& user : users) {
            users_json.push_back(user); 
        }

        nlohmann::json response;
        response["status"] = "ok";
        response["count"] = users_json.size();
        response["users"] = users_json;
        
        res.status = 200;
        res.set_content(response.dump(), "application/json");
    } catch (const std::exception& e) {
        nlohmann::json err_res;
        err_res["status"] = "error";
        err_res["message"] = "Błąd serwera";
        res.status = 500;
        res.set_content(err_res.dump(), "application/json");
    }
}

// Odpowiada za DELETE /api/users/:email
void UserController::deleteUser(const httplib::Request& req, httplib::Response& res) {
    std::string email = req.path_params.at("email");
    nlohmann::json response;

    try {
        bool deleted = userService.deleteUser(email);

        if (deleted) {
            res.status = 200; 
            response["status"] = "ok";
            response["message"] = "Użytkownik usunięty pomyślnie.";
        } else {
            res.status = 404;
            response["error"] = "Brak takiego użytkownika";
        }
    } catch (const std::exception& e) {
        response["status"] = "error";
        response["message"] = "Błąd serwera";
        res.status = 500;
    }
    res.set_content(response.dump(), "application/json");
}

// Odpowiada za PATCH /api/user/:email/:flag
void UserController::modUser(const httplib::Request& req, httplib::Response& res) {
    std::string email = req.path_params.at("email");
    std::string flag_str = req.path_params.at("flag");
    bool flag = (flag_str == "true" || flag_str == "1");
    nlohmann::json response;

    try {
        bool success = userService.modUser(email, flag);

        if (success) {
            res.status = 200; 
            response["status"] = "ok";
            response["message"] = flag ? "Nadano uprawnienia administratora" : "Odebrano uprawnienia administratora";
        } else {
            res.status = 404;
            response["status"] = "error";
            response["message"] = "Nie znaleziono użytkownika lub nie zmieniono stanu";
        }
    } catch (const std::exception& e) {
        response["status"] = "error";
        response["message"] = "Błąd serwera";
        res.status = 500;
    }
    
    res.set_content(response.dump(), "application/json");
}

// Odpowiada za PATCH /api/user/:email/:flag
void UserController::changeUserAccountStatus(const httplib::Request& req, httplib::Response& res) {
    std::string email = req.path_params.at("email");
    std::string flag_str = req.path_params.at("flag");
    bool flag = (flag_str == "true" || flag_str == "1");
    nlohmann::json response;

    try {
        bool success = userService.changeUserAccountStatus(email, flag);

        if (success) {
            res.status = 200; 
            response["status"] = "ok";
            response["message"] = flag ? "Aktywowano użytkownika" : "Dezaktywowano";
        } else {
            res.status = 404;
            response["status"] = "error";
            response["message"] = "Nie znaleziono użytkownika lub nie zmieniono stanu";
        }
    } catch (const std::exception& e) {
        response["status"] = "error";
        response["message"] = "Błąd serwera";
        res.status = 500;
    }
    
    res.set_content(response.dump(), "application/json");
}
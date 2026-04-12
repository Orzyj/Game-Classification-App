#include "GameController.hpp"

std::string GameController::extractUserFromToken(const httplib::Request& req) {
    if (req.has_header("Authorization")) {
        std::string token = req.get_header_value("Authorization");
        if (token.length() > 8) return token.substr(8);
    }
    return "unknown_user";
}

std::string GameController::url_decode(const std::string& encoded) {
    std::string decoded;
    decoded.reserve(encoded.length()); 
    for (size_t i = 0; i < encoded.length(); ++i) {
        if (encoded[i] == '+') decoded += ' ';
        else if (encoded[i] == '%' && i + 2 < encoded.length()) {
            std::string hexStr = encoded.substr(i + 1, 2);
            try {
                decoded += static_cast<char>(std::stoi(hexStr, nullptr, 16));
                i += 2; 
            } catch (...) { decoded += '%'; }
        } else decoded += encoded[i];
    }
    return decoded;
}

GameController::GameController(GameService& service) 
: gameService(service) {

}

// GET /api/games
void GameController::getGames(const httplib::Request& req, httplib::Response& res) {
    try {
        int limit = req.has_param("limit") ? std::stoi(req.get_param_value("limit")) : 20;

        std::map<std::string, std::string> query_params;
        for (const auto& param : req.params) {
            if (param.first != "limit") {
                query_params[param.first] = url_decode(param.second);
            }
        }

        auto games = gameService.getGames(limit, query_params);
        
        nlohmann::json response = {
            {"status", "ok"},
            {"count", games.size()},
            {"games", games} 
        };
        res.set_content(response.dump(), "application/json");

    } catch (const std::exception& e) {
        res.status = 500;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    }
}

// POST /api/addgames
void GameController::addGame(const httplib::Request& req, httplib::Response& res) {
    try {
        auto j = nlohmann::json::parse(req.body);
        Game new_game = j.get<Game>();
        std::string userEmail = extractUserFromToken(req);

        gameService.addGame(new_game, userEmail);

        res.status = 201;
        res.set_content(R"({"status": "success", "message": "Gra dodana pomyślnie"})", "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 400;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) {
        res.status = 500;
        res.set_content(nlohmann::json{{"error", "Błąd wewnętrzny"}}.dump(), "application/json");
    }
}

// DELETE /api/games/:title
void GameController::deleteGame(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string title = url_decode(req.path_params.at("title"));
        std::string userEmail = extractUserFromToken(req);

        gameService.deleteGame(title, userEmail);

        res.status = 200;
        res.set_content(R"({"status": "ok", "message": "Gra usunięta pomyślnie."})", "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 404; 
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    }
}

// PUT /api/games/:title
void GameController::updateGame(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string title = url_decode(req.path_params.at("title"));
        auto j = nlohmann::json::parse(req.body);
        std::string userEmail = extractUserFromToken(req);

        gameService.updateGame(title, j.value("developer", ""), j.value("release_year", 2024), j.value("genre", ""), userEmail);

        res.status = 200;
        res.set_content(R"({"status": "ok", "message": "Gra zaktualizowana pomyślnie."})", "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 404;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    }
}

// POST /api/games/:title/rating
void GameController::rateGame(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string title = url_decode(req.path_params.at("title"));
        auto j = nlohmann::json::parse(req.body);
        std::string email = j.value("email", "");
        std::string vote = j.value("vote", "");

        gameService.rateGame(title, email, vote);

        res.status = 200;
        res.set_content(R"({"status": "ok", "message": "Twój głos został pomyślnie dodany!"})", "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 404;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::logic_error& e) {
        res.status = 403;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) {
        res.status = 500;
        res.set_content(nlohmann::json{{"error", "Błąd serwera"}}.dump(), "application/json");
    }
}

// POST /api/games/:title/comments
void GameController::addComment(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string title = url_decode(req.path_params.at("title"));
        auto j = nlohmann::json::parse(req.body);
        std::string author = extractUserFromToken(req);
        
        gameService.addComment(title, author, j.value("content", ""));

        res.status = 200;
        res.set_content(R"({"status": "ok", "message": "Komentarz dodany!"})", "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 404;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) { 
        res.status = 400;
        res.set_content(nlohmann::json{{"error", std::string("Błąd: ") + e.what()}}.dump(), "application/json");
    }
}

// DELETE /api/games/:title/comments/:index
void GameController::deleteComment(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string title = url_decode(req.path_params.at("title"));
        std::string index = req.path_params.at("index");
        std::string userEmail = extractUserFromToken(req);

        gameService.deleteComment(title, index, userEmail);

        res.status = 200;
        res.set_content(R"({"status": "ok", "message": "Komentarz usunięty pomyślnie."})", "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 404;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) { 
        res.status = 500;
        res.set_content(nlohmann::json{{"error", "Błąd serwera"}}.dump(), "application/json");
    }
}
// PATCH /api/games/:title/comments/:index
void GameController::updateComment(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string title = url_decode(req.path_params.at("title"));
        std::string index = req.path_params.at("index");
        std::string userEmail = extractUserFromToken(req);

        auto json_body = nlohmann::json::parse(req.body);
        if (!json_body.contains("content")) {
            res.status = 400; // Bad Request
            res.set_content(R"({"error": "Brak pola 'content' w ciele zapytania"})", "application/json");
            return;
        }
        std::string newContent = json_body["content"];
        gameService.updateComment(title, index, userEmail, newContent);
        res.status = 200;
        res.set_content(R"({"status": "ok", "message": "Komentarz zaktualizowany pomyślnie."})", "application/json");

    } catch (const nlohmann::json::exception& e) {
        res.status = 400;
        res.set_content(nlohmann::json{{"error", "Nieprawidłowy format JSON"}}.dump(), "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 404; 
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) { 
        res.status = 500;
        res.set_content(nlohmann::json{{"error", "Błąd serwera"}}.dump(), "application/json");
    }
}

// POST /api/games/:title/image
void GameController::uploadImage(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string title = url_decode(req.path_params.at("title"));
        std::string userEmail = extractUserFromToken(req);

        if (req.body.empty()) {
            res.status = 400;
            res.set_content(R"({"error": "Brak danych obrazka."})", "application/json");
            return;
        }

        std::string ext = req.has_header("X-File-Name") ? "_" + req.get_header_value("X-File-Name") : ".jpg";
        std::string file_name = title + ext;
        std::string physical_path = "./uploads/" + file_name;
        std::string url_path = "/uploads/" + file_name;

        if (!std::filesystem::exists("./uploads")) std::filesystem::create_directory("./uploads");

        std::ofstream ofs(physical_path, std::ios::binary);
        if (!ofs.is_open()) throw std::runtime_error("Błąd zapisu pliku na dysku.");
        ofs.write(req.body.data(), req.body.size());
        ofs.close();

        gameService.setGameImage(title, url_path, userEmail);

        res.status = 200;
        res.set_content(nlohmann::json{{"status", "ok"}, {"message", "Zdjęcie wgrane pomyślnie!"}, {"image_url", url_path}}.dump(), "application/json");
    } catch (const std::invalid_argument& e) {
        res.status = 404;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) {
        res.status = 500;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    }
}
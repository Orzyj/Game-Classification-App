#ifndef GAMECONTROLLER_HPP
#define GAMECONTROLLER_HPP

#include "httplib.h"
#include "GameService.hpp"
#include <nlohmann/json.hpp>
#include <iostream>
#include <fstream>
#include <filesystem>
#include <map>

class GameController {
private:
    GameService& gameService;

    std::string extractUserFromToken(const httplib::Request& req);

    std::string url_decode(const std::string& encoded);

public:
    explicit GameController(GameService& service);

    // GET /api/games
    void getGames(const httplib::Request& req, httplib::Response& res);

    // POST /api/addgames
    void addGame(const httplib::Request& req, httplib::Response& res);

    // DELETE /api/games/:title
    void deleteGame(const httplib::Request& req, httplib::Response& res);

    // PUT /api/games/:title
    void updateGame(const httplib::Request& req, httplib::Response& res);

    // POST /api/games/:title/rating
    void rateGame(const httplib::Request& req, httplib::Response& res);

    // POST /api/games/:title/comments
    void addComment(const httplib::Request& req, httplib::Response& res);

    // DELETE /api/games/:title/comments/:index
    void deleteComment(const httplib::Request& req, httplib::Response& res);
    // PATCH /api/games/:title/comments/:index
    void updateComment(const httplib::Request& req, httplib::Response& res);

    // POST /api/games/:title/image
    void uploadImage(const httplib::Request& req, httplib::Response& res);
};

#endif // GAMECONTROLLER_HPP
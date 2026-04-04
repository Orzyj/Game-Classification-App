#ifndef IGAMEREPOSITORY_HPP
#define IGAMEREPOSITORY_HPP

#include <vector>
#include <string>
#include <map>
#include "Game.hpp"
#include <nlohmann/json.hpp>

class IGameRepository {
public:
    virtual ~IGameRepository() = default;

    virtual void insertGame(const Game& game) = 0;
    virtual bool deleteGame(const std::string& title) = 0;
    virtual bool updateGame(const std::string& title, const std::string& dev, int year, const std::string& genre) = 0;
    
    virtual std::vector<nlohmann::json> getGames(int limit, const std::map<std::string, std::string>& filters) = 0;
    virtual bool gameExists(const std::string& title, const int& year, const std::string& dev) = 0;

    virtual int addRating(const std::string& title, const std::string& email, bool isUpvote) = 0;
    virtual bool addComment(const std::string& title, const nlohmann::json& commentJson) = 0;
    virtual bool deleteComment(const std::string& title, const std::string& commentIndex) = 0;
    virtual bool updateComment(
        const std::string& title, 
        const std::string& commentIndex, 
        const std::string& author, 
        const std::string& newContent) = 0;
    virtual bool updateGameImage(const std::string& title, const std::string& imageUrl) = 0;
};

#endif // IGAMEREPOSITORY_HPP
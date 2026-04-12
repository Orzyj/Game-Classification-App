#ifndef MONGOGAMEREPOSITORY_HPP
#define MONGOGAMEREPOSITORY_HPP

#include "IGameRepository.hpp"
#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/types.hpp>
#include <bsoncxx/json.hpp> // Wymagane!
#include <iostream>
using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

class MongoGameRepository : public IGameRepository {
private:
    const std::map<std::string, std::vector<std::string>> FILTER_KEYS {
        {"classification",{"genre", "subgenre","theme", "difficulty"}},
        {"technical_stats",{"engine", "average_playtime_hours","theme"}},
        {"title",{"title"}},
        {"developer", {"developer"}},
        {"release_year",{"release_year"}}
    };

    mongocxx::database db;

public:
    explicit MongoGameRepository(mongocxx::database database);

    void insertGame(const Game& game) override;

    bool deleteGame(const std::string& title) override;

    bool updateGame(const std::string& title, const std::string& dev, int year, const std::string& genre) override;

    std::vector<nlohmann::json> getGames(int limit, const std::map<std::string, std::string>& filters) override;

    bool gameExists(const std::string& title, const int& year, const std::string& dev) override;

    int addRating(const std::string& title, const std::string& email, bool isUpvote) override;

    bool addComment(const std::string& title, const nlohmann::json& commentJson) override;

    bool deleteComment(const std::string& title, const std::string& commentIndex) override;

    bool updateGameImage(const std::string& title, const std::string& imageUrl) override;

    bool updateComment(
        const std::string& title, 
        const std::string& commentIndex, 
        const std::string& author,
        const std::string& newContent) override;
};

#endif // MONGOGAMEREPOSITORY_HPP
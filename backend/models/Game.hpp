#ifndef GAME_HPP
#define GAME_HPP

#include <string>
#include <vector>
#include <nlohmann/json.hpp>

#include "Comment.hpp"
#include "User.hpp"

struct Classification {
    std::string genre;
    std::string subgenre;
    std::string theme;
    std::string difficulty;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Classification, genre, subgenre, theme, difficulty)
};

struct TechnicalStats {
    std::string engine;
    int average_playtime_hours;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(TechnicalStats, engine, average_playtime_hours)
};

struct Game {
    std::string title;
    std::string developer;
    int release_year;
    int rating_up;
    int rating_down;
    
    Classification classification;
    TechnicalStats technical_stats;
    std::vector<Comment> comments;
    std::vector<std::string> rated_emails;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Game, title, developer, release_year, classification, technical_stats)
};

#endif // GAME.HPP
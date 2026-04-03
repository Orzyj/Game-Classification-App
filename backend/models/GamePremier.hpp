#ifndef GAMEPREMIER_HPP
#define GAMEPREMIER_HPP

#include <string>
#include <nlohmann/json.hpp>

struct GamePremier {
    std::string title;
    std::string developer;
    std::string platform;
    std::string release_date; 
    int hype_score;           
    bool is_exclusive;       

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(GamePremier, title, developer, platform, release_date, hype_score, is_exclusive)
};

#endif // GAMEPREMIER_HPP
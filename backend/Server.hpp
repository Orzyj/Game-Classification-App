#ifndef SERVER_HPP
#define SERVER_HPP

#include <cstdlib>
#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <httplib.h>

#include <nlohmann/json.hpp>

#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/uri.hpp>

#include <bsoncxx/json.hpp>

using json = nlohmann::json;

class Server {
private:
    mongocxx::instance m_instance{};
    const char* m_mongo_uri_env;
    std::string m_mongo_uri;
    mongocxx::client m_client;
    httplib::Server m_svr;

    // key , values
    std::map<std::string, std::vector<std::string>> FILTER_KEYS {
        {"classification",{"genre", "subgenre","theme", "difficulty"}},
        {"technical_stats",{"engine", "average_playtime_hours","theme"}},
        {"title",{}},
        {"developer", {}},
        {"release_year",{}}
    };

    std::vector<std::string> FILTER_KEYS_USER = {
        "name", "email", "password"
    };

    void setup_status_routes();
    void setup_games_routes();
    void setup_user_routes();
    void seed_test_data();

public:
    Server();
    void start();

};

#endif // SERVER.HPP
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
#include <mutex>

#include <bsoncxx/json.hpp>

using json = nlohmann::json;

class Server {
private:
    mongocxx::instance m_instance{};
    const char* m_mongo_uri_env;
    std::string m_mongo_uri;
    mongocxx::client m_client;
    httplib::Server m_svr;
    std::mutex m_db_mutex;

    // key , values
    const std::map<std::string, std::vector<std::string>> FILTER_KEYS {
        {"classification",{"genre", "subgenre","theme", "difficulty"}},
        {"technical_stats",{"engine", "average_playtime_hours","theme"}},
        {"title",{"title"}},
        {"developer", {"developer"}},
        {"release_year",{"release_year"}}
    };

    const std::vector<std::string> FILTER_KEYS_USER = {
        "name", "email", "password"
    };
      
    void setup_rating_routes();
    void setup_status_routes();
    void setup_games_routes();
    void setup_user_routes();
    void setup_files_routes();
    void setup_developers_routes();
    void setup_logs_routes();
    void setup_platforms_routes();
    void setup_reports_routes();
    void setup_premiere_routes();

    void log_activity(const std::string& email, const std::string& action, const std::string& details);

public:
    Server();
    void start();

    std::string url_decode(const std::string& encoded);

};

#endif // SERVER.HPP
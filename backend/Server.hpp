#include <cstdlib>
#include <iostream>

#include <httplib.h>
#include <nlohmann/json.hpp>

#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/uri.hpp>

using json = nlohmann::json;

class Server {
private:
    mongocxx::instance m_instance{};
    const char* m_mongo_uri_env;
    std::string m_mongo_uri;
    mongocxx::client m_client;
    httplib::Server m_svr;

    void setup_status_routes();

public:
    Server();
    void start();

};
#include "Server.hpp"

Server::Server() {
    m_mongo_uri_env = std::getenv("MONGO_URI");
    m_mongo_uri = m_mongo_uri_env ? m_mongo_uri_env : "mongodb://mongodb:27017";
    m_client = mongocxx::client{mongocxx::uri{m_mongo_uri}};
}

void Server::start() {
    setup_status_routes();

    std::cout << "Serwer startuje na porcie 8080..." << std::endl;
    m_svr.listen("0.0.0.0", 8080);
}

void Server::setup_status_routes() {

    // [http://localhost:8080/api/status]
    m_svr.Get("/api/status", [this](const httplib::Request&, httplib::Response& res) {
        nlohmann::json response;
        response["status"] = "ok";
        response["message"] = "Status Serwera [OK]";
        
        try {
            auto db = m_client["test_db"];
            auto collections = db.list_collection_names();
            response["db_connection"] = "success";
            response["collections_count"] = std::distance(collections.begin(), collections.end());
        } catch (const std::exception& e) {
            response["db_connection"] = "failed";
            response["db_error"] = e.what();
        }

        res.set_content(response.dump(), "application/json");
    });
}
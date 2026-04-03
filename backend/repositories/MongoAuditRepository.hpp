#ifndef MONGOAUDITREPOSITORY_HPP
#define MONGOAUDITREPOSITORY_HPP

#include "IAuditRepository.hpp"
#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/json.hpp>
#include <iostream>

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

class MongoAuditRepository : public IAuditRepository {
private:
    mongocxx::database db;

public:
    //DI
    explicit MongoAuditRepository(mongocxx::database database) : db(std::move(database)) {}

    void insertLog(const AuditLog& log) override {
        try {
            auto collection = db["audit_logs"];
            auto doc = make_document(
                kvp("timestamp", log.timestamp),
                kvp("email", log.email),
                kvp("action", log.action),
                kvp("details", log.details)
            );
            collection.insert_one(doc.view());
        } catch (const std::exception& e) {
            std::cerr << "[MongoAuditRepository] Błąd zapisu logu: " << e.what() << std::endl;
        }
    }

    std::vector<AuditLog> getRecentLogs(int limit) override {
        std::vector<AuditLog> logs;
        try {
            auto collection = db["audit_logs"];
            
            mongocxx::options::find opts{};
            opts.sort(make_document(kvp("timestamp", -1)));
            opts.limit(limit); 

            auto cursor = collection.find({}, opts);

            for(auto&& doc : cursor) {
                auto j = nlohmann::json::parse(bsoncxx::to_json(doc));
                logs.emplace_back(
                    j.value("timestamp", ""),
                    j.value("email", ""),
                    j.value("action", ""),
                    j.value("details", "")
                );
            }
        } catch (const std::exception& e) {
            std::cerr << "[MongoAuditRepository] Błąd odczytu logów: " << e.what() << std::endl;
            throw; 
        }
        return logs;
    }
};

#endif // MONGOAUDITREPOSITORY_HPP
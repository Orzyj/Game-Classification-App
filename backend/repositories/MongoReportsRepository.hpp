#ifndef MONGOREPORTREPOSITORY_HPP
#define MONGOREPORTREPOSITORY_HPP

#include "IReportRepository.hpp"
#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/builder/stream/document.hpp> 
#include <bsoncxx/oid.hpp>      
#include <bsoncxx/json.hpp>               
#include <nlohmann/json.hpp>
#include <iostream>

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

class MongoReportRepository : public IReportRepository {
private:
    mongocxx::database db;

public:
    // DI
    explicit MongoReportRepository(mongocxx::database database) : db(std::move(database)) {}

    bool insertReport(const Ticket& ticket) override {
        try {
            auto collection = db["reports"];
            
            nlohmann::json j = ticket; 
            auto doc = bsoncxx::from_json(j.dump());
            
            auto result = collection.insert_one(doc.view());

            return result ? true : false;
        } catch (const std::exception& e) {
            std::cerr << "[MongoReportRepository] Błąd zapisu zgłoszenia: " << e.what() << std::endl;
            return false;
        }
    }

    std::vector<nlohmann::json> getAllReports() override {
        std::vector<nlohmann::json> reports;
        try {
            auto collection = db["reports"];
            auto cursor = collection.find({});
            
            for(auto&& doc : cursor) 
                reports.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            
        } catch (const std::exception& e) {
            std::cerr << "[MongoReportRepository] Błąd odczytu zgłoszeń: " << e.what() << std::endl;
        }

        return reports;
    }

    bool deleteReport(const std::string& report_id) override {
        try {
            auto collection = db["reports"]; 
            
            auto result = collection.delete_one(
                bsoncxx::builder::stream::document{} 
                << "_id" << bsoncxx::oid{report_id} 
                << bsoncxx::builder::stream::finalize
            );

            return (result && result->deleted_count() > 0) ? true : false;
        } catch (const std::exception& e) {
            std::cerr << "[MongoReportRepository] Błąd usuwania zgłoszenia: " << e.what() << std::endl;
            return false;
        }
    }
}; 

#endif // MONGOREPORTREPOSITORY_HPP
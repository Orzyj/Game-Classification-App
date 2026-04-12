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
    explicit MongoReportRepository(mongocxx::database database);

    bool insertReport(const Ticket& ticket) override;

    std::vector<nlohmann::json> getAllReports() override;

    bool deleteReport(const std::string& report_id) override;
}; 

#endif // MONGOREPORTREPOSITORY_HPP
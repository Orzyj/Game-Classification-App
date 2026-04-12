#include "MongoReportsRepository.hpp"

MongoReportRepository::MongoReportRepository(mongocxx::database database) 
: db(std::move(database)) {

}

bool MongoReportRepository::insertReport(const Ticket& ticket) {
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

std::vector<nlohmann::json> MongoReportRepository::getAllReports() {
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

bool MongoReportRepository::deleteReport(const std::string& report_id) {
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
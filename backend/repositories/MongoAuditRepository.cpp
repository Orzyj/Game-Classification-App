#include "MongoAuditRepository.hpp"

MongoAuditRepository::MongoAuditRepository(mongocxx::database database) 
: db(std::move(database)) {

}

void MongoAuditRepository::insertLog(const AuditLog& log) {
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

std::vector<AuditLog> MongoAuditRepository::getRecentLogs(int limit) {
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
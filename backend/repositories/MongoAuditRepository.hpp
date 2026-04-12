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
    explicit MongoAuditRepository(mongocxx::database database);

    void insertLog(const AuditLog& log) override;

    std::vector<AuditLog> getRecentLogs(int limit) override;
};

#endif // MONGOAUDITREPOSITORY_HPP
#ifndef MONGOUSERREPOSITORY_HPP
#define MONGOUSERREPOSITORY_HPP

#include "IUserRepository.hpp"
#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <nlohmann/json.hpp>
#include <bsoncxx/json.hpp>
#include <iostream>

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

class MongoUserRepository : public IUserRepository {
private:
    mongocxx::database db;

public:
    // Wstrzykiwanie zależności - poprawiona literówka w 'database'
    explicit MongoUserRepository(mongocxx::database database);

    bool userExists(const std::string& email) override;

    void insertUser(const User& user) override;

    bool validateCredentials(const std::string& email, const std::string& password) override;

    std::vector<User> getAllUsers() override;

    bool deleteUser(const std::string& email) override;

    bool modUser(const std::string& email, const bool& flag) override;

    bool chagneUserAccountStatus(const std::string& email, const bool& flag) override;

    bool isUserMod(const std::string& email) override;

    bool isUserEnable(const std::string& email) override;
}; 

#endif // MONGOUSERREPOSITORY_HPP
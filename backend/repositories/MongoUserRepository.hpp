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
    explicit MongoUserRepository(mongocxx::database database) : db(std::move(database)) {}

    bool userExists(const std::string& email) override {
        try {
            auto collection = db["users"];
            // Poprawione collection i literówka 'email'
            auto existing = collection.find_one(make_document(kvp("email", email)));
            return existing ? true : false; 
        } catch (const std::exception& e) {
            std::cerr << "[MongoUserRepository] Błąd znajdowania użytkownika: " << e.what() << std::endl;
            return false; // Zabezpieczenie przed undefined behavior
        }
    }

    void insertUser(const User& user) override {
        try {
            auto collection = db["users"];
            // Konwersja obiektu User -> nlohmann::json -> BSON Document
            nlohmann::json j = user;
            auto doc = bsoncxx::from_json(j.dump());
            collection.insert_one(doc.view());
        } catch (const std::exception& e) {
            std::cerr << "[MongoUserRepository] Błąd dodawania użytkownika: " << e.what() << std::endl;
        }
    }

    bool validateCredentials(const std::string& email, const std::string& password) override {
        try {
            auto user_doc_exist = db["users"].find_one(make_document(
                kvp("email", email),
                kvp("password", password)
            ));

            return user_doc_exist ? true : false; 
        } catch (const std::exception& e) {
            std::cerr << "[MongoUserRepository] Błąd logowania użytkownika: " << e.what() << std::endl;
            return false; // Zabezpieczenie
        }
    }

    std::vector<User> getAllUsers() override {
        std::vector<User> users;

        try { 
            auto collection = db["users"]; 
            auto cursor = collection.find({});

            for(auto&& doc : cursor) {
                auto j = nlohmann::json::parse(bsoncxx::to_json(doc));
                users.push_back(j.get<User>()); 
            }
            
        } catch (const std::exception& e) {
            std::cerr << "[MongoUserRepository] Błąd pobierania bazy: " << e.what() << std::endl;
        }

        return users;
    }

    bool deleteUser(const std::string& email) override {
        try {
            auto collection = db["users"];
            auto filter = make_document(kvp("email", email));
            auto result = collection.delete_one(filter.view());

            return (result && result->deleted_count() > 0) ? true : false;
        } catch (const std::exception& e) {
            std::cerr << "[MongoUserRepository] Błąd usuwania: " << e.what() << std::endl;
            return false;
        }
    }
}; 

#endif // MONGOUSERREPOSITORY_HPP
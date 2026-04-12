#include "MongoUserRepository.hpp"

MongoUserRepository::MongoUserRepository(mongocxx::database database) 
: db(std::move(database)) {

}

bool MongoUserRepository::userExists(const std::string& email) {
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

void MongoUserRepository::insertUser(const User& user) {
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

bool MongoUserRepository::validateCredentials(const std::string& email, const std::string& password) {
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

std::vector<User> MongoUserRepository::getAllUsers() {
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

bool MongoUserRepository::deleteUser(const std::string& email) {
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

bool MongoUserRepository::modUser(const std::string& email, const bool& flag) {
    try {
        auto collection = db["users"];
        auto filter = make_document(kvp("email", email));
        auto update = make_document(kvp("$set", make_document(kvp("isMod", flag))));
        auto result = collection.update_one(filter.view(), update.view());

        return (result && result->modified_count() > 0) ? true : false;
        
    } catch (const std::exception& e) {
        std::cerr << "[MongoUserRepository] Błąd nadawania uprawnien: " << e.what() << std::endl;
        return false;
    }
}

bool MongoUserRepository::chagneUserAccountStatus(const std::string& email, const bool& flag) {
    try {
        auto collection = db["users"];
        auto filter = make_document(kvp("email", email));
        auto update = make_document(kvp("$set", make_document(kvp("isEnable", flag))));
        auto result = collection.update_one(filter.view(), update.view());

        return (result && result->modified_count() > 0) ? true : false;
        
    } catch (const std::exception& e) {
        std::cerr << "[MongoUserRepository] Błąd aktualizowania konta użytkownika: " << e.what() << std::endl;
        return false;
    }
}

bool MongoUserRepository::isUserMod(const std::string& email) {
    try {
        auto userCredentials = db["users"].find_one(
            make_document(
                kvp("email", email)
            )
        );

        if(userCredentials) {
            bsoncxx::document::view view = userCredentials->view();
            auto isModField = view["isMod"];

            if(isModField && isModField.type() == bsoncxx::type::k_bool) {
                return isModField.get_bool().value;
            }
        } 
        return false;
        
    } catch (const std::exception& e) {
        std::cerr << "[MongoUserRepository] Błąd podczas sprawdzania uprawnień konta: " << e.what() << std::endl;
        return false;
    }
}

bool MongoUserRepository::isUserEnable(const std::string& email) {
    try {
        auto userCredentials = db["users"].find_one(
            make_document(
                kvp("email", email)
            )
        );

        if(userCredentials) {
            bsoncxx::document::view view = userCredentials->view();
            auto isEnableField = view["isEnable"];

            if(isEnableField && isEnableField.type() == bsoncxx::type::k_bool) {
                return isEnableField.get_bool().value;
            }
        } 
        return false;
    } catch (const std::exception& e) {
        std::cerr << "[MongoUserRepository] Błąd podczas sprawdzanai status konta: " << e.what() << std::endl;
        return false;
    }
}
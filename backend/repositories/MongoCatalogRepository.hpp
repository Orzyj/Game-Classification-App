#ifndef MONGOCATALOGREPOSITORY_HPP
#define MONGOCATALOGREPOSITORY_HPP

#include "ICatalogRepository.hpp"
#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/json.hpp>
#include <nlohmann/json.hpp>
#include <iostream>

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

class MongoCatalogRepository : public ICatalogRepository {
private:
    mongocxx::database db;

public:
    // Wstrzykiwanie połączenia do bazy (DI)
    explicit MongoCatalogRepository(mongocxx::database database);

    // ==========================================
    // DEWELOPERZY
    // ==========================================
    bool insertDeveloper(const Developer& dev);

    std::vector<Developer> getAllDevelopers() override;

    bool deleteDeveloper(const std::string& name) override;

    // ==========================================
    // PLATFORMY
    // ==========================================
    bool insertPlatform(const Platform& platform) override;

    std::vector<Platform> getAllPlatforms() override;

    bool deletePlatform(const std::string& name) override;

    // ==========================================
    // PREMIERY
    // ==========================================
    bool insertPremiere(const GamePremier& premiere) override;

    std::vector<GamePremier> getAllPremieres() override;
};

#endif // MONGOCATALOGREPOSITORY_HPP
#include "MongoCatalogRepository.hpp"

MongoCatalogRepository::MongoCatalogRepository(mongocxx::database database) 
: db(std::move(database)) {}

// ==========================================
// DEWELOPERZY
// ==========================================
bool MongoCatalogRepository::insertDeveloper(const Developer& dev) {
    try {
        auto collection = db["developers"];
        nlohmann::json j = dev;
        auto doc = bsoncxx::from_json(j.dump());
        auto result = collection.insert_one(doc.view());
        return result ? true : false;
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd dodawania dewelopera: " << e.what() << std::endl;
        return false;
    }
}

std::vector<Developer> MongoCatalogRepository::getAllDevelopers() {
    std::vector<Developer> devs;
    try {
        auto collection = db["developers"];
        auto cursor = collection.find({});
        for (auto&& doc : cursor) {
            auto j = nlohmann::json::parse(bsoncxx::to_json(doc));
            devs.push_back(j.get<Developer>()); // Magia nlohmann_json
        }
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd odczytu deweloperów: " << e.what() << std::endl;
    }
    return devs;
}

bool MongoCatalogRepository::deleteDeveloper(const std::string& name) {
    try {
        auto collection = db["developers"];
        auto filter = make_document(kvp("name", name));
        auto result = collection.delete_one(filter.view());
        return (result && result->deleted_count() > 0);
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd usuwania dewelopera: " << e.what() << std::endl;
        return false;
    }
}

// ==========================================
// PLATFORMY
// ==========================================
bool MongoCatalogRepository::insertPlatform(const Platform& platform) {
    try {
        auto collection = db["platforms"];
        nlohmann::json j = platform;
        auto doc = bsoncxx::from_json(j.dump());
        auto result = collection.insert_one(doc.view());
        return result ? true : false;
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd dodawania platformy: " << e.what() << std::endl;
        return false;
    }
}

std::vector<Platform> MongoCatalogRepository::getAllPlatforms() {
    std::vector<Platform> platforms;
    try {
        auto collection = db["platforms"];
        auto cursor = collection.find({});
        for (auto&& doc : cursor) {
            auto j = nlohmann::json::parse(bsoncxx::to_json(doc));
            platforms.push_back(j.get<Platform>());
        }
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd odczytu platform: " << e.what() << std::endl;
    }
    return platforms;
}

bool MongoCatalogRepository::deletePlatform(const std::string& name) {
    try {
        auto collection = db["platforms"];
        auto filter = make_document(kvp("name", name));
        auto result = collection.delete_one(filter.view());
        return (result && result->deleted_count() > 0);
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd usuwania platformy: " << e.what() << std::endl;
        return false;
    }
}

// ==========================================
// PREMIERY
// ==========================================
bool MongoCatalogRepository::insertPremiere(const GamePremier& premiere) {
    try {
        // Uwaga: w Twoim starym kodzie kolekcja nazywała się "premiers"
        auto collection = db["premiers"]; 
        nlohmann::json j = premiere;
        auto doc = bsoncxx::from_json(j.dump());
        auto result = collection.insert_one(doc.view());
        return result ? true : false;
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd dodawania premiery: " << e.what() << std::endl;
        return false;
    }
}

std::vector<GamePremier> MongoCatalogRepository::getAllPremieres() {
    std::vector<GamePremier> premieres;
    try {
        auto collection = db["premiers"];
        
        // Zachowanie Twojej logiki sortowania po dacie!
        mongocxx::options::find opts{};
        opts.sort(make_document(kvp("release_date", 1)));

        auto cursor = collection.find({}, opts);
        for (auto&& doc : cursor) {
            auto j = nlohmann::json::parse(bsoncxx::to_json(doc));
            premieres.push_back(j.get<GamePremier>());
        }
    } catch (const std::exception& e) {
        std::cerr << "[MongoCatalog] Błąd odczytu premier: " << e.what() << std::endl;
    }
    return premieres;
}
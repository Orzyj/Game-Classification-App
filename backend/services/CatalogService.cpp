#include "CatalogService.hpp"

CatalogService::CatalogService(ICatalogRepository& catalogRepo, AuditService& audit) 
    : catalogRepository(catalogRepo), auditService(audit) {}

void CatalogService::addDeveloper(const Developer& dev, const std::string& adminEmail) {
    if (dev.name.empty()) {
        throw std::invalid_argument("Nazwa dewelopera nie może być pusta.");
    }

    bool success = catalogRepository.insertDeveloper(dev);
    if (!success) {
        throw std::runtime_error("Nie udało się zapisać dewelopera do bazy.");
    }

    auditService.logActivity(adminEmail, "DEVELOPER_ADDED", "Dodano studio deweloperskie: " + dev.name);
}

std::vector<Developer> CatalogService::getAllDevelopers() {
    return catalogRepository.getAllDevelopers();
}

void CatalogService::deleteDeveloper(const std::string& name, const std::string& adminEmail) {
    bool deleted = catalogRepository.deleteDeveloper(name);
    if (!deleted) {
        throw std::invalid_argument("Nie znaleziono dewelopera do usunięcia.");
    }

    auditService.logActivity(adminEmail, "DEVELOPER_DELETED", "Usunięto studio deweloperskie: " + name);
}

void CatalogService::addPlatform(const Platform& platform, const std::string& adminEmail) {
    if (platform.name.empty()) {
        throw std::invalid_argument("Nazwa platformy nie może być pusta.");
    }

    bool success = catalogRepository.insertPlatform(platform);
    if (!success) {
        throw std::runtime_error("Nie udało się zapisać platformy do bazy.");
    }

    auditService.logActivity(adminEmail, "PLATFORM_ADDED", "Dodano platformę: " + platform.name);
}

std::vector<Platform> CatalogService::getAllPlatforms() {
    return catalogRepository.getAllPlatforms();
}

void CatalogService::deletePlatform(const std::string& name, const std::string& adminEmail) {
    bool deleted = catalogRepository.deletePlatform(name);
    if (!deleted) {
        throw std::invalid_argument("Nie znaleziono platformy do usunięcia.");
    }

    auditService.logActivity(adminEmail, "PLATFORM_DELETED", "Usunięto platformę: " + name);
}


void CatalogService::addPremiere(const GamePremier& premiere, const std::string& adminEmail) {
    bool success = catalogRepository.insertPremiere(premiere);
    if (!success) {
        throw std::runtime_error("Nie udało się zapisać premiery do bazy.");
    }

    auditService.logActivity(adminEmail, "PREMIERE_ADDED", "Dodano datę premiery dla gry");
}

std::vector<GamePremier> CatalogService::getAllPremieres() {
    return catalogRepository.getAllPremieres();
}
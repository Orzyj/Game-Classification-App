#ifndef CATALOGSERVICE_HPP
#define CATALOGSERVICE_HPP

#include "ICatalogRepository.hpp"
#include "AuditService.hpp"
#include <stdexcept>
#include <string>

/**
 * @class CatalogService
 * @brief Usługa aplikacji zarządzająca słownikami systemowymi (Deweloperzy, Platformy, Premiery).
 */
class CatalogService {
private:
    ICatalogRepository& catalogRepository;
    AuditService& auditService;

public:
    // DI
    explicit CatalogService(ICatalogRepository& catalogRepo, AuditService& audit);

    // ==========================================
    // DEWELOPERZY
    // ==========================================
    void addDeveloper(const Developer& dev, const std::string& adminEmail);

    std::vector<Developer> getAllDevelopers();

    void deleteDeveloper(const std::string& name, const std::string& adminEmail);

    // ==========================================
    // PLATFORMY
    // ==========================================
    void addPlatform(const Platform& platform, const std::string& adminEmail);

    std::vector<Platform> getAllPlatforms();

    void deletePlatform(const std::string& name, const std::string& adminEmail);

    // ==========================================
    // PREMIERY
    // ==========================================
    void addPremiere(const GamePremier& premiere, const std::string& adminEmail);

    std::vector<GamePremier> getAllPremieres();
};

#endif // CATALOGSERVICE_HPP
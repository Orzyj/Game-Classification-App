#ifndef ICATALOGREPOSITORY_HPP
#define ICATALOGREPOSITORY_HPP

#include <vector>
#include <string>

// Twoje modele danych
#include "Developer.hpp"
#include "Platform.hpp"
#include "GamePremier.hpp"

/**
 * @class ICatalogRepository
 * @brief Interfejs repozytorium dla prostych słowników/katalogów w systemie.
 * Grupuje operacje na deweloperach, platformach i premierach, aby unikać 
 * tworzenia wielu małych, niemal identycznych klas.
 */
class ICatalogRepository {
public:
    virtual ~ICatalogRepository() = default;

    // ==========================================
    // DEWELOPERZY
    // ==========================================
    virtual bool insertDeveloper(const Developer& dev) = 0;
    virtual std::vector<Developer> getAllDevelopers() = 0;
    virtual bool deleteDeveloper(const std::string& name) = 0;

    // ==========================================
    // PLATFORMY
    // ==========================================
    virtual bool insertPlatform(const Platform& platform) = 0;
    virtual std::vector<Platform> getAllPlatforms() = 0;
    virtual bool deletePlatform(const std::string& name) = 0;

    // ==========================================
    // PREMIERY
    // ==========================================
    virtual bool insertPremiere(const GamePremier& premiere) = 0;
    
    // Zauważ, że w starym kodzie sortowałeś premiery po dacie.
    // Zrobimy to w implementacji Mongo!
    virtual std::vector<GamePremier> getAllPremieres() = 0;
};

#endif // ICATALOGREPOSITORY_HPP
#ifndef CATALOGCONTROLLER_HPP
#define CATALOGCONTROLLER_HPP

#include "httplib.h"
#include "CatalogService.hpp"
#include <nlohmann/json.hpp>
#include <iostream>

/**
 * @class CatalogController
 * @brief Kontroler HTTP zarządzający routingiem dla słowników (Developerzy, Platformy, Premiery).
 */
class CatalogController {
private:
    CatalogService& catalogService;

    // Pomocnicza metoda do "wyciągania" emaila z tokena
    std::string extractUserFromToken(const httplib::Request& req);

public:
    explicit CatalogController(CatalogService& service);

    // ==========================================
    // DEWELOPERZY
    // ==========================================
    
    // POST /api/developers
    void addDeveloper(const httplib::Request& req, httplib::Response& res);

    // GET /api/developers
    void getAllDevelopers(const httplib::Request& req, httplib::Response& res);

    // DELETE /api/developers/:name
    void deleteDeveloper(const httplib::Request& req, httplib::Response& res);

    // ==========================================
    // PLATFORMY
    // ==========================================

    // POST /api/platforms
    void addPlatform(const httplib::Request& req, httplib::Response& res);

    // GET /api/platforms
    void getAllPlatforms(const httplib::Request& req, httplib::Response& res);

    // DELETE /api/platforms/:name
    void deletePlatform(const httplib::Request& req, httplib::Response& res);

    // ==========================================
    // PREMIERY
    // ==========================================

    // POST /api/premiers
    void addPremiere(const httplib::Request& req, httplib::Response& res);

    // GET /api/premiers
    void getAllPremieres(const httplib::Request& req, httplib::Response& res);
};

#endif // CATALOGCONTROLLER_HPP
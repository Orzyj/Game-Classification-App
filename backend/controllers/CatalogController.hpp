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
    std::string extractUserFromToken(const httplib::Request& req) {
        if (req.has_header("Authorization")) {
            std::string token = req.get_header_value("Authorization");
            if (token.length() > 8) return token.substr(8);
        }
        return "unknown_admin";
    }

public:
    explicit CatalogController(CatalogService& service) : catalogService(service) {}

    // ==========================================
    // DEWELOPERZY
    // ==========================================
    
    // POST /api/developers
    void addDeveloper(const httplib::Request& req, httplib::Response& res) {
        try {
            auto j = nlohmann::json::parse(req.body);
            Developer dev = j.get<Developer>();
            std::string adminEmail = extractUserFromToken(req);

            catalogService.addDeveloper(dev, adminEmail);

            res.status = 201;
            res.set_content(R"({"status": "success", "message": "Deweloper dodany pomyślnie"})", "application/json");
        } catch (const std::invalid_argument& e) {
            res.status = 400;
            res.set_content(nlohmann::json{{"status", "error"}, {"message", e.what()}}.dump(), "application/json");
        } catch (const std::exception& e) {
            res.status = 500;
            res.set_content(nlohmann::json{{"status", "error"}, {"message", "Błąd serwera"}}.dump(), "application/json");
        }
    }

    // GET /api/developers
    void getAllDevelopers(const httplib::Request& req, httplib::Response& res) {
        try {
            auto devs = catalogService.getAllDevelopers();
            nlohmann::json dev_list = nlohmann::json::array();
            for (const auto& dev : devs) {
                dev_list.push_back(dev);
            }

            nlohmann::json response = {
                {"status", "ok"},
                {"count", dev_list.size()},
                {"developers", dev_list}
            };
            res.status = 200;
            res.set_content(response.dump(), "application/json");
        } catch (...) {
            res.status = 500;
            res.set_content(R"({"status": "error", "message": "Błąd serwera"})", "application/json");
        }
    }

    // DELETE /api/developers/:name
    void deleteDeveloper(const httplib::Request& req, httplib::Response& res) {
        try {
            std::string name = req.path_params.at("name");
            std::string adminEmail = extractUserFromToken(req);

            catalogService.deleteDeveloper(name, adminEmail);

            res.status = 200;
            res.set_content(R"({"status": "ok", "message": "Developer usunięty pomyślnie."})", "application/json");
        } catch (const std::invalid_argument& e) {
            res.status = 404;
            res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
        }
    }

    // ==========================================
    // PLATFORMY
    // ==========================================

    // POST /api/platforms
    void addPlatform(const httplib::Request& req, httplib::Response& res) {
        try {
            auto j = nlohmann::json::parse(req.body);
            Platform plat = j.get<Platform>();
            std::string adminEmail = extractUserFromToken(req);

            catalogService.addPlatform(plat, adminEmail);

            res.status = 201;
            res.set_content(R"({"status": "success", "message": "Platforma dodana pomyślnie"})", "application/json");
        } catch (const std::invalid_argument& e) {
            res.status = 400;
            res.set_content(nlohmann::json{{"status", "error"}, {"message", e.what()}}.dump(), "application/json");
        } catch (const std::exception& e) {
            res.status = 500;
            res.set_content(nlohmann::json{{"status", "error"}, {"message", "Błąd serwera"}}.dump(), "application/json");
        }
    }

    // GET /api/platforms
    void getAllPlatforms(const httplib::Request& req, httplib::Response& res) {
        try {
            auto plats = catalogService.getAllPlatforms();
            nlohmann::json plat_list = nlohmann::json::array();
            for (const auto& plat : plats) {
                plat_list.push_back(plat);
            }

            nlohmann::json response = {
                {"status", "ok"},
                {"count", plat_list.size()},
                {"platforms", plat_list}
            };
            res.status = 200;
            res.set_content(response.dump(), "application/json");
        } catch (...) {
            res.status = 500;
            res.set_content(R"({"status": "error", "message": "Błąd serwera"})", "application/json");
        }
    }

    // DELETE /api/platforms/:name
    void deletePlatform(const httplib::Request& req, httplib::Response& res) {
        try {
            std::string name = req.path_params.at("name");
            std::string adminEmail = extractUserFromToken(req);

            catalogService.deletePlatform(name, adminEmail);

            res.status = 200;
            res.set_content(R"({"status": "ok", "message": "Platforma usunięta pomyślnie."})", "application/json");
        } catch (const std::invalid_argument& e) {
            res.status = 404;
            res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
        }
    }

    // ==========================================
    // PREMIERY
    // ==========================================

    // POST /api/premiers
    void addPremiere(const httplib::Request& req, httplib::Response& res) {
        try {
            auto j = nlohmann::json::parse(req.body);
            GamePremier premiere = j.get<GamePremier>();
            std::string adminEmail = extractUserFromToken(req);

            catalogService.addPremiere(premiere, adminEmail);

            res.status = 201;
            res.set_content(R"({"status": "ok", "message": "Premiera dodana"})", "application/json");
        } catch (const std::exception& e) {
            res.status = 400;
            res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
        }
    }

    // GET /api/premiers
    void getAllPremieres(const httplib::Request& req, httplib::Response& res) {
        try {
            auto premieres = catalogService.getAllPremieres();
            nlohmann::json list = nlohmann::json::array();
            for (const auto& p : premieres) {
                list.push_back(p);
            }

            res.status = 200;
            res.set_content(nlohmann::json{{"status", "ok"}, {"premiers", list}}.dump(), "application/json");
        } catch (const std::exception& e) {
            res.status = 500;
            res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
        }
    }
};

#endif // CATALOGCONTROLLER_HPP
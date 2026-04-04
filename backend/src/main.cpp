#include <iostream>
#include <cstdlib>
#include <mutex>
#include "httplib.h"

// MongoDB
#include <mongocxx/instance.hpp>
#include <mongocxx/client.hpp>
#include <mongocxx/uri.hpp>

// Repozytoria (Warstwa dostępu do danych)
#include "MongoAuditRepository.hpp"
#include "MongoUserRepository.hpp"
#include "MongoGameRepository.hpp"
#include "MongoReportsRepository.hpp"
#include "MongoCatalogRepository.hpp"

// Serwisy (Warstwa logiki biznesowej)
#include "AuditService.hpp"
#include "UserService.hpp"
#include "GameService.hpp"
#include "ReportService.hpp"
#include "CatalogService.hpp"

// Kontrolery (Warstwa HTTP / Interfejs)
#include "AuditController.hpp"
#include "UserController.hpp"
#include "GameController.hpp"
#include "ReportController.hpp"
#include "CatalogController.hpp"

int main() {
    // 1. Inicjalizacja sterownika MongoDB
    mongocxx::instance inst{};
    const char* mongo_uri_env = std::getenv("MONGO_URI");
    std::string mongo_uri = mongo_uri_env ? mongo_uri_env : "mongodb://mongodb:27017";
    std::mutex mutex;
    
    mongocxx::client client{mongocxx::uri{mongo_uri}};
    auto db = client["game_db"];

    // ==========================================
    // 2. WSTRZYKIWANIE ZALEŻNOŚCI (DI)
    // ==========================================

    // Repozytoria
    MongoAuditRepository auditRepo(db);
    MongoUserRepository userRepo(db);
    MongoGameRepository gameRepo(db);
    MongoReportRepository reportRepo(db);
    MongoCatalogRepository catalogRepo(db);

    // Serwisy biznesowe
    AuditService auditService(auditRepo);
    UserService userService(auditRepo, userRepo); 
    GameService gameService(gameRepo, auditService);
    ReportService reportService(reportRepo, auditService);
    CatalogService catalogService(catalogRepo, auditService);

    // Kontrolery HTTP
    AuditController auditController(auditService);
    UserController userController(userService);
    GameController gameController(gameService);
    ReportController reportController(reportService);
    CatalogController catalogController(catalogService);

    // ==========================================
    // 3. KONFIGURACJA SERWERA HTTP
    // ==========================================
    
    httplib::Server svr;
    svr.set_mount_point("/uploads", "./uploads");

    //[DP] MIDDLEWARE AUTORYZACYJNY
    auto with_auth = [](auto handler) {
        return [handler](const httplib::Request& req, httplib::Response& res) {
            if (!req.has_header("Authorization")) {
                res.status = 401;
                res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
                return;
            }

            std::string token = req.get_header_value("Authorization");
            if (token.find("session_") != 0) {
                res.status = 401;
                res.set_content(R"({"error": "Nieprawidłowy token lub sesja wygasła."})", "application/json");
                return;
            }

            handler(req, res);
        };
    };

    // ==========================================
    // 4. MAPOWANIE ŚCIEŻEK (ROUTING)
    // ==========================================

    // --- ENDPOINTY PUBLICZNE (Brak logowania) ---
    svr.Get("/api/status", [&](const httplib::Request&, httplib::Response& res) {
        std::lock_guard<std::mutex> lock(mutex); 
        res.set_content(R"({"status": "ok", "message": "Server is running"})", "application/json");
    });
    svr.Post("/api/register", [&](const auto& req, auto& res) { userController.registerUser(req, res); });
    svr.Post("/api/login", [&](const auto& req, auto& res) { userController.loginUser(req, res); });

    // --- ENDPOINTY ZABEZPIECZONE WERYFIKACJĄ ---
    
    // Audyt
    svr.Get("/api/logs", with_auth([&](const auto& req, auto& res) {
        std::lock_guard<std::mutex> lock(mutex);  
        auditController.getLogs(req, res); 
    }));

    // Użytkownicy
    svr.Get("/api/users", with_auth([&](const auto& req, auto& res) { 
        std::lock_guard<std::mutex> lock(mutex); 
        userController.getAllUsers(req, res); 
    }));
    svr.Delete("/api/users/:email", with_auth([&](const auto& req, auto& res) { userController.deleteUser(req, res); }));
    svr.Patch("/api/users/:email/:flag", with_auth([&](const auto& req, auto& res) { userController.modUser(req, res); }));
    svr.Patch("/api/users/:email/status/:flag", with_auth([&](const auto& req, auto& res) { userController.changeUserAccountStatus(req, res); }));
    
    // Gry
    svr.Get("/api/games", with_auth([&](const auto& req, auto& res) {
        std::lock_guard<std::mutex> lock(mutex); 
        gameController.getGames(req, res); 
    }));
    svr.Post("/api/addgames", with_auth([&](const auto& req, auto& res) { gameController.addGame(req, res); }));
    svr.Delete("/api/games/:title", with_auth([&](const auto& req, auto& res) { gameController.deleteGame(req, res); }));
    svr.Put("/api/games/:title", with_auth([&](const auto& req, auto& res) { gameController.updateGame(req, res); }));
    svr.Post("/api/games/:title/rating", with_auth([&](const auto& req, auto& res) { gameController.rateGame(req, res); }));
    svr.Post("/api/games/:title/comments", with_auth([&](const auto& req, auto& res) { gameController.addComment(req, res); }));
    svr.Delete("/api/games/:title/comments/:index", with_auth([&](const auto& req, auto& res) { gameController.deleteComment(req, res); }));
    svr.Post("/api/games/:title/image", with_auth([&](const auto& req, auto& res) { gameController.uploadImage(req, res); }));
    svr.Patch("/api/games/:title/comments/:index", with_auth([&](const auto& req, auto& res) { gameController.updateComment(req, res); }));

    // Zgłoszenia (Reports)
    svr.Post("/api/reports", with_auth([&](const auto& req, auto& res) { reportController.submitReport(req, res); }));
    svr.Get("/api/reports", with_auth([&](const auto& req, auto& res) { 
        std::lock_guard<std::mutex> lock(mutex); 
        reportController.getAllReports(req, res); 
    }));

    svr.Delete(R"(/api/reports/([^/]+))", with_auth([&](const auto& req, auto& res) { reportController.closeReport(req, res); }));

    // Katalogi (Developerzy)
    svr.Post("/api/developers", with_auth([&](const auto& req, auto& res) { catalogController.addDeveloper(req, res); }));
    svr.Get("/api/developers", with_auth([&](const auto& req, auto& res) { 
        std::lock_guard<std::mutex> lock(mutex); 
        catalogController.getAllDevelopers(req, res); 
    }));
    svr.Delete("/api/developers/:name", with_auth([&](const auto& req, auto& res) { catalogController.deleteDeveloper(req, res); }));

    // Katalogi (Platformy)
    svr.Post("/api/platforms", with_auth([&](const auto& req, auto& res) { catalogController.addPlatform(req, res); }));
    svr.Get("/api/platforms", with_auth([&](const auto& req, auto& res) { 
        std::lock_guard<std::mutex> lock(mutex); 
        catalogController.getAllPlatforms(req, res); 
    }));
    svr.Delete("/api/platforms/:name", with_auth([&](const auto& req, auto& res) { catalogController.deletePlatform(req, res); }));

    // Katalogi (Premiery)
    svr.Post("/api/premiers", with_auth([&](const auto& req, auto& res) { catalogController.addPremiere(req, res); }));
    svr.Get("/api/premiers", with_auth([&](const auto& req, auto& res) { 
        std::lock_guard<std::mutex> lock(mutex); 
        catalogController.getAllPremieres(req, res); 
    }));


    // ==========================================
    // 5. URUCHOMIENIE SERWERA
    // ==========================================
    
    std::cout << "==========================================\n";
    std::cout << "Backend startuje na porcie 8080...\n";
    std::cout << "==========================================\n";
    
    svr.listen("0.0.0.0", 8080);

    return 0;
}
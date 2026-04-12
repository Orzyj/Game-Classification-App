#include "ReportController.hpp"

std::string ReportController::extractUserFromToken(const httplib::Request& req) {
    if (req.has_header("Authorization")) {
        std::string token = req.get_header_value("Authorization");
        if (token.length() > 8) return token.substr(8); // obcinamy "session_"
    }
    return "unknown_admin";
}

ReportController::ReportController(ReportService& service) 
    : reportService(service) {
        
}

void ReportController::submitReport(const httplib::Request& req, httplib::Response& res) {
    try {
        auto j = nlohmann::json::parse(req.body);
        std::string email = j.value("email_user", "");
        std::string message = j.value("message", "");

        reportService.submitReport(email, message);

        res.status = 201;
        res.set_content(R"({"status": "success", "message": "Zgłoszenie dodane"})", "application/json");

    } catch (const std::invalid_argument& e) {
        res.status = 400;
        res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) {
        res.status = 500;
        res.set_content(nlohmann::json{{"error", "Nie udało się zapisać zgłoszenia."}}.dump(), "application/json");
    }
}

/**
 * @brief GET /api/reports
 * Zwraca listę wszystkich zgłoszeń (np. dla panelu admina).
 */
void ReportController::getAllReports(const httplib::Request& req, httplib::Response& res) {
    try {
        auto reports = reportService.getAllReports();

        nlohmann::json response;
        response["status"] = "ok";
        response["count"] = reports.size();
        response["reports"] = reports;

        res.status = 200;
        res.set_content(response.dump(), "application/json");

    } catch (const std::exception& e) {
        std::cerr << "[ReportController] Błąd: " << e.what() << std::endl;
        nlohmann::json err_res;
        err_res["status"] = "error";
        err_res["message"] = "Błąd serwera/bazy danych przy odczycie zgłoszeń";
        res.status = 500;
        res.set_content(err_res.dump(), "application/json");
    }
}

/**
 * @brief DELETE /api/reports/:id
 * Usuwa zgłoszenie z bazy (zamyka ticket).
 */
void ReportController::closeReport(const httplib::Request& req, httplib::Response& res) {
    try {
        std::string report_id = req.matches[1]; 
        std::string adminEmail = extractUserFromToken(req);

        reportService.closeReport(report_id, adminEmail);
        res.status = 200;
        res.set_content(R"({"status": "ok", "message": "Zgłoszenie zostało zamknięte/usunięte"})", "application/json");

    } catch (const std::invalid_argument& e) {
        res.status = 404;
        res.set_content(nlohmann::json{{"status", "error", "message", e.what()}}.dump(), "application/json");
    } catch (const std::exception& e) {
        res.status = 500;
        nlohmann::json response = {
            {"status", "error"},
            {"message", "Błąd podczas usuwania zgłoszenia"},
            {"details", e.what()}
        };
        res.set_content(response.dump(), "application/json");
    }
}
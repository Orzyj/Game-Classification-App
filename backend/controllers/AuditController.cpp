#include "AuditController.hpp"

AuditController::AuditController(AuditService& service) 
    : auditService(service) {
        
}

void AuditController::getLogs(const httplib::Request& req, httplib::Response& res) {
    try {
        std::vector<AuditLog> logs_list = auditService.getLogs();

        nlohmann::json logs_json = nlohmann::json::array();
        for (const auto& log : logs_list) {
            logs_json.push_back(log); 
        }

        nlohmann::json response;
        response["status"] = "ok";
        response["count"] = logs_list.size();
        response["logs"] = logs_json;

        res.status = 200;
        res.set_content(response.dump(), "application/json");

    } catch (const std::exception& e) {
        std::cerr << "[AuditController] Błąd odczytu logów: " << e.what() << std::endl;
        nlohmann::json err_res;
        err_res["status"] = "error";
        err_res["message"] = "Błąd serwera przy odczycie logów";
        res.status = 500;
        res.set_content(err_res.dump(), "application/json");
    }
}
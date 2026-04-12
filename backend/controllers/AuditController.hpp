#ifndef AUDITCONTROLLER_HPP
#define AUDITCONTROLLER_HPP

#include "httplib.h"
#include "AuditService.hpp"
#include <nlohmann/json.hpp>
#include <iostream>

/**
 * @class AuditController
 * @brief Kontroler obsługujący żądania HTTP związane z logami audytowymi.
 */
class AuditController {
private:
    AuditService& auditService;

public:
    // Wstrzykujemy serwis logów
    explicit AuditController(AuditService& service);

    // Odpowiada za GET /api/logs
    void getLogs(const httplib::Request& req, httplib::Response& res);
    
};

#endif // AUDITCONTROLLER_HPP
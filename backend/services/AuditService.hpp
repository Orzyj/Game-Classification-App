#ifndef AUDITSERVICE_HPP
#define AUDITSERVICE_HPP

#include <string>
#include <chrono>
#include <iomanip>
#include <sstream>
#include "IAuditRepository.hpp"

class AuditService {
private:
    IAuditRepository& repository;

    std::string getCurrentTimestamp();

public:
    explicit AuditService(IAuditRepository& repo);

    /**
     * @brief Główna metoda logująca aktywność.
     */
    void logActivity(const std::string& email, const std::string& action, const std::string& details);

    /**
     * @brief Pobiera najnowsze logi (domyślnie 50).
     */
    std::vector<AuditLog> getLogs(int limit = 50);
};


#endif // AUDITSERVICE_HPP
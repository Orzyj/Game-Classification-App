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

    std::string getCurrentTimestamp() {
        auto now = std::chrono::system_clock::now();
        auto in_time_t = std::chrono::system_clock::to_time_t(now);
        std::stringstream ss;
        ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %H:%M:%S");
        return ss.str();
    }

public:
    explicit AuditService(IAuditRepository& repo) : repository(repo) {}

    /**
     * @brief Główna metoda logująca aktywność.
     */
    void logActivity(const std::string& email, const std::string& action, const std::string& details) {
        AuditLog newLog(getCurrentTimestamp(), email, action, details);
        repository.insertLog(newLog);
    }

    /**
     * @brief Pobiera najnowsze logi (domyślnie 50).
     */
    std::vector<AuditLog> getLogs(int limit = 50) {
        return repository.getRecentLogs(limit);
    }
};


#endif // AUDITSERVICE_HPP
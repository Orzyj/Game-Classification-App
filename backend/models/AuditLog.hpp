#ifndef AUDITLOG_HPP
#define AUDITLOG_HPP

#include <string>
#include <nlohmann/json.hpp>

/**
 * @brief Struktura reprezentująca pojedynczy wpis w logu audytowym.
 * Warstwa Domeny (Domain Model).
 */
struct AuditLog {
    std::string timestamp;
    std::string email;
    std::string action;
    std::string details;

    AuditLog() = default;

    AuditLog(std::string ts, std::string mail, std::string act, std::string det)
        : timestamp(std::move(ts)), email(std::move(mail)), action(std::move(act)), details(std::move(det)) {}

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(AuditLog, timestamp, email, action, details)
};

#endif // AUDITLOG_HPP
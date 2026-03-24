#ifndef AUDITLOG_HPP
#define AUDITLOG_HPP

#include <string>
#include <nlohmann/json.hpp>

struct AuditLog {
    std::string timestamp;
    std::string email;
    std::string action;
    std::string details;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(AuditLog, timestamp, email, action, details)
};

#endif // AUDITLOG_HPP
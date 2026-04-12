#include "AuditService.hpp"

std::string AuditService::getCurrentTimestamp() {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);
    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %H:%M:%S");
    return ss.str();
}

AuditService::AuditService(IAuditRepository& repo) 
: repository(repo) {

}

void AuditService::logActivity(const std::string& email, const std::string& action, const std::string& details) {
    AuditLog newLog(getCurrentTimestamp(), email, action, details);
    repository.insertLog(newLog);
}


std::vector<AuditLog> AuditService::getLogs(int limit) {
    return repository.getRecentLogs(limit);
}
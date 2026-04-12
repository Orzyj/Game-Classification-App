#include "ReportService.hpp"

std::string ReportService::getCurrentTimestamp() const {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);
    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %H:%M:%S");
    return ss.str();
}

ReportService::ReportService(IReportRepository& reportRepo, AuditService& audit) 
    : reportRepository(reportRepo), auditService(audit) {}

void ReportService::submitReport(const std::string& email, const std::string& message) {
    if (message.empty() || message == "Brak wiadomości") {
        throw std::invalid_argument("Treść zgłoszenia nie może być pusta.");
    }

    Ticket newTicket;
    newTicket.email_user = email.empty() ? "Nieznany" : email;
    newTicket.message = message;
    newTicket.timestamp = getCurrentTimestamp();

    bool success = reportRepository.insertReport(newTicket);
    if (!success) {
        throw std::runtime_error("Nie udało się zapisać zgłoszenia do bazy.");
    }

    auditService.logActivity(newTicket.email_user, "REPORT_SUBMITTED", "Użytkownik wysłał zgłoszenie");
}

std::vector<nlohmann::json> ReportService::getAllReports() {
    return reportRepository.getAllReports();
}

void ReportService::closeReport(const std::string& reportId, const std::string& adminEmail) {
    bool success = reportRepository.deleteReport(reportId);
    
    if (!success) {
        throw std::invalid_argument("Zgłoszenie nie zostało znalezione lub zostało już zamknięte.");
    }

    auditService.logActivity(adminEmail, "REPORT_CLOSED", "Zamknięto ticket: " + reportId);
}
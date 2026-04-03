#ifndef REPORTSERVICE_HPP
#define REPORTSERVICE_HPP

#include "IReportRepository.hpp"
#include "AuditService.hpp"
#include <stdexcept>
#include <chrono>
#include <iomanip>
#include <sstream>

/**
 * @class ReportService
 * @brief Usługa logiki biznesowej do zarządzania zgłoszeniami (Ticketami).
 * Izoluje kontroler od szczegółów bazy danych oraz dba o zapisy w audycie.
 */
class ReportService {
private:
    IReportRepository& reportRepository;
    AuditService& auditService;

    /**
     * @brief Generuje aktualny znacznik czasu dla zgłoszenia.
     * @return std::string Aktualna data i czas.
     */
    std::string getCurrentTimestamp() const {
        auto now = std::chrono::system_clock::now();
        auto in_time_t = std::chrono::system_clock::to_time_t(now);
        std::stringstream ss;
        ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %H:%M:%S");
        return ss.str();
    }

public:
    /**
     * @brief Konstruktor wstrzykujący zależności (DI).
     * @param reportRepo Repozytorium zgłoszeń.
     * @param audit Serwis audytów do logowania akcji systemowych.
     */
    explicit ReportService(IReportRepository& reportRepo, AuditService& audit) 
        : reportRepository(reportRepo), auditService(audit) {}

    /**
     * @brief Tworzy nowe zgłoszenie i zapisuje je w systemie.
     * @param email Adres email użytkownika zgłaszającego problem.
     * @param message Treść zgłoszenia.
     * @throws std::invalid_argument Jeśli wiadomość jest pusta.
     * @throws std::runtime_error Jeśli baza danych odrzuci zapis.
     */
    void submitReport(const std::string& email, const std::string& message) {
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

    /**
     * @brief Pobiera listę wszystkich zgłoszeń z bazy.
     * @return std::vector<Ticket> Wektor obiektów zgłoszeń.
     */
    std::vector<nlohmann::json> getAllReports() {
        return reportRepository.getAllReports();
    }

    /**
     * @brief Usuwa (zamyka) zgłoszenie na podstawie jego ID.
     * @param reportId Unikalny identyfikator zgłoszenia (MongoDB ObjectId).
     * @param adminEmail Email administratora zamykającego zgłoszenie (do logów).
     * @throws std::invalid_argument Jeśli zgłoszenie nie istnieje w bazie.
     */
    void closeReport(const std::string& reportId, const std::string& adminEmail) {
        bool success = reportRepository.deleteReport(reportId);
        
        if (!success) {
            throw std::invalid_argument("Zgłoszenie nie zostało znalezione lub zostało już zamknięte.");
        }

        auditService.logActivity(adminEmail, "REPORT_CLOSED", "Zamknięto ticket: " + reportId);
    }
};

#endif // REPORTSERVICE_HPP
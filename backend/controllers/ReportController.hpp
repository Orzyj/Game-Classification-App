#ifndef REPORTCONTROLLER_HPP
#define REPORTCONTROLLER_HPP

#include "httplib.h"
#include "ReportService.hpp"
#include <nlohmann/json.hpp>
#include <iostream>

/**
 * @class ReportController
 * @brief Kontroler HTTP obsługujący routing dla modułu zgłoszeń (Tickets/Reports).
 */
class ReportController {
private:
    ReportService& reportService;

    std::string extractUserFromToken(const httplib::Request& req);

public:
    /**
     * @brief Konstruktor wstrzykujący usługę zgłoszeń (DI).
     * @param service Referencja do obiektu ReportService.
     */
    explicit ReportController(ReportService& service);

    /**
     * @brief POST /api/reports
     * Odbiera żądanie utworzenia nowego zgłoszenia.
     */
    void submitReport(const httplib::Request& req, httplib::Response& res);

    /**
     * @brief GET /api/reports
     * Zwraca listę wszystkich zgłoszeń (np. dla panelu admina).
     */
    void getAllReports(const httplib::Request& req, httplib::Response& res);

    /**
     * @brief DELETE /api/reports/:id
     * Usuwa zgłoszenie z bazy (zamyka ticket).
     */
    void closeReport(const httplib::Request& req, httplib::Response& res);
};

#endif // REPORTCONTROLLER_HPP
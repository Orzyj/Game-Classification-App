#ifndef IREPORTREPOSITORY_HPP
#define IREPORTREPOSITORY_HPP

#include <string>
#include <vector>
#include <nlohmann/json.hpp>
#include "Ticket.hpp"

/**
 * @class IReportRepository
 * @brief Interfejs repozytorium dla modułu zgłoszeń (Ticket/Report).
 */
class IReportRepository {
public:
    virtual ~IReportRepository() = default;

    /**
     * @brief Dodaje nowe zgłoszenie do bazy danych.
     * @param ticket Obiekt zgłoszenia do zapisu.
     * @return zwraca prawde lub fałsz wykonania zapytania
     */
    virtual bool insertReport(const Ticket& ticket) = 0;

    /**
     * @brief Pobiera listę wszystkich zgłoszeń.
     * @return std::vector<Ticket> Wektor obiektów reprezentujących zgłoszenia.
     */
    virtual std::vector<nlohmann::json> getAllReports() = 0;

    /**
     * @brief Usuwa zgłoszenie z bazy danych na podstawie jego unikalnego ID (OID).
     * @param report_id Ciąg znaków reprezentujący ObjectID z MongoDB.
     * @return true, jeśli usunięto pomyślnie, w przeciwnym razie false.
     */
    virtual bool deleteReport(const std::string& report_id) = 0;
};

#endif // IREPORTREPOSITORY_HPP
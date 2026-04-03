#ifndef IAUDITREPOSITORY_HPP
#define IAUDITREPOSITORY_HPP

#include <vector>
#include "AuditLog.hpp"

/**
 * @brief Interfejs dla repozytorium logów.
 * Warstwa Domeny / Aplikacji.
 */
class IAuditRepository {
public:
    virtual ~IAuditRepository() = default;

    /**
     * @brief Zapisuje nowy log w bazie danych.
     */
    virtual void insertLog(const AuditLog& log) = 0;

    /**
     * @brief Pobiera najnowsze logi z bazy.
     * @param limit Maksymalna liczba logów do pobrania.
     */
    virtual std::vector<AuditLog> getRecentLogs(int limit) = 0;
};

#endif // IAUDITREPOSITORY_HPP
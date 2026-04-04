#ifndef USERSERVICE_HPP
#define USERSERVICE_HPP

#include "IAuditRepository.hpp"
#include "IUserRepository.hpp"
#include <stdexcept>
#include <chrono>
#include <iomanip>
#include <sstream>

/**
 * @class UserService
 * @brief Usługa aplikacji (Application Service) zarządzająca logiką biznesową użytkowników.
 * * Klasa ta koordynuje operacje na koncie użytkownika (rejestracja, logowanie) 
 * oraz dba o automatyczne zapisywanie tych akcji w logach audytowych.
 * Działa niezależnie od warstwy sieciowej (HTTP) i infrastruktury bazy danych.
 */
class UserService {
private:
    IAuditRepository& auditRepository;
    IUserRepository& userRepository;

    /**
     * @brief Generuje aktualny znacznik czasu w czytelnym formacie.
     * @return std::string Aktualna data i czas (np. "2024-05-18 14:30:00").
     */
    std::string getCurrentTimestamp() const {
        auto now = std::chrono::system_clock::now();
        auto in_time_t = std::chrono::system_clock::to_time_t(now);
        std::stringstream ss;
        ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");
        return ss.str();
    }

public:
    /**
     * @brief Konstruktor usługi wstrzykujący wymagane repozytoria (Dependency Injection).
     * @param auditRepo Referencja do repozytorium logów audytowych.
     * @param userRepo Referencja do repozytorium użytkowników.
     */
    explicit UserService(IAuditRepository& auditRepo, IUserRepository& userRepo) 
        : auditRepository(auditRepo), userRepository(userRepo) {}

    /**
     * @brief Rejestruje nowego użytkownika w systemie.
     * * Sprawdza, czy podany adres email jest już zajęty. Jeśli nie, zapisuje 
     * użytkownika do bazy i generuje odpowiedni wpis w logach audytowych.
     * * @param user Obiekt encji User zawierający dane rejestracyjne.
     * @throws std::invalid_argument Jeśli użytkownik o podanym adresie email już istnieje.
     */
    void registerUser(const User& user) {
        if (userRepository.userExists(user.email)) {
            throw std::invalid_argument("Użytkownik o podanym adresie email już istnieje!");
        }

        userRepository.insertUser(user);

        const std::string DETAILS = "Utworzenie użytkownika: " + user.email;
        AuditLog newLog(getCurrentTimestamp(), user.email, "USER_REGISTER", DETAILS);
        auditRepository.insertLog(newLog);
    }

    /**
     * @brief Weryfikuje dane logowania użytkownika.
     * * Metoda sprawdza poprawność logowania i ZAWSZE generuje wpis w logach 
     * audytowych (niezależnie od tego, czy logowanie zakończyło się sukcesem, czy błędem).
     * * @param email Adres email użytkownika.
     * @param password Hasło użytkownika.
     * @return true, jeśli dane logowania są poprawne, false w przeciwnym razie.
     */
    bool loginUser(const std::string& email, const std::string& password) {
        bool isValid = userRepository.validateCredentials(email, password);
        std::string action = isValid ? "USER_LOGIN" : "FAILED_LOGIN";
        std::string details = isValid ? "Pomyślne logowanie użytkownika" : "Próba logowania z błędnym hasłem";

        AuditLog newLog(getCurrentTimestamp(), email, action, details);
        auditRepository.insertLog(newLog);

        return isValid;
    }

    /**
     * @brief Pobiera listę wszystkich użytkowników w systemie.
     * @return std::vector<User> Wektor zawierający dane użytkowników.
     */
    std::vector<User> getAllUsers() {
        return userRepository.getAllUsers();
    }

    /**
     * @brief Usuwa konto użytkownika.
     * * Jeśli usunięcie przebiegnie pomyślnie, akcja ta zostaje odnotowana w logach audytowych.
     * * @param email Adres email konta przeznaczonego do usunięcia.
     * @return true, jeśli konto zostało pomyślnie usunięte, false jeśli go nie znaleziono.
     */
    bool deleteUser(const std::string& email) {
        bool isDeleted = userRepository.deleteUser(email);
        if (isDeleted) {
            AuditLog newLog(getCurrentTimestamp(), email, "USER_DELETED", "Usunięto konto użytkownika");
            auditRepository.insertLog(newLog);
        }

        return isDeleted;
    }

    /**
     * @brief Zmienia uprawnienia moderatora/administratora dla danego konta.
     * @param email Adres email konta.
     * @param flag true, aby nadać uprawnienia, false, aby je odebrać.
     * @return true, jeśli konto zostało pomyślnie zmodyfikowane, false jeśli wystąpił błąd.
     */
    bool modUser(const std::string& email, const bool& flag) {
        bool isModed = userRepository.modUser(email, flag);

        if(isModed) {
            std::string logMessage = flag ? "Nadano uprawnienia moderatora" : "Odebrano uprawnienia moderatora";
            AuditLog newLog(getCurrentTimestamp(), email, "MOD_USER", logMessage);
            auditRepository.insertLog(newLog);
        }

        return isModed;
    }

    /**
     * @brief Zmienia status aktywności konta użytkownika (aktywacja/dezaktywacja).
     * * Funkcja modyfikuje status konta na podstawie przekazanej flagi. 
     * Po pomyślnej zmianie w bazie danych, operacja jest automatycznie 
     * zapisywana w logach audytowych (AuditLog).
     * * @param email Adres email użytkownika, którego konto ma zostać zmodyfikowane.
     * @param flag Wartość logiczna: true, aby aktywować (odblokować) konto, false, aby je dezaktywować (zablokować).
     * @return true, jeśli status został pomyślnie zmieniony, false jeśli wystąpił błąd (np. brak użytkownika w bazie).
     */
    bool changeUserAccountStatus(const std::string& email, const bool& flag) {
        bool isChanged = userRepository.chagneUserAccountStatus(email, flag);

        if(isChanged) {
            std::string logMessage = flag ? "Aktywowano użytkownika" : "Dezaktywowano";
            AuditLog newLog(getCurrentTimestamp(), email, "ACCOUNT_STATUS_USER", logMessage);
            auditRepository.insertLog(newLog);
        }

        return isChanged;
    }

    /**
     * @brief Sprawdza, czy użytkownik o podanym adresie email posiada uprawnienia moderatora.
     * @param email Adres email użytkownika do sprawdzenia.
     * @return true, jeśli użytkownik ma uprawnienia moderatora, false w przeciwnym razie (lub gdy użytkownik nie istnieje).
     */
    bool isUserMod(const std::string& email) {
        return userRepository.isUserMod(email);
    }

    /**
     * @brief Sprawdza, czy konto użytkownika o podanym adresie email jest aktywne.
     * @param email Adres email użytkownika do sprawdzenia.
     * @return true, jeśli konto jest aktywne (niezablokowane), false jeśli jest zablokowane (lub gdy użytkownik nie istnieje).
     */
    bool isUserEnable(const std::string& email) {
        return userRepository.isUserEnable(email);
    }
};

#endif // USERSERVICE_HPP
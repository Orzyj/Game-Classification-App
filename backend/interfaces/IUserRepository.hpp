#ifndef IUSERREPOSITORY_HPP
#define IUSERREPOSITORY_HPP

#include <vector>
#include <string>
#include "User.hpp"

/**
 * @class IUserRepository
 * @brief Interfejs repozytorium dla encji User.
 *
 * Zgodnie z zasadami Clean Architecture, abstrahuje on operacje utrwalania 
 * danych użytkowników od logiki biznesowej. Pozwala to na łatwą wymianę 
 * bazy danych (np. MongoDB na bazę w pamięci do testów) bez zmiany kodu serwisów.
 */
class IUserRepository {
public:
    virtual ~IUserRepository() = default;

    /**
     * @brief Sprawdza, czy użytkownik o podanym adresie email istnieje w bazie.
     * @param email Adres email do weryfikacji.
     * @return true, jeśli użytkownik istnieje, w przeciwnym razie false.
     */
    virtual bool userExists(const std::string& email) = 0;

    /**
     * @brief Dodaje nowego użytkownika do bazy danych.
     * @param user Obiekt encji User zawierający dane do zapisu.
     */
    virtual void insertUser(const User& user) = 0;

    /**
     * @brief Weryfikuje poprawność danych logowania.
     * @param email Adres email podany podczas logowania.
     * @param password Hasło podane podczas logowania.
     * @return true, jeśli email i hasło pasują do rekordu w bazie, w przeciwnym razie false.
     */
    virtual bool validateCredentials(const std::string& email, const std::string& password) = 0;

    /**
     * @brief Pobiera listę wszystkich zarejestrowanych użytkowników.
     * @return std::vector<User> Wektor zawierający obiekty wszystkich użytkowników.
     */
    virtual std::vector<User> getAllUsers() = 0;

    /**
     * @brief Usuwa użytkownika na podstawie jego adresu email.
     * @param email Adres email użytkownika przeznaczonego do usunięcia.
     * @return true, jeśli użytkownik został pomyślnie usunięty, false jeśli go nie znaleziono.
     */
    virtual bool deleteUser(const std::string& email) = 0;

    /**
     * @brief Nadaje/Odbiera uprawnienia moda użytkownikowi 
     * @param email Adres użytkownika 
     * @param bool Nadanie/Odebranie uprawnienia
     * @return true jeśli wszystko pójdzie dobrze, false jeśli coś pójdzie nie tak
     */
    virtual bool modUser(const std::string& email, const bool& flag) = 0;

    /**
     * @brief Dezaktwuje/Aktywuje konto użytkownika
     * @param email Adres użytkownika
     * @param bool Aktywacja/Dezaktywacja użytkownika
     * @return true jeśli wszystko pójdzie dobrze, false jesli coś pójdzie nie tak
     */
    virtual bool chagneUserAccountStatus(const std::string& email, const bool& flag) = 0;

    /**
     * @brief Sprawdza czy użytkownik ma moda
     * @param email Adres użytkownika
     * @return true jeśli jeśli jest mod, false jeśli nie jest
     */
    virtual bool isUserMod(const std::string& email) = 0;
    
    /**
     * @brief Sprawdza czy konto użytkownika jest wyłaczone
     * @param email Adres użytkownika
     * @return true jeśli jeśli jest , false jeśli nie jest
     */
    virtual bool isUserEnable(const std::string& email) = 0;
};

#endif // IUSERREPOSITORY_HPP
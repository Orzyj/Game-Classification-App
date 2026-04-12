#include "UserService.hpp"

std::string UserService::getCurrentTimestamp() const {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);
    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");
    return ss.str();
}


UserService::UserService(IAuditRepository& auditRepo, IUserRepository& userRepo) 
    : auditRepository(auditRepo), userRepository(userRepo) {}


void UserService::registerUser(const User& user) {
    if (userRepository.userExists(user.email)) {
        throw std::invalid_argument("Użytkownik o podanym adresie email już istnieje!");
    }

    userRepository.insertUser(user);

    const std::string DETAILS = "Utworzenie użytkownika: " + user.email;
    AuditLog newLog(getCurrentTimestamp(), user.email, "USER_REGISTER", DETAILS);
    auditRepository.insertLog(newLog);
}

bool UserService::loginUser(const std::string& email, const std::string& password) {
    bool isValid = userRepository.validateCredentials(email, password);
    std::string action = isValid ? "USER_LOGIN" : "FAILED_LOGIN";
    std::string details = isValid ? "Pomyślne logowanie użytkownika" : "Próba logowania z błędnym hasłem";

    AuditLog newLog(getCurrentTimestamp(), email, action, details);
    auditRepository.insertLog(newLog);

    return isValid;
}

std::vector<User> UserService::getAllUsers() {
    return userRepository.getAllUsers();
}

bool UserService::deleteUser(const std::string& email) {
    bool isDeleted = userRepository.deleteUser(email);
    if (isDeleted) {
        AuditLog newLog(getCurrentTimestamp(), email, "USER_DELETED", "Usunięto konto użytkownika");
        auditRepository.insertLog(newLog);
    }

    return isDeleted;
}


bool UserService::modUser(const std::string& email, const bool& flag) {
    bool isModed = userRepository.modUser(email, flag);

    if(isModed) {
        std::string logMessage = flag ? "Nadano uprawnienia moderatora" : "Odebrano uprawnienia moderatora";
        AuditLog newLog(getCurrentTimestamp(), email, "MOD_USER", logMessage);
        auditRepository.insertLog(newLog);
    }

    return isModed;
}

bool UserService::changeUserAccountStatus(const std::string& email, const bool& flag) {
    bool isChanged = userRepository.chagneUserAccountStatus(email, flag);

    if(isChanged) {
        std::string logMessage = flag ? "Aktywowano użytkownika" : "Dezaktywowano";
        AuditLog newLog(getCurrentTimestamp(), email, "ACCOUNT_STATUS_USER", logMessage);
        auditRepository.insertLog(newLog);
    }

    return isChanged;
}

bool UserService::isUserMod(const std::string& email) {
    return userRepository.isUserMod(email);
}

bool UserService::isUserEnable(const std::string& email) {
    return userRepository.isUserEnable(email);
}
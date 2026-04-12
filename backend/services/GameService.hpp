#ifndef GAMESERVICE_HPP
#define GAMESERVICE_HPP

#include "IGameRepository.hpp"
#include "AuditService.hpp"
#include <stdexcept>
#include <chrono>
#include <iomanip>
#include <sstream>

class GameService {
private:
    IGameRepository& gameRepository;
    AuditService& auditService;

    std::string getCurrentTimestamp() const;

public:
    explicit GameService(IGameRepository& gameRepo, AuditService& audit);
    void addGame(const Game& game, const std::string& userEmail);

    void deleteGame(const std::string& title, const std::string& userEmail);
    void updateGame(const std::string& title, const std::string& dev, int year, const std::string& genre, const std::string& userEmail);
    std::vector<nlohmann::json> getGames(int limit, const std::map<std::string, std::string>& filters);

    void rateGame(const std::string& title, const std::string& email, const std::string& vote);

    void addComment(const std::string& title, const std::string& author, const std::string& content);

    void deleteComment(const std::string& title, const std::string& indexStr, const std::string& userEmail);

    void updateComment(
        const std::string& title, 
        const std::string& commentIndex, 
        const std::string& author,
        const std::string& newContent);

    void setGameImage(const std::string& title, const std::string& imageUrl, const std::string& userEmail);
};

#endif // GAMESERVICE_HPP
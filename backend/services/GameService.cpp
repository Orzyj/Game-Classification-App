#include "GameService.hpp"

std::string GameService::getCurrentTimestamp() const {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);
    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");
    return ss.str();
}

GameService::GameService(IGameRepository& gameRepo, AuditService& audit) 
    : gameRepository(gameRepo), auditService(audit) {}

void GameService::addGame(const Game& game, const std::string& userEmail) {
    if (gameRepository.gameExists(game.title, game.release_year, game.developer)) throw std::invalid_argument("Gra o tym tytule już istnieje.");
    gameRepository.insertGame(game);
    auditService.logActivity(userEmail, "GAME_ADDED", "Dodano nową grę: " + game.title);
}

void GameService::deleteGame(const std::string& title, const std::string& userEmail) {
    if (!gameRepository.deleteGame(title)) throw std::invalid_argument("Nie znaleziono gry do usunięcia.");
    auditService.logActivity(userEmail, "GAME_DELETED", "Usunięto grę: " + title);
}

void GameService::updateGame(const std::string& title, const std::string& dev, int year, const std::string& genre, const std::string& userEmail) {
    if (!gameRepository.updateGame(title, dev, year, genre)) throw std::invalid_argument("Nie znaleziono gry do edycji.");
    auditService.logActivity(userEmail, "GAME_UPDATED", "Zaktualizowano dane gry: " + title);
}

std::vector<nlohmann::json> GameService::getGames(int limit, const std::map<std::string, std::string>& filters) {
    if (limit > 100) limit = 100;
    if (limit <= 0) limit = 20;
    return gameRepository.getGames(limit, filters);
}

void GameService::rateGame(const std::string& title, const std::string& email, const std::string& vote) {
    if (vote != "up" && vote != "down") throw std::invalid_argument("Wymagane 'up' lub 'down'.");
    bool isUpvote = (vote == "up");
    int result = gameRepository.addRating(title, email, isUpvote);
    if (result == 1) throw std::invalid_argument("Nie znaleziono takiej gry.");
    if (result == 2) throw std::logic_error("Już oddałeś głos na tę grę!"); 
}

void GameService::addComment(const std::string& title, const std::string& author, const std::string& content) {
    if (content.empty()) throw std::invalid_argument("Komentarz nie może być pusty.");
    nlohmann::json full_comment;
    full_comment["author_name"] = author;
    full_comment["content"] = content;
    full_comment["date"] = getCurrentTimestamp();

    if (!gameRepository.addComment(title, full_comment)) throw std::invalid_argument("Nie znaleziono gry.");
    auditService.logActivity(author, "COMMENT_ADDED", "Dodano komentarz do gry: " + title);
}

void GameService::deleteComment(const std::string& title, const std::string& indexStr, const std::string& userEmail) {
    if (!gameRepository.deleteComment(title, indexStr)) throw std::invalid_argument("Nie znaleziono gry lub komentarza.");
    auditService.logActivity(userEmail, "COMMENT_DELETED", "Usunięto komentarz z gry: " + title);
}

void GameService::updateComment(
    const std::string& title, 
    const std::string& commentIndex, 
    const std::string& author,
    const std::string& newContent) {
        if(!gameRepository.updateComment(title, commentIndex, author, newContent)) {
            auditService.logActivity(author, "COMMENT_DELETED", "Bład podczas Update komentarza: ");
            throw std::invalid_argument("Nie znaleziono komentarza");
        }
        auditService.logActivity(author, "COMMENT_DELETED", "Pomyślny Update komentarza: ");
}

void GameService::setGameImage(const std::string& title, const std::string& imageUrl, const std::string& userEmail) {
    if (!gameRepository.updateGameImage(title, imageUrl)) throw std::invalid_argument("Nie znaleziono gry.");
    auditService.logActivity(userEmail, "IMAGE_UPLOADED", "Dodano okładkę dla gry: " + title);
}
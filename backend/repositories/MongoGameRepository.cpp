#include "MongoGameRepository.hpp"

MongoGameRepository::MongoGameRepository(mongocxx::database database) 
    : db(std::move(database)) {
        
}

void MongoGameRepository::insertGame(const Game& game) {
    try {
        auto collection = db["games"];
        nlohmann::json j = game;
        auto doc = bsoncxx::from_json(j.dump());
        collection.insert_one(doc.view());
    } catch (const std::exception& e) {
        std::cerr << "[MongoGameRepository] Błąd dodawania gry: " << e.what() << std::endl;
    }
}

bool MongoGameRepository::deleteGame(const std::string& title) {
    try {
        auto collection = db["games"];
        auto filter = make_document(kvp("title", title));
        auto result = collection.delete_one(filter.view());
        return (result && result->deleted_count() > 0);
    } catch (const std::exception& e) {
        return false;
    }
}

bool MongoGameRepository::updateGame(const std::string& title, const std::string& dev, int year, const std::string& genre) {
    try {
        auto collection = db["games"];
        auto filter = make_document(kvp("title", title));
        auto update = make_document(
            kvp("$set", make_document(
                kvp("developer", dev),
                kvp("release_year", year),
                kvp("classification.genre", genre)
            ))
        );
        auto result = collection.update_one(filter.view(), update.view());
        return (result && result->matched_count() > 0);
    } catch (const std::exception& e) {
        return false;
    }
}

std::vector<nlohmann::json> MongoGameRepository::getGames(int limit, const std::map<std::string, std::string>& filters) {
    std::vector<nlohmann::json> games;
    try {
        auto collection = db["games"];
        mongocxx::options::find opts{};
        opts.limit(limit);
        bsoncxx::builder::basic::document filter_builder{};

        for (const auto& [parent_key, child_keys] : FILTER_KEYS) {
            for (const auto& child_key : child_keys) {
                
                auto it = filters.find(child_key);
                if (it != filters.end()) {
                    std::string value = it->second;
                    std::string db_field = (parent_key == child_key) ? child_key : (parent_key + "." + child_key);

                    if (child_key == "release_year" || child_key == "average_playtime_hours") {
                        try {
                            filter_builder.append(kvp(db_field, std::stoi(value)));
                        } catch (...) { }
                    } else {
                        filter_builder.append(kvp(db_field, value));
                    }
                }
            }
        }

        auto cursor = collection.find(filter_builder.extract().view(), opts);

        for (auto&& doc : cursor) {
            games.push_back(nlohmann::json::parse(bsoncxx::to_json(doc))); 
        }
    } catch (const std::exception& e) {
        std::cerr << "[MongoGameRepository] Błąd pobierania gier: " << e.what() << std::endl;
    }
    return games;
}

bool MongoGameRepository::gameExists(const std::string& title, const int& year, const std::string& dev) {
    try {
        auto collection = db["games"];
        auto count = collection.count_documents(
            make_document(
                kvp("title", title),
                kvp("developer", dev),
                kvp("release_year", year)
            )
        );
        return count > 0;
    } catch (...) {
        return false;
    }
}

int MongoGameRepository::addRating(const std::string& title, const std::string& email, bool isUpvote) {
    try {
        auto collection = db["games"];
        auto filter = make_document(
            kvp("title", title),
            kvp("rated_emails", make_document(kvp("$ne", email)))
        );
        std::string field_to_inc = isUpvote ? "rating_up" : "rating_down";
        auto update = make_document(
            kvp("$inc", make_document(kvp(field_to_inc, 1))),
            kvp("$push", make_document(kvp("rated_emails", email)))
        );
        auto result = collection.update_one(filter.view(), update.view());

        if (result && result->modified_count() > 0) return 0;
        //if (gameExists(title)) return 2; 
        return 1; 
    } catch (...) { return -1; }
}

bool MongoGameRepository::addComment(const std::string& title, const nlohmann::json& commentJson) {
    try {
        auto collection = db["games"];
        auto result = collection.update_one(
            make_document(kvp("title", title)),
            make_document(kvp("$push", make_document(kvp("comments", bsoncxx::from_json(commentJson.dump())))))
        );
        return (result && result->modified_count() > 0);
    } catch (...) { return false; }
}

bool MongoGameRepository::deleteComment(const std::string& title, const std::string& commentIndex) {
    try {
        auto collection = db["games"];
        auto filter = make_document(kvp("title", title));
        std::string array_path = "comments." + commentIndex;
    
        auto unset_update = make_document(kvp("$unset", make_document(kvp(array_path, 1))));
        collection.update_one(filter.view(), unset_update.view());

        auto pull_update = make_document(
            kvp("$pull", make_document(kvp("comments", bsoncxx::types::b_null{})))
        );
        auto pull_result = collection.update_one(filter.view(), pull_update.view());

        return (pull_result && pull_result->modified_count() > 0);
    } catch (...) { return false; }
}

bool MongoGameRepository::updateGameImage(const std::string& title, const std::string& imageUrl) {
    try {
        auto collection = db["games"];
        auto filter = make_document(kvp("title", title));
        auto update = make_document(kvp("$set", make_document(kvp("image_url", imageUrl))));

        auto result = collection.update_one(filter.view(), update.view());
        return (result && result->matched_count() > 0);
    } catch (...) { return false; }
}

bool MongoGameRepository::updateComment(
    const std::string& title, 
    const std::string& commentIndex, 
    const std::string& author,
    const std::string& newContent) {
    try {
        auto collection = db["games"];
        std::string contentPath = "comments." + commentIndex + ".content";
        std::string authorPath = "comments." + commentIndex + ".author_name";

        auto filter = make_document(
            kvp("title", title),
            kvp(authorPath, author) 
        );
        
        auto update = make_document(
            kvp("$set", make_document(
                kvp(contentPath, newContent)
            ))
        );
        
        auto result = collection.update_one(filter.view(), update.view());
        return (result && result->modified_count() > 0);

    } catch (...) { return false; }
}
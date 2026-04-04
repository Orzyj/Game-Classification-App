#ifndef MONGOGAMEREPOSITORY_HPP
#define MONGOGAMEREPOSITORY_HPP

#include "IGameRepository.hpp"
#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/types.hpp>
#include <bsoncxx/json.hpp> // Wymagane!
#include <iostream>
using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

class MongoGameRepository : public IGameRepository {
private:
    const std::map<std::string, std::vector<std::string>> FILTER_KEYS {
        {"classification",{"genre", "subgenre","theme", "difficulty"}},
        {"technical_stats",{"engine", "average_playtime_hours","theme"}},
        {"title",{"title"}},
        {"developer", {"developer"}},
        {"release_year",{"release_year"}}
    };

    mongocxx::database db;

public:
    explicit MongoGameRepository(mongocxx::database database) : db(std::move(database)) {}

    void insertGame(const Game& game) override {
        try {
            auto collection = db["games"];
            nlohmann::json j = game;
            auto doc = bsoncxx::from_json(j.dump());
            collection.insert_one(doc.view());
        } catch (const std::exception& e) {
            std::cerr << "[MongoGameRepository] Błąd dodawania gry: " << e.what() << std::endl;
        }
    }

    bool deleteGame(const std::string& title) override {
        try {
            auto collection = db["games"];
            auto filter = make_document(kvp("title", title));
            auto result = collection.delete_one(filter.view());
            return (result && result->deleted_count() > 0);
        } catch (const std::exception& e) {
            return false;
        }
    }

    bool updateGame(const std::string& title, const std::string& dev, int year, const std::string& genre) override {
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

    std::vector<nlohmann::json> getGames(int limit, const std::map<std::string, std::string>& filters) override {
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

    bool gameExists(const std::string& title, const int& year, const std::string& dev) override {
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

    int addRating(const std::string& title, const std::string& email, bool isUpvote) override {
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

    bool addComment(const std::string& title, const nlohmann::json& commentJson) override {
        try {
            auto collection = db["games"];
            auto result = collection.update_one(
                make_document(kvp("title", title)),
                make_document(kvp("$push", make_document(kvp("comments", bsoncxx::from_json(commentJson.dump())))))
            );
            return (result && result->modified_count() > 0);
        } catch (...) { return false; }
    }

    bool deleteComment(const std::string& title, const std::string& commentIndex) override {
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

    bool updateGameImage(const std::string& title, const std::string& imageUrl) override {
        try {
            auto collection = db["games"];
            auto filter = make_document(kvp("title", title));
            auto update = make_document(kvp("$set", make_document(kvp("image_url", imageUrl))));

            auto result = collection.update_one(filter.view(), update.view());
            return (result && result->matched_count() > 0);
        } catch (...) { return false; }
    }

    bool updateComment(
        const std::string& title, 
        const std::string& commentIndex, 
        const std::string& author,
        const std::string& newContent) override {
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
};

#endif // MONGOGAMEREPOSITORY_HPP
#include "Server.hpp"
#include "Game.hpp"
#include "Developer.hpp"
#include "AuditLog.hpp"
#include "Ticket.hpp"
#include "GamePremier.hpp"

#include <chrono>
#include <iomanip>
#include <sstream>
#include <string>
#include <ctime>
#include <algorithm>
#include <numeric>


#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/builder/stream/document.hpp>
#include <bsoncxx/builder/stream/helpers.hpp>
#include <bsoncxx/oid.hpp> 

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

std::string Server::url_decode(const std::string& encoded) {
    std::string decoded;
    decoded.reserve(encoded.length()); 
    for (size_t i = 0; i < encoded.length(); ++i) {
        if (encoded[i] == '+') {
            decoded += ' ';
        } else if (encoded[i] == '%' && i + 2 < encoded.length()) {
            std::string hexStr = encoded.substr(i + 1, 2);
            try {
                decoded += static_cast<char>(std::stoi(hexStr, nullptr, 16));
                i += 2; 
            } catch (...) {
                decoded += '%';
            }
        } else {
            decoded += encoded[i];
        }
    }
    return decoded;
}

Server::Server() {
    m_mongo_uri_env = std::getenv("MONGO_URI");
    m_mongo_uri = m_mongo_uri_env ? m_mongo_uri_env : "mongodb://mongodb:27017";
    m_client = mongocxx::client{mongocxx::uri{m_mongo_uri}};
}

void Server::start() {
    setup_status_routes();
    setup_games_routes();
    setup_user_routes();
    setup_files_routes();
    setup_rating_routes();
    setup_developers_routes();
    setup_logs_routes();
    setup_platforms_routes();
    setup_reports_routes();

    m_svr.set_mount_point("/uploads", "./uploads");

    std::cout << "Serwer startuje na porcie 8080..." << std::endl;
    m_svr.listen("0.0.0.0", 8080);
}

void Server::setup_rating_routes(){
    m_svr.Post("/api/games/:title/rating",[this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        std::string title = req.path_params.at("title");
        nlohmann::json response;

        try {
            auto json_req = nlohmann::json::parse(req.body);
            std::string email = json_req.value("email", "");
            std::string vote = json_req.value("vote", "");

            if (email.empty() || (vote != "up" && vote != "down")) {
                res.status = 400;
                res.set_content(R"({"error": "Brak emaila lub nieprawidłowy głos (wymagane 'up' lub 'down')."})", "application/json");
                return;
            }

            auto db = m_client["game_db"];
            auto collection = db["games"];

            auto filter = make_document(
                kvp("title", title),
                kvp("rated_emails", make_document(kvp("$ne", email)))
            );

            std::string field_to_inc = (vote == "up") ? "rating_up" : "rating_down";

            auto update = make_document(
                kvp("$inc", make_document(kvp(field_to_inc, 1))),        // $inc zwiększa wartość o 1
                kvp("$push", make_document(kvp("rated_emails", email)))  // $push dodaje element na koniec tablicy
            );

            auto result = collection.update_one(filter.view(), update.view());
            if (result && result->modified_count() > 0) {
                res.status = 200;
                response["status"] = "ok";
                response["message"] = "Twój głos został pomyślnie dodany!";
            } else {
                auto game_exists = collection.count_documents(make_document(kvp("title", title)));
                if (game_exists > 0) {
                    res.status = 403; // 403 Forbidden
                    response["error"] = "Już oddałeś głos na tę grę!";
                } else {
                    res.status = 404; // 404 Not Found
                    response["error"] = "Nie znaleziono takiej gry.";
                }
            }

        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }
    });
}

void Server::setup_status_routes() {

    /*  
    *   Example of use:
        [http://localhost:8080/api/status]
    */

    m_svr.Get("/api/status", [this](const httplib::Request&, httplib::Response& res) {
        nlohmann::json response;
        response["status"] = "ok";
        response["message"] = "Status Serwera [OK]";
        
        try {
            auto db = m_client["game_db"];
            auto collections = db.list_collection_names();
            response["db_connection"] = "success";
            response["collections_count"] = std::distance(collections.begin(), collections.end());
        } catch (const std::exception& e) {
            response["db_connection"] = "failed";
            response["db_error"] = e.what();
        }

        res.set_content(response.dump(), "application/json");
    });
}

void Server::setup_games_routes() {

    m_svr.Delete("/api/games/:title",[this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        std::string title = req.path_params.at("title");
        nlohmann::json response;

        try {
            auto db = m_client["game_db"];
            auto collection = db["games"];
            auto filter = make_document(kvp("title", title));
            auto result = collection.delete_one(filter.view());
            
            if (result && result->deleted_count() > 0) {
                res.status = 200; 
                response["status"] = "ok";
                response["message"] = "Gra usunięta pomyślnie.";
            } else {
                res.status = 404;
                response["error"] = "Nie znaleziono takiej gry.";
            }
        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }
        res.set_content(response.dump(), "application/json");
    });

    m_svr.Put("/api/games/:title",[this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        std::string title = req.path_params.at("title");
        nlohmann::json response;

        try {
            auto json_req = nlohmann::json::parse(req.body);

            std::string dev = json_req.value("developer", "");
            int year = json_req.value("release_year", 2024);
            std::string genre = json_req.value("genre", "");

            auto db = m_client["game_db"];
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

            if (result && result->matched_count() > 0) {
                res.status = 200; 
                response["status"] = "ok";
                response["message"] = "Gra zaktualizowana pomyślnie.";
                std::cout << "Gra zaktualizowana pomyślnie.";
            } else {
                res.status = 404; 
                response["error"] = "Nie znaleziono takiej gry do edycji.";
                std::cout << "Nie znaleziono takiej gry do edycji.";
            }
            
        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }
        res.set_content(response.dump(), "application/json");
    });

m_svr.Delete("/api/games/:title/comments/:index",[this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        nlohmann::json response;

        try {
            std::string title = req.path_params.at("title");
            std::string index_str = req.path_params.at("index");

            auto db = m_client["game_db"];
            auto collection = db["games"];

            auto filter = make_document(kvp("title", title));
            std::string array_path = "comments." + index_str;
        
            auto unset_update = make_document(
                kvp("$unset", make_document(kvp(array_path, 1)))
            );

            collection.update_one(filter.view(), unset_update.view());

            auto pull_update = make_document(
                kvp("$pull", make_document(
                    kvp("comments", bsoncxx::types::b_null{})
                ))
            );

            auto pull_result = collection.update_one(filter.view(), pull_update.view());

            if (pull_result && pull_result->modified_count() > 0) {
                res.status = 200;
                response["status"] = "ok";
                response["message"] = "Komentarz usunięty pomyślnie.";
            } else {
                res.status = 404;
                response["error"] = "Nie znaleziono gry lub komentarza.";
            }
            
        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }
        res.set_content(response.dump(), "application/json");
    });

    /*
    * Example of request:
    *
    * [http://localhost:8080/api/games]
    * [http://localhost:8080/api/games?limit=2]
    * [http://localhost:8080/api/games?theme=Dark%20Fantasy]
    * [http://localhost:8080/api/games?theme=Dark%20Fantasy&limit=1]
    */
    m_svr.Get("/api/games", [this](const httplib::Request& req, httplib::Response& res){
        std::lock_guard<std::mutex> lock(m_db_mutex);

        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }
        
        nlohmann::json response;
        
        try {
            int limit = 20;
            if(req.has_param("limit")) {
                limit = std::stoi(req.get_param_value("limit"));
            }

            auto db = m_client["game_db"];
            auto collection = db["games"];

            mongocxx::options::find opts{};
            opts.limit(limit);

            // To filter documents
            bsoncxx::builder::basic::document filter_builder{};
            for(const auto& [key, values] : FILTER_KEYS) {
                for(const auto& v : values) {
                    if(req.has_param(v)) {
                        std::string value = req.get_param_value(v);
                        value = url_decode(value);
                        std::string k = (key == v) ? v : (key + "." + v);
                        filter_builder.append(kvp(k, value));
                    }
                }
            }

            auto filter = filter_builder.extract();
            auto cursor = collection.find(filter.view(), opts);
            nlohmann::json games_list = nlohmann::json::array();

            for(auto&& doc : cursor) {
                games_list.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            }

            response["status"] = "ok";
            response["count"] = games_list.size();
            response["games"] = games_list;

        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });

    /*
    Example of request
    * [http://localhost:8080/api/addgames]
    */

    m_svr.Post("/api/addgames", [this](const httplib::Request& req, httplib::Response& res) {
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        nlohmann::json response;
        try {
            auto j = nlohmann::json::parse(req.body);
            Game new_game = j.get<Game>();

            auto db = m_client["game_db"];
            auto collection = db["games"];
            auto doc = bsoncxx::from_json(j.dump());
            auto result = collection.insert_one(doc.view());

            if (result) {
                response["status"] = "success";
                response["message"] = "Gra dodana pomyślnie";
                response["inserted_id"] = result->inserted_id().get_oid().value.to_string();
                res.status = 201; 
            }

        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });

    m_svr.Post("/api/games/:title/comments", [this](const httplib::Request& req, httplib::Response& res) {
        if (!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Musisz być zalogowany, aby dodać komentarz"})", "application/json");
            return;
        }

        std::string token = req.get_header_value("Authorization");
        std::string game_title = req.path_params.at("title");

        try {
            auto comment_body = nlohmann::json::parse(req.body);
            
            // Wyciągamy autora z tokena (uproszczenie)
            std::string author = token.substr(8);

            // Tworzymy obiekt komentarza
            nlohmann::json full_comment;
            full_comment["author_name"] = author;
            full_comment["content"] = comment_body["content"];

            auto now = std::chrono::system_clock::now();
            auto in_time_t = std::chrono::system_clock::to_time_t(now);
            std::stringstream ss;
            ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");
            full_comment["date"] = ss.str();;

            auto db = m_client["game_db"];
            auto result = db["games"].update_one(
                make_document(kvp("title", game_title)),
                make_document(kvp("$push", make_document(kvp("comments", bsoncxx::from_json(full_comment.dump())))))
            );

            if (result && result->modified_count() > 0) {
                res.set_content(R"({"status": "Komentarz dodany!"})", "application/json");
            } else {
                res.status = 404;
                res.set_content(R"({"error": "Nie znaleziono gry"})", "application/json");
            }
        } catch (const std::exception& e) {
            res.status = 400;
            res.set_content(e.what(), "text/plain");
        }
    });
}

void Server::setup_user_routes() {
    // REJESTRACJA
    m_svr.Post("/api/register", [this](const httplib::Request& req, httplib::Response& res) {
        try {
            auto j = nlohmann::json::parse(req.body);
            User new_user = j.get<User>();

            auto db = m_client["game_db"];
            auto users = db["users"];

            // Sprawdź czy użytkownik już istnieje
            auto existing = users.find_one(make_document(kvp("email", new_user.email)));
            if (existing) {
                res.status = 400;
                res.set_content(R"({"error": "User already exists"})", "application/json");
                return;
            }

            users.insert_one(bsoncxx::from_json(j.dump()));
            res.status = 201;
            res.set_content(R"({"message": "User registered successfully"})", "application/json");
        
            log_activity(new_user.email, "USER_REGISTER", "Utworzono nowe konto w systemie");
            
        } catch (const std::exception& e) { 
            std::cout << "KRYTYCZNY BŁĄD W REJESTRACJI: " << e.what() << std::endl;
            nlohmann::json err_res;
            err_res["error"] = e.what();
            res.status = 400; 
            res.set_content(err_res.dump(), "application/json");
        }
    });

    // LOGOWANIE
    m_svr.Post("/api/login", [this](const httplib::Request& req, httplib::Response& res) {
        try {
            auto j = nlohmann::json::parse(req.body);
            auto db = m_client["game_db"];
            
            // Szukamy użytkownika
            auto user_doc = db["users"].find_one(make_document(
                kvp("email", j["email"].get<std::string>()),
                kvp("password", j["password"].get<std::string>())
            ));

            if (user_doc) {
                std::string token = "session_" + j["email"].get<std::string>(); 
                
                nlohmann::json response;
                response["status"] = "success";
                response["token"] = token; 
                response["user"] = j["email"].get<std::string>();

                res.set_content(response.dump(), "application/json");
                log_activity(j["email"].get<std::string>(), "USER_LOGIN", "Pomyślne logowanie użytkownika");
            } else {
                res.status = 401;
                res.set_content(R"({"error": "Błędne dane logowania"})", "application/json");
                log_activity(j["email"].get<std::string>(), "FAILED_LOGIN", "Próba logowania z błędnym hasłem");
            }
        } catch (const std::exception& e) { 
            res.status = 400; 
            res.set_content(R"({"error": "Błąd wewnętrzny serwera lub niepoprawny JSON"})", "application/json");
        }
    });

    m_svr.Delete("/api/users/:email", [this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        std::string email = req.path_params.at("email");
        nlohmann::json response;

        try {
            auto db = m_client["game_db"];
            auto collection = db["users"];
            auto filter = make_document(kvp("email", email));
            auto result = collection.delete_one(filter.view());

            if (result && result->deleted_count() > 0) {
                res.status = 200; 
                response["status"] = "ok";
                response["message"] = "Użytkownik usunięty pomyślnie.";
            } else {
                res.status = 404;
                response["error"] = "Brak takiego użytkownika";
            }

        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }
        res.set_content(response.dump(), "application/json");
    });

    //Odczyt użytkowników
    m_svr.Get("/api/users", [this](const httplib::Request& req, httplib::Response& res){
        std::lock_guard<std::mutex> lock(m_db_mutex);
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return;
        }

        nlohmann::json response;

        try {
            auto db = m_client["game_db"];
            auto collection = db["users"];

            bsoncxx::builder::basic::document filter_builder{};
            for(const std::string& k : FILTER_KEYS_USER) {
                if(req.has_param(k)) {
                    std::string value = req.get_param_value(k);
                    filter_builder.append(kvp("User", value));
                }
            }

            auto filter = filter_builder.extract();
            auto cursor = collection.find(filter.view(), {});
            nlohmann::json users_list = nlohmann::json::array();

            for(auto&& doc : cursor) {
                users_list.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            }

            response["status"] = "ok";
            response["count"] = users_list.size();
            response["users"] = users_list;
            res.status = 200;

        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 500;
        }
        res.set_content(response.dump(), "application/json");
    });
}

void Server::setup_files_routes() {
    m_svr.Post("/api/games/:title/image", [this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu."})", "application/json");
            return; 
        }      
        
        nlohmann::json response;
        std::string title = req.path_params.at("title");

        if (req.body.empty()) {
            res.status = 400;
            res.set_content(R"({"error": "Brak danych obrazka."})", "application/json");
            return;
        }

        std::string ext = ".jpg"; 
        if (req.has_header("X-File-Name")) {
            ext = "_" + req.get_header_value("X-File-Name");
        }

        std::string file_name = title + ext;
        std::string physical_path = "./uploads/" + file_name;
        std::string url_path = "/uploads/" + file_name;

        // Upewniamy się, że folder istnieje
        if (!std::filesystem::exists("./uploads")) {
            std::filesystem::create_directory("./uploads");
        }

        std::ofstream ofs(physical_path, std::ios::binary);
        if (!ofs.is_open()) {
            res.status = 500;
            res.set_content(R"({"error": "Błąd zapisu pliku na serwerze."})", "application/json");
            return;
        }
        ofs.write(req.body.data(), req.body.size());
        ofs.close();

        // Aktualizujemy bazę danych MongoDB
        try {
            auto collection = m_client["game_db"]["games"];
            auto filter = make_document(kvp("title", title));
            auto update = make_document(kvp("$set", make_document(kvp("image_url", url_path))));

            auto result = collection.update_one(filter.view(), update.view());

            if (result && result->matched_count() > 0) {
                res.status = 200;
                response["status"] = "ok";
                response["message"] = "Zdjęcie wgrane pomyślnie!";
                response["image_url"] = url_path;
            } else {
                res.status = 404;
                response["error"] = "Zdjęcie zapisano, ale nie znaleziono gry w bazie.";
            }

        } catch (const std::exception& e) {
            res.status = 500;
            response["error"] = "Błąd bazy danych: " + std::string(e.what());
        }
        
        res.set_content(response.dump(), "application/json");
    });
}

void Server::setup_developers_routes() {

    //DELETE 
    m_svr.Delete("/api/developers/:name", [this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        std::string name = req.path_params.at("name");
        nlohmann::json response;

        try {
            auto db = m_client["game_db"];
            auto collection = db["developers"];
            auto filter = make_document(kvp("name", name));
            auto result = collection.delete_one(filter.view());

            if (result && result->deleted_count() > 0) {
                res.status = 200; 
                response["status"] = "ok";
                response["message"] = "Developer usunięty pomyślnie.";
            } else {
                res.status = 404;
                response["error"] = "Brak takiego developera";
            }

        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });


    // POST /api/developers - Dodawanie nowego studia
    m_svr.Post("/api/developers", [this](const httplib::Request& req, httplib::Response& res) {
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        nlohmann::json response;
        try {
            auto j = nlohmann::json::parse(req.body);

            auto db = m_client["game_db"];
            auto collection = db["developers"];
            auto doc = bsoncxx::from_json(j.dump());
            auto result = collection.insert_one(doc.view());

            if (result) {
                response["status"] = "success";
                response["message"] = "Deweloper dodany pomyślnie";
                response["inserted_id"] = result->inserted_id().get_oid().value.to_string();
                res.status = 201; 
            }

        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });

    // GET /api/developers - Pobieranie listy deweloperów
    m_svr.Get("/api/developers", [this](const httplib::Request& req, httplib::Response& res) {
        std::lock_guard<std::mutex> lock(m_db_mutex);

        nlohmann::json response;
        try {
            auto db = m_client["game_db"];
            auto collection = db["developers"];
            auto cursor = collection.find({});
            nlohmann::json dev_list = nlohmann::json::array();

            for(auto&& doc : cursor) {
                dev_list.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            }

            response["status"] = "ok";
            response["count"] = dev_list.size();
            response["developers"] = dev_list;
            res.status = 200;

        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });
}
void Server::log_activity(const std::string& email, const std::string& action, const std::string& details) {
    try {
        auto db = m_client["game_db"];
        auto collection = db["audit_logs"]; // Nasza 5. KOLEKCJA!

        // Pobranie aktualnego czasu
        auto now = std::chrono::system_clock::now();
        auto in_time_t = std::chrono::system_clock::to_time_t(now);
        std::stringstream ss;
        ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");

        auto doc = make_document(
            kvp("timestamp", ss.str()),
            kvp("email", email),
            kvp("action", action),
            kvp("details", details)
        );
        collection.insert_one(doc.view());
    } catch (...) {
        std::cout << "Błąd zapisu logu w tle." << std::endl;
    }
}

// --- ENDPOINT DO ODCZYTU LOGÓW
void Server::setup_logs_routes() {
    m_svr.Get("/api/logs", [this](const httplib::Request& req, httplib::Response& res) {
        std::lock_guard<std::mutex> lock(m_db_mutex);

        nlohmann::json response;
        try {
            auto db = m_client["game_db"];
            auto collection = db["audit_logs"];
            
            mongocxx::options::find opts{};
            opts.sort(make_document(kvp("timestamp", -1)));
            opts.limit(50); 

            auto cursor = collection.find({}, opts);
            nlohmann::json logs_list = nlohmann::json::array();

            for(auto&& doc : cursor) {
                logs_list.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            }

            response["status"] = "ok";
            response["count"] = logs_list.size();
            response["logs"] = logs_list;
            res.status = 200;

        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera przy odczycie logów";
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });
}
void Server::setup_platforms_routes() {
        m_svr.Post("/api/platforms", [this](const httplib::Request& req, httplib::Response& res) {
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        nlohmann::json response;
        try {
            auto j = nlohmann::json::parse(req.body);

            auto db = m_client["game_db"];
            auto collection = db["platforms"];
            auto doc = bsoncxx::from_json(j.dump());
            auto result = collection.insert_one(doc.view());

            if (result) {
                response["status"] = "success";
                response["message"] = "Deweloper dodany pomyślnie";
                response["inserted_id"] = result->inserted_id().get_oid().value.to_string();
                res.status = 201; 
            }

        } catch (const nlohmann::json::exception& e) {
            response["status"] = "error";
            response["message"] = "Błędny format JSON";
            response["details"] = e.what();
            res.status = 400;
        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });

    // DELETE /api/platforms/:name
    m_svr.Delete("/api/platforms/:name", [this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        std::string name = req.path_params.at("name");
        nlohmann::json response;

        try {
            auto db = m_client["game_db"];
            auto collection = db["platforms"];
            auto filter = make_document(kvp("name", name));
            auto result = collection.delete_one(filter.view());

            if (result && result->deleted_count() > 0) {
                res.status = 200; 
                response["status"] = "ok";
                response["message"] = "Platforma usunięta pomyślnie.";
            } else {
                res.status = 404;
                response["error"] = "Brak takiej platformy";
            }

        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });

    // GET /api/platforms - Pobieranie listy platform
    m_svr.Get("/api/platforms", [this](const httplib::Request& req, httplib::Response& res) {
        std::lock_guard<std::mutex> lock(m_db_mutex);

        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak dostępu. Zaloguj się!"})", "application/json");
            return; 
        }

        nlohmann::json response;
        try {
            auto db = m_client["game_db"];
            auto collection = db["platforms"];
            auto cursor = collection.find({});
            nlohmann::json plat_list = nlohmann::json::array();

            for(auto&& doc : cursor) {
                plat_list.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            }

            response["status"] = "ok";
            response["count"] = plat_list.size();
            response["platforms"] = plat_list;
            res.status = 200;

        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500;
        }

        res.set_content(response.dump(), "application/json");
    });
}

void Server::setup_reports_routes() {

     m_svr.Post("/api/reports", [this](const httplib::Request& req, httplib::Response& res){
        std::lock_guard<std::mutex> lock(m_db_mutex); 
        
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Musisz być zalogowany, aby wysłać zgłoszenie."})", "application/json");
            return; 
        }

        try {
            auto j = nlohmann::json::parse(req.body);
            std::string email = j.value("email_user", "Nieznany");
            std::string message = j.value("message", "Brak wiadomości");

            auto now = std::chrono::system_clock::now();
            auto in_time_t = std::chrono::system_clock::to_time_t(now);
            std::stringstream ss;
            ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %H:%M:%S");

            nlohmann::json final_j;
            final_j["email_user"] = email;
            final_j["message"] = message;
            final_j["timestamp"] = ss.str();
            
            auto db = m_client["game_db"];
            auto doc = bsoncxx::from_json(final_j.dump());
            
            auto result = db["reports"].insert_one(doc.view());

            if (result) {
                res.status = 201;
                res.set_content(R"({"status": "success", "message": "Zgłoszenie dodane"})", "application/json");
                log_activity(email, "REPORT_SUBMITTED", "Użytkownik wysłał zgłoszenie");
                return; 
            }
        } catch (const std::exception& e) {
            res.status = 400;
            res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
            return;
        }
        
        res.status = 500;
        res.set_content(R"({"error": "Nie udało się zapisać zgłoszenia do bazy."})", "application/json");
    });

    m_svr.Get("/api/reports", [this](const httplib::Request& req, httplib::Response& res){
        std::lock_guard<std::mutex> lock(m_db_mutex);

        nlohmann::json response;

        try {
            auto db = m_client["game_db"];
            auto cursor =  db["reports"].find({});
            nlohmann::json reports_list = nlohmann::json::array();

            for(auto&& doc : cursor) {
                reports_list.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            }

            res.status = 200;
            response["status"] = "ok";
            response["count"] = reports_list.size();
            response["reports"] = reports_list;

        } catch (const std::exception& e) {
            response["status"] = "error";
            response["message"] = "Błąd serwera/bazy danych";
            response["details"] = e.what();
            res.status = 500; 
        }
        res.set_content(response.dump(), "application/json");
    });

    m_svr.Delete(R"(/api/reports/([^/]+))", [this](const httplib::Request& req, httplib::Response& res){
        if(!req.has_header("Authorization")) {
            res.status = 401;
            res.set_content(R"({"error": "Brak autoryzacji."})", "application/json");
            return; 
        }

        nlohmann::json response;
        std::string report_id = req.matches[1]; 

        try {
            auto db = m_client["game_db"];
            auto result = db["reports"].delete_one(
                bsoncxx::builder::stream::document{} 
                    << "_id" << bsoncxx::oid{report_id} 
                    << bsoncxx::builder::stream::finalize
            );

            if (result && result->deleted_count() > 0) {
                res.status = 200;
                res.set_content(R"({"status": "ok", "message": "Zgłoszenie zostało zamknięte/usunięte"})", "application/json");
                log_activity("ADMIN", "REPORT_CLOSED", "Zamknięto ticket: " + report_id);
            } else {
                res.status = 404;
                res.set_content(R"({"status": "error", "message": "Zgłoszenie nie zostało znalezione"})", "application/json");
            }
        } catch (const std::exception& e) {
            res.status = 500;
            response["status"] = "error";
            response["message"] = "Błąd podczas usuwania zgłoszenia";
            response["details"] = e.what();
            res.set_content(response.dump(), "application/json");
        }
    });
}

void Server::setup_premiere_routes() {
    m_svr.Post("/api/premiers", [this](const httplib::Request& req, httplib::Response& res) {
        std::lock_guard<std::mutex> lock(m_db_mutex);
        try {
            auto j = nlohmann::json::parse(req.body);
            auto db = m_client["game_db"];
            auto doc = bsoncxx::from_json(j.dump());
            
            db["premiers"].insert_one(doc.view());
            res.status = 201;
            res.set_content(R"({"status": "ok", "message": "Premiera dodana"})", "application/json");
        } catch (const std::exception& e) {
            res.status = 400;
            res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
        }
    });

    m_svr.Get("/api/premiers", [this](const httplib::Request& req, httplib::Response& res) {
        std::lock_guard<std::mutex> lock(m_db_mutex);
        try {
            auto db = m_client["game_db"];
            mongocxx::options::find opts{};
            opts.sort(bsoncxx::builder::basic::make_document(bsoncxx::builder::basic::kvp("release_date", 1)));

            auto cursor = db["premiers"].find({}, opts);
            nlohmann::json list = nlohmann::json::array();
            for (auto&& doc : cursor) {
                list.push_back(nlohmann::json::parse(bsoncxx::to_json(doc)));
            }
            res.set_content(nlohmann::json{{"status", "ok"}, {"premiers", list}}.dump(), "application/json");
        } catch (const std::exception& e) {
            res.status = 500;
            res.set_content(nlohmann::json{{"error", e.what()}}.dump(), "application/json");
        }
    });
}
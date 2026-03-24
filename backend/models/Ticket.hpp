#ifndef TICKET_HPP
#define TICKET_HPP

#include <string>
#include <nlohmann/json.hpp>

struct Ticket {
    std::string email_user;
    std::string text;
    std::string timestamp;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Ticket, email_user, text, timestamp);
};

#endif // TICKET_HPP
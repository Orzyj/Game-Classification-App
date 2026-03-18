#ifndef COMMMENT_H
#define COMMMENT_H

struct Comment {
    std::string author_name;
    std::string content;
    std::string date;        

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Comment, author_name, content, date)
};

#endif // COMMENT_H
#ifndef IMAGEUPLOADER_HPP
#define IMAGEUPLOADER_HPP

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QFile>
#include <QUrl>

class ImageUploader : public QObject {
    Q_OBJECT
public:
    explicit ImageUploader(QObject *parent = nullptr);

    Q_INVOKABLE void uploadImage(const QString &gameTitle, const QString &fileUrl, const QString &token);

signals:
    void uploadFinished(bool success, const QString &message);

private:
    QNetworkAccessManager *m_manager;
};

#endif // IMAGEUPLOADER_HPP

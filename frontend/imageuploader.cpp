#include "imageuploader.h"
#include <QFileInfo>
#include <QDebug>

ImageUploader::ImageUploader(QObject *parent) : QObject(parent) {
    m_manager = new QNetworkAccessManager(this);
}

void ImageUploader::uploadImage(const QString &gameTitle, const QString &fileUrl, const QString &token) {
    QString localPath = QUrl(fileUrl).toLocalFile();
    QFile file(localPath);

    if (!file.open(QIODevice::ReadOnly)) {
        emit uploadFinished(false, "Nie można otworzyć pliku do wysłania.");
        return;
    }

    QByteArray imageData = file.readAll();
    file.close();

    if (imageData.isEmpty()) {
        emit uploadFinished(false, "Błąd: Wczytany plik ma 0 bajtów.");
        qDebug() << "[ImageUploader] Błąd: Plik jest pusty lub zablokowany!";
        return;
    }

    qDebug() << "[ImageUploader] Wysyłam plik o rozmiarze:" << imageData.size() << "bajtów";

    QUrl url("http://localhost:8080/api/games/" + gameTitle + "/image");
    QNetworkRequest request(url);

    request.setRawHeader("Authorization", token.toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
    request.setRawHeader("X-File-Name", QFileInfo(localPath).fileName().toUtf8());

    request.setHeader(QNetworkRequest::ContentLengthHeader, imageData.size());

    QNetworkReply *reply = m_manager->post(request, imageData);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            emit uploadFinished(true, "Zdjęcie wgrane pomyślnie.");
            qDebug() << "[ImageUploader] Sukces:" << reply->readAll();
        } else {
            QString serverError = reply->readAll();
            emit uploadFinished(false, "Błąd wgrywania: " + reply->errorString() + " | Serwer: " + serverError);
            qDebug() << "[ImageUploader] Błąd:" << reply->errorString() << "Serwer:" << serverError;
        }
        reply->deleteLater();
    });
}

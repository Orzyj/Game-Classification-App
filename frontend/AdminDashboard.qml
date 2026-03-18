import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f8f9fa" // Jasnoszare tło dla czystego, nowoczesnego wyglądu

    property string authToken: ""
    property string loggedUserEmail: ""

    // Modele danych
    property var gamesList: []
    property var usersList: []

    // Zmienna pomocnicza do zapamiętania, którą grę akurat edytujemy
    property string editingGameTitle: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // ==========================================
        // PASEK NAWIGACJI ADMINA
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            height: 70
            color: "#dc3545" // Ostrzegawczy czerwony pasek
            radius: 8
            border.color: "#b02a37"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                Label {
                    text: "👑 PANEL ADMINISTRATORA: " + root.loggedUserEmail
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                    Layout.fillWidth: true
                }

                Button {
                    text: "Odśwież Dane"
                    background: Rectangle { color: "transparent"; border.color: "white"; border.width: 1; radius: 5 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        fetchGames()
                        fetchUsers()
                    }
                }

                Button {
                    text: "Wyloguj się"
                    background: Rectangle { color: "#212529"; radius: 5 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: stackView.pop()
                }
            }
        }

        // ==========================================
        // ZAKŁADKI (TABS) DO PRZEŁĄCZANIA WIDOKÓW
        // ==========================================
        TabBar {
            id: adminTabs
            Layout.fillWidth: true
            background: Rectangle { color: "transparent" }

            TabButton {
                text: "🎮 Zarządzanie Grami"
                font.bold: true
                background: Rectangle {
                    color: adminTabs.currentIndex === 0 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: adminTabs.currentIndex === 0 ? "#dc3545" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TabButton {
                text: "👥 Zarządzanie Użytkownikami"
                font.bold: true
                background: Rectangle {
                    color: adminTabs.currentIndex === 1 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: adminTabs.currentIndex === 1 ? "#dc3545" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Komunikat o stanie
        Label {
            id: statusLabel
            text: adminTabs.currentIndex === 0 ? (root.gamesList.length === 0 ? "Brak gier w bazie." : "") : (root.usersList.length === 0 ? "Brak użytkowników." : "")
            color: "#6c757d"
            font.italic: true
            font.bold: true
            visible: (adminTabs.currentIndex === 0 && root.gamesList.length === 0) || (adminTabs.currentIndex === 1 && root.usersList.length === 0)
            Layout.alignment: Qt.AlignHCenter
        }

        // ==========================================
        // WIDOK 1: FEED GIER (Tryb Edycji i Usuwania)
        // ==========================================
        ListView {
            id: gamesListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 25
            model: root.gamesList

            visible: adminTabs.currentIndex === 0

            delegate: Rectangle {
                width: gamesListView.width
                height: postLayout.implicitHeight + 50
                color: "white"
                radius: 12
                border.color: "#f5c2c7" // Różowa ramka wskazująca na tryb edycji
                border.width: 2

                required property var modelData
                required property int index
                property var game: modelData

                ColumnLayout {
                    id: postLayout
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 15

                    // NAGŁÓWEK POSTA Z PRZYCISKAMI ADMINA
                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true
                            Label { text: game.title; font.bold: true; font.pixelSize: 24; color: "#212529" }
                            Label { text: game.developer + " • " + game.release_year; font.pixelSize: 15; color: "#6c757d"; font.bold: true }
                        }

                        Button {
                            text: "✏️ Edytuj"
                            background: Rectangle { color: "#e9ecef"; radius: 5; border.color: "#ced4da"; border.width: 1 }
                            contentItem: Text { text: parent.text; color: "#495057"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: openEditPopup(game)
                        }
                        Button {
                            text: "🗑️ Usuń Grę"
                            background: Rectangle { color: "#f8d7da"; radius: 5; border.color: "#dc3545"; border.width: 1 }
                            contentItem: Text { text: parent.text; color: "#dc3545"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: deleteGame(game.title)
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 2; color: "#e9ecef"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

                    Label { text: "Zarządzaj komentarzami (" + game.comments.length + ")"; font.bold: true; font.pixelSize: 16; color: "#495057" }

                    Repeater {
                        model: game.comments
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            Layout.bottomMargin: 10

                            required property var modelData
                            required property int index
                            property var comment: modelData

                            Rectangle {
                                Layout.fillWidth: true
                                height: commentCol.implicitHeight + 20
                                color: "#f8f9fa"
                                radius: 8
                                border.color: "#dee2e6"
                                border.width: 1

                                ColumnLayout {
                                    id: commentCol
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4
                                    Label { text: comment.author_name + " • " + comment.date; font.bold: true; font.pixelSize: 13; color: "#212529" }
                                    Label { text: comment.content; wrapMode: Text.Wrap; font.pixelSize: 14; color: "#343a40"; Layout.fillWidth: true }
                                }
                            }

                            Button {
                                text: "❌ Usuń"
                                background: Rectangle { color: "transparent"; radius: 5 }
                                contentItem: Text { text: parent.text; color: "#dc3545"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: deleteComment(game.title, index)
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // WIDOK 2: ZARZĄDZANIE UŻYTKOWNIKAMI
        // ==========================================
        ListView {
            id: usersListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 15
            model: root.usersList

            visible: adminTabs.currentIndex === 1

            delegate: Rectangle {
                width: usersListView.width
                height: 80
                color: "white"
                radius: 12
                border.color: "#ced4da"
                border.width: 1

                required property var modelData
                property var user: modelData

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: "#e9ecef"
                        Label { text: "👤"; anchors.centerIn: parent; font.pixelSize: 24 }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        spacing: 4

                        Label {
                            text: user.email ? user.email : "Brak email"
                            font.bold: true
                            font.pixelSize: 18
                            color: "#212529"
                        }
                        Label {
                            text: "ID: " + (user._id ? user._id["$oid"] : "Brak")
                            font.pixelSize: 13
                            color: "#6c757d"
                        }
                    }

                    Button {
                        text: "🗑️ Usuń Użytkownika"
                        background: Rectangle { color: "#f8d7da"; radius: 5; border.color: "#dc3545"; border.width: 1 }
                        contentItem: Text { text: parent.text; color: "#dc3545"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        visible: user.email !== root.loggedUserEmail
                        onClicked: deleteUser(user.email)
                    }

                    Label {
                        text: "(To Twoje konto)"
                        color: "#198754"
                        font.italic: true
                        font.bold: true
                        visible: user.email === root.loggedUserEmail
                    }
                }
            }
        }
    }

    // ==========================================
    // POP-UP DO EDYCJI GRY
    // ==========================================
    Popup {
        id: editPopup
        width: 450
        height: editLayout.implicitHeight + 50
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: "white"
            radius: 12
            border.color: "#ced4da"
            border.width: 1

            ColumnLayout {
                id: editLayout
                anchors.fill: parent
                anchors.margins: 25
                spacing: 15

                Label { text: "Edycja Gry: " + root.editingGameTitle; font.bold: true; font.pixelSize: 20; color: "#212529" }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6"; Layout.bottomMargin: 10 }

                TextField { id: editDev; placeholderText: "Deweloper"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: editYear; placeholderText: "Rok wydania"; validator: IntValidator {bottom: 1950; top: 2100} Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: editGenre; placeholderText: "Gatunek"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }

                Label { id: editStatus; text: ""; color: "#dc3545"; font.bold: true }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: 10
                    spacing: 15

                    Button {
                        text: "Anuluj"
                        background: Rectangle { color: "#e9ecef"; radius: 5 }
                        contentItem: Text { text: parent.text; color: "#495057"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: editPopup.close()
                    }
                    Button {
                        text: "Zapisz Zmiany"
                        background: Rectangle { color: "#0d6efd"; radius: 5 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: saveGameEdits()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        fetchGames()
        fetchUsers()
    }

    // ==========================================
    // FUNKCJE API: GRY I KOMENTARZE
    // ==========================================

    function fetchGames() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/api/games");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    if (jsonResponse.status === "ok" && jsonResponse.games) {
                        var flatGames = jsonResponse.games.map(function(game) {
                            return {
                                title: game.title,
                                developer: game.developer,
                                release_year: game.release_year,
                                genre: game.classification ? game.classification.genre : "-",
                                comments: game.comments ? game.comments : []
                            };
                        });
                        root.gamesList = flatGames;
                    }
                } catch(e) { console.error("Błąd parsowania gier"); }
            }
        }
        xhr.send();
    }

    function deleteGame(title) {
        var xhr = new XMLHttpRequest();
        xhr.open("DELETE", "http://localhost:8080/api/games/" + encodeURIComponent(title));
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 204)) {
                fetchGames();
            }
        }
        xhr.send();
    }

    function deleteComment(gameTitle, commentIndex) {
        var xhr = new XMLHttpRequest();
        xhr.open("DELETE", "http://localhost:8080/api/games/" + encodeURIComponent(gameTitle) + "/comments/" + commentIndex);
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 204)) {
                fetchGames();
            }
        }
        xhr.send();
    }

    function openEditPopup(game) {
        root.editingGameTitle = game.title;
        editDev.text = game.developer;
        editYear.text = game.release_year.toString();
        editGenre.text = game.genre;
        editStatus.text = "";
        editPopup.open();
    }

    function saveGameEdits() {
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "http://localhost:8080/api/games/" + encodeURIComponent(root.editingGameTitle));
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    editPopup.close();
                    fetchGames();
                } else {
                    editStatus.text = "Błąd edycji: " + xhr.responseText;
                }
            }
        }

        var payload = {
            "developer": editDev.text,
            "release_year": parseInt(editYear.text),
            "genre": editGenre.text
        };
        xhr.send(JSON.stringify(payload));
    }

    // ==========================================
    // FUNKCJE API: UŻYTKOWNICY
    // ==========================================

    function fetchUsers() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/api/users");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    if (jsonResponse.status === "ok" && jsonResponse.users) {
                        root.usersList = jsonResponse.users;
                    }
                } catch(e) { console.error("Błąd parsowania użytkowników:", e); }
            }
        }
        xhr.send();
    }

    function deleteUser(email) {
        var xhr = new XMLHttpRequest();
        xhr.open("DELETE", "http://localhost:8080/api/users/" + encodeURIComponent(email));
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 204)) {
                fetchUsers();
            }
        }
        xhr.send();
    }
}

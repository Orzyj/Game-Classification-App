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
    property var logsList: []
    property var reportsList: []
    property var premieresList: []

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
                    text: "➕ Dodaj Premierę"
                    background: Rectangle { color: "#28a745"; radius: 5 } // Zielony przycisk akcji
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked:
                    {
                        addPremierePopup.open();
                        fetchPremieres();
                    }
                }

                Button {
                    text: "Odśwież Dane"
                    background: Rectangle { color: "transparent"; border.color: "white"; border.width: 1; radius: 5 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        fetchGames()
                        fetchUsers()
                        fetchLogs()
                        fetchReports()
                        fetchPremieres()
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
            TabButton {
                text: "📜 Logi Aktywności"
                font.bold: true
                background: Rectangle {
                    color: adminTabs.currentIndex === 2 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: adminTabs.currentIndex === 2 ? "#dc3545" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TabButton {
                text: "📝 Tickety"
                font.bold: true
                background: Rectangle {
                    color: adminTabs.currentIndex === 3 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: adminTabs.currentIndex === 3 ? "#dc3545" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TabButton {
                text: "📅 Premiery"
                font.bold: true
                background: Rectangle {
                    color: adminTabs.currentIndex === 4 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: adminTabs.currentIndex === 4 ? "#dc3545" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Komunikat o stanie
        Label {
            id: statusLabel
            text: adminTabs.currentIndex === 0 ? (root.gamesList.length === 0 ? "Brak gier w bazie." : "") :
                  adminTabs.currentIndex === 1 ? (root.usersList.length === 0 ? "Brak użytkowników." : "") :
                  adminTabs.currentIndex === 2 ? (root.logsList.length === 0 ? "Brak logów aktywności." : "") :
                  adminTabs.currentIndex === 3 ? (root.reportsList.length === 0 ? "Brak zgłoszonych ticketów." : "") :
                  (root.premieresList.length === 0 ? "Brak zaplanowanych premier." : "")
            color: "#6c757d"
            font.italic: true
            font.bold: true
            visible: (adminTabs.currentIndex === 0 && root.gamesList.length === 0) ||
                     (adminTabs.currentIndex === 1 && root.usersList.length === 0) ||
                     (adminTabs.currentIndex === 2 && root.logsList.length === 0) ||
                     (adminTabs.currentIndex === 3 && root.reportsList.length === 0) ||
                     (adminTabs.currentIndex === 4 && root.premieresList.length === 0)
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
                height: userLayout.implicitHeight + 30
                color: "white"
                radius: 12
                border.color: "#ced4da"
                border.width: 1

                required property var modelData
                property var user: modelData

                RowLayout {
                    id: userLayout
                    anchors.fill: parent
                    anchors.margins: 15

                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        width: 50; height: 50; radius: 25
                        color: "#e9ecef"
                        Label { text: "👤"; anchors.centerIn: parent; font.pixelSize: 24 }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        spacing: 4

                        Label {
                            text: user.name ? user.name : "Nieznana nazwa"
                            font.bold: true
                            font.pixelSize: 18
                            color: "#212529"
                        }

                        Label {
                            text: "📧 Email: " + (user.email ? user.email : "Brak email")
                            font.pixelSize: 14
                            color: "#495057"
                        }

                        Label {
                            text: "🔑 Hasło (hash): " + (user.password ? user.password : "Brak")
                            font.pixelSize: 12
                            color: "#adb5bd"
                        }

                        RowLayout {
                            spacing: 15
                            Layout.topMargin: 5

                            Label {
                                text: "👑 Rola: " + (user.isMod ? "Moderator" : "Zwykły użytkownik")
                                font.pixelSize: 13
                                font.bold: true
                                color: user.isMod ? "#d63384" : "#6c757d"
                            }

                            Label {
                                text: "🟢 Status: " + (user.isEnable !== false ? "Konto aktywne" : "Zablokowane")
                                font.pixelSize: 13
                                font.bold: true
                                color: user.isEnable !== false ? "#198754" : "#dc3545"
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 10

                        // Przyciski Uprawnień (MOD)
                        Button {
                            text: "⬆️ Nadaj Moda"
                            visible: user.isMod === false || user.isMod === undefined
                            background: Rectangle { color: "#28a745"; radius: 5 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: toggleModStatus(user.email, true)
                        }

                        Button {
                            text: "⬇️ Odbierz Moda"
                            visible: user.isMod === true
                            background: Rectangle { color: "#ffc107"; radius: 5 }
                            contentItem: Text { text: parent.text; color: "#212529"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: toggleModStatus(user.email, false)
                        }

                        // Przyciski Statusu Konta (ENABLE/DISABLE)
                        Button {
                            text: "✅ Odblokuj"
                            visible: user.isEnable === false
                            background: Rectangle { color: "#20c997"; radius: 5 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: toggleAccountStatus(user.email, true)
                        }

                        Button {
                            text: "🚫 Zablokuj"
                            visible: user.isEnable !== false
                            background: Rectangle { color: "#fd7e14"; radius: 5 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: toggleAccountStatus(user.email, false)
                        }

                        // Przycisk Usuwania
                        Button {
                            text: "🗑️ Usuń"
                            enabled: false
                            background: Rectangle { color: "#f8d7da"; radius: 5; border.color: "#dc3545"; border.width: 1 }
                            contentItem: Text { text: parent.text; color: "#dc3545"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: deleteUser(user.email)
                        }
                    }
                }
            }
        }

        // ==========================================
        // WIDOK 3: LOGI AKTYWNOŚCI
        // ==========================================
        ListView {
            id: logsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: root.logsList

            visible: adminTabs.currentIndex === 2

            delegate: Rectangle {
                width: logsListView.width
                height: logLayout.implicitHeight + 20
                color: "white"
                radius: 8
                border.color: "#ced4da"
                border.width: 1

                required property var modelData
                property var logEntry: modelData

                ColumnLayout {
                    id: logLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "🕒 " + logEntry.timestamp
                            font.pixelSize: 12
                            color: "#6c757d"
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true } // Wypełniacz robiący odstęp

                        // Tag akcji (np. USER_LOGIN)
                        Rectangle {
                            color: "#e9ecef"
                            radius: 4
                            width: actionLabel.width + 10
                            height: actionLabel.height + 6
                            Label {
                                id: actionLabel
                                text: logEntry.action
                                anchors.centerIn: parent
                                font.pixelSize: 11
                                font.bold: true
                                color: "#495057"
                            }
                        }
                    }

                    Label {
                        text: "👤 Użytkownik: " + logEntry.email
                        font.pixelSize: 14
                        font.bold: true
                        color: "#212529"
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "📝 Szczegóły: " + logEntry.details
                        font.pixelSize: 14
                        color: "#343a40"
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // ==========================================
        // WIDOK 4: TICKETY (RAPORTY)
        // ==========================================
        ListView {
            id: ticketListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: root.reportsList

            visible: adminTabs.currentIndex === 3

            delegate: Rectangle {
                width: ticketListView.width
                height: ticketLayout.implicitHeight + 20
                color: "#fff3cd" // Żółtawe tło dla zgłoszeń
                radius: 8
                border.color: "#ffe69c"
                border.width: 1

                required property var modelData
                property var ticketEntry: modelData

                ColumnLayout {
                    id: ticketLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "🕒 " + (ticketEntry.timestamp ? ticketEntry.timestamp : "Brak daty")
                            font.pixelSize: 12
                            color: "#856404"
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }

                        // Przycisk Zakończ - gotowy do podpięcia endpointu usuwania/zamykania ticketu
                        Button {
                            text: "✓ Zakończ"
                            background: Rectangle { color: "transparent"; radius: 4; border.color: "#856404" }
                            contentItem: Text { text: parent.text; color: "#856404"; font.bold: true; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                if (ticketEntry._id && ticketEntry._id["$oid"]) {
                                    closeTicket(ticketEntry._id["$oid"]);
                                } else {
                                    console.error("Brak poprawnego ID dla tego zgłoszenia.");
                                }
                            }
                        }
                    }

                    Label {
                        text: "👤 Zgłaszający: " + (ticketEntry.email_user ? ticketEntry.email_user : "Nieznany")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#212529"
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "📝 Treść: " + (ticketEntry.message ? ticketEntry.message : (ticketEntry.content ? ticketEntry.content : "Brak treści zgłoszenia."))
                        font.pixelSize: 14
                        color: "#343a40"
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // ==========================================
        // WIDOK 5: PREMIERY GIER
        // ==========================================
        ListView {
            id: premieresListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 15
            model: root.premieresList

            visible: adminTabs.currentIndex === 4

            delegate: Rectangle {
                width: premieresListView.width
                height: premiereLayout.implicitHeight + 20
                color: "#f8f9fa"
                radius: 8
                border.color: "#ced4da"
                border.width: 1

                required property var modelData
                property var premiere: modelData

                ColumnLayout {
                    id: premiereLayout
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: premiere.title + " (" + premiere.platform + ")"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#212529"
                        }

                        Item { Layout.fillWidth: true } // Wypełniacz

                        // Etykieta Exclusive (wyświetla się tylko jeśli true)
                        Rectangle {
                            color: "#ffc107" // Złoty/żółty
                            radius: 4
                            width: exclLabel.width + 12
                            height: exclLabel.height + 6
                            visible: premiere.is_exclusive === true

                            Label {
                                id: exclLabel
                                text: "👑 Exclusive"
                                anchors.centerIn: parent
                                font.pixelSize: 11
                                font.bold: true
                                color: "#212529"
                            }
                        }
                    }

                    Label {
                        text: "🏢 Deweloper: " + premiere.developer
                        font.pixelSize: 14
                        color: "#495057"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 25

                        Label {
                            text: "📅 Data premiery: " + premiere.release_date
                            font.pixelSize: 14
                            font.bold: true
                            color: "#0d6efd" // Niebieski akcent dla daty
                        }

                        Label {
                            text: "🔥 Hype Score: " + premiere.hype_score + "/100"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#dc3545" // Czerwony akcent dla hype
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // POP-UP DO DODAWANIA PREMIERY
    // ==========================================
    Popup {
        id: addPremierePopup
        width: 450
        height: addPremiereLayout.implicitHeight + 50
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
                id: addPremiereLayout
                anchors.fill: parent
                anchors.margins: 25
                spacing: 15

                Label { text: "Dodaj Nową Premierę"; font.bold: true; font.pixelSize: 20; color: "#212529" }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6"; Layout.bottomMargin: 10 }

                TextField { id: premTitle; placeholderText: "Tytuł gry"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: premDev; placeholderText: "Deweloper"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: premPlatform; placeholderText: "Platforma (np. PC, PS5)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: premDate; placeholderText: "Data premiery (YYYY-MM-DD)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: premHype; placeholderText: "Hype Score (0-100)"; validator: IntValidator {bottom: 0; top: 100} Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }

                CheckBox { id: premExclusive; text: "Gra ekskluzywna (Exclusive)" }

                Label { id: premStatus; text: ""; color: "#dc3545"; font.bold: true }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: 10
                    spacing: 15

                    Button {
                        text: "Anuluj"
                        background: Rectangle { color: "#e9ecef"; radius: 5 }
                        contentItem: Text { text: parent.text; color: "#495057"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: addPremierePopup.close()
                    }
                    Button {
                        text: "Dodaj"
                        background: Rectangle { color: "#28a745"; radius: 5 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: submitPremiere()
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
        fetchLogs()
        fetchReports()
        fetchPremieres()
    }

    // ==========================================
    // FUNKCJE UŻYTKOWNIKÓW (UPRAWNIENIA / STATUS)
    // ==========================================

    function toggleModStatus(email, flag) {
        var xhr = new XMLHttpRequest();
        var flagStr = flag ? "true" : "false";

        xhr.open("PATCH", "http://localhost:8080/api/users/" + encodeURIComponent(email) + "/" + flagStr);
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("Pomyślnie zmieniono uprawnienia użytkownika: " + email);
                    fetchUsers(); // Odświeżamy listę, by zobaczyć efekty
                } else {
                    console.error("Błąd podczas zmiany uprawnień:", xhr.responseText);
                }
            }
        }
        xhr.send();
    }

    function toggleAccountStatus(email, flag) {
        var xhr = new XMLHttpRequest();
        var flagStr = flag ? "true" : "false";

        // Strzał do nowo dodanego endpointu: /api/users/:email/status/:flag
        xhr.open("PATCH", "http://localhost:8080/api/users/" + encodeURIComponent(email) + "/status/" + flagStr);
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("Pomyślnie zmieniono status konta: " + email);
                    fetchUsers(); // Odświeżamy listę
                } else {
                    console.error("Błąd podczas zmiany statusu konta:", xhr.responseText);
                }
            }
        }
        xhr.send();
    }

    // ==========================================
    // FUNKCJE API: PREMIERY
    // ==========================================

    function fetchPremieres() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/api/premiers");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    if (jsonResponse.status === "ok" && jsonResponse.premiers) {
                        root.premieresList = jsonResponse.premiers;
                    }
                } catch(e) { console.error("Błąd parsowania list premier:", e); }
            }
        }
        xhr.send();
    }

    function submitPremiere() {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/premiers");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 201) {
                    addPremierePopup.close();

                    // Wyczyszczenie formularza
                    premTitle.text = "";
                    premDev.text = "";
                    premPlatform.text = "";
                    premDate.text = "";
                    premHype.text = "";
                    premExclusive.checked = false;
                    premStatus.text = "";
                    console.log("Premiera dodana pomyślnie.");
                    fetchPremieres();

                } else {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        premStatus.text = "Błąd: " + (response.error ? response.error : xhr.responseText);
                    } catch(e) {
                        premStatus.text = "Wystąpił nieznany błąd.";
                    }
                }
            }
        }

        var payload = {
            "title": premTitle.text,
            "developer": premDev.text,
            "platform": premPlatform.text,
            "release_date": premDate.text,
            "hype_score": parseInt(premHype.text) || 0,
            "is_exclusive": premExclusive.checked
        };

        xhr.send(JSON.stringify(payload));
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
    // FUNKCJE API: UŻYTKOWNICY I LOGI
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

                        // TUTAJ FILTRUJEMY - Usuwamy Twoje (zalogowane) konto z listy
                        var filteredUsers = jsonResponse.users.filter(function(u) {
                            return u.email !== root.loggedUserEmail;
                        });

                        root.usersList = filteredUsers;
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

    function fetchLogs() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/api/logs");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    if (jsonResponse.status === "ok" && jsonResponse.logs) {
                        root.logsList = jsonResponse.logs;
                    }
                } catch(e) { console.error("Błąd parsowania logów:", e); }
            }
        }
        xhr.send();
    }

    // ==========================================
    // FUNKCJE API: TICKETY (RAPORTY)
    // ==========================================

    function fetchReports() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/api/reports");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    if (jsonResponse.status === "ok" && jsonResponse.reports) {
                        root.reportsList = jsonResponse.reports;
                    }
                } catch(e) { console.error("Błąd parsowania ticketów:", e); }
            }
        }
        xhr.send();
    }

    function closeTicket(ticketId) {
            var xhr = new XMLHttpRequest();
            xhr.open("DELETE", "http://localhost:8080/api/reports/" + encodeURIComponent(ticketId));
            xhr.setRequestHeader("Authorization", root.authToken);

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200 || xhr.status === 204) {
                        console.log("Ticket zamknięty pomyślnie.");
                        fetchReports(); // Odśwież listę, aby zniknął z ekranu
                    } else {
                        console.error("Błąd podczas zamykania ticketu:", xhr.responseText);
                    }
                }
            }
            xhr.send();
        }
}

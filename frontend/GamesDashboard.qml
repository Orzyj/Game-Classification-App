import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQml

Rectangle {
    id: root
    color: "#e9ecef"

    property string authToken: ""
    property string loggedUserEmail: ""
    property var gamesList: []
    property var developersList: []
    property var platformsList: [] // <-- NOWE: Lista platform
    property string gameTitle: ""
    property string fileUrl: ""
    property bool isImageLoaded: false

    FileDialog {
        id: fileDialog
        onAccepted: root.fileUrl = selectedFile
    }

    Drawer {
        id: toolsDrawer
        width: 1800
        height: root.height
        edge: Qt.LeftEdge

        ScrollView {
            anchors.fill: parent
            clip: true
            padding: 10

            ColumnLayout {
                spacing: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 15

                // ==========================================
                // SEKCJA DODAWANIA NOWEJ GRY
                // ==========================================
                Rectangle {
                    id: addGameContainer
                    Layout.fillWidth: true
                    property bool isExpanded: false
                    Layout.preferredHeight: isExpanded ? addGameContent.implicitHeight + 80 : 80
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                    color: "white"
                    radius: 8
                    border.color: "#cdd1d5"
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 15; spacing: 15

                        RowLayout {
                            Layout.fillWidth: true
                            Label { text: addGameContainer.isExpanded ? "➖ Zwiń panel dodawania" : "➕ Dodaj nową grę do bazy"; font.bold: true; font.pixelSize: 16; color: "#212529"; Layout.fillWidth: true }
                            Button {
                                text: addGameContainer.isExpanded ? "Ukryj" : "Rozwiń formularz"
                                background: Rectangle { color: "#e2e6ea"; radius: 5 }
                                onClicked: {
                                    addGameContainer.isExpanded = !addGameContainer.isExpanded;
                                    if (addGameContainer.isExpanded) { addDevContainer.isExpanded = false; addPlatformContainer.isExpanded = false; }
                                }
                            }
                        }

                        ColumnLayout {
                            id: addGameContent
                            Layout.fillWidth: true
                            spacing: 15
                            visible: addGameContainer.isExpanded

                            Label { text: "Podstawowe informacje:"; font.bold: true; color: "#495057" }
                            GridLayout {
                                columns: 4
                                Layout.fillWidth: true
                                columnSpacing: 10

                                TextField { id: inputTitle; placeholderText: "* Tytuł gry"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }

                                ComboBox {
                                    id: inputDev
                                    Layout.fillWidth: true
                                    model: ["Wybierz dewelopera..."]
                                    background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 }
                                }

                                // <-- NOWE: Wybór platformy przy dodawaniu gry
                                ComboBox {
                                    id: inputPlatform
                                    Layout.fillWidth: true
                                    model: ["Wybierz platformę..."]
                                    background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 }
                                }

                                TextField { id: inputYear; placeholderText: "Rok (np. 2024)"; validator: IntValidator {bottom: 1950; top: 2100} Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6" }

                            Label { text: "Klasyfikacja (Gatunki i Trudność):"; font.bold: true; color: "#495057" }
                            GridLayout {
                                columns: 4
                                Layout.fillWidth: true
                                columnSpacing: 10
                                TextField { id: inputGenre; placeholderText: "Gatunek (np. RPG)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                TextField { id: inputSubgenre; placeholderText: "Podgatunek (np. Action)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                TextField { id: inputTheme; placeholderText: "Motyw (np. Fantasy)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                ComboBox {
                                    id: inputDifficulty
                                    model: ["Easy", "Medium", "Hard", "Very Hard", "Nightmare"]
                                    currentIndex: 1
                                    Layout.fillWidth: true
                                    background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 }
                                }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6" }

                            Label { text: "Statystyki techniczne:"; font.bold: true; color: "#495057" }
                            GridLayout {
                                columns: 2
                                Layout.fillWidth: true
                                columnSpacing: 10
                                TextField { id: inputEngine; placeholderText: "Silnik (np. Unreal Engine 5)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                TextField { id: inputPlaytime; placeholderText: "Średni czas gry (godziny)"; validator: IntValidator {bottom: 0; top: 1000} Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 10
                                Label { id: addStatusLabelImage; text: "Brak zdjęcia"; color: "#198754"; font.bold: true; Layout.fillWidth: true }
                                Button {
                                    text: "Dodaj zdjęcie"
                                    onClicked: {
                                        fileDialog.open();
                                        addStatusLabelImage.text = "Wybrano plik do wgrania";
                                        root.isImageLoaded = true;
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 10
                                Label { id: addStatusLabel; text: ""; color: "#198754"; font.bold: true; Layout.fillWidth: true }
                                Button {
                                    text: "Dodaj Grę do Bazy"
                                    background: Rectangle { color: "#198754"; radius: 5 }
                                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: addNewGame()
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // SEKCJA ZARZĄDZANIA DEWELOPERAMI
                // ==========================================
                Rectangle {
                    id: addDevContainer
                    Layout.fillWidth: true
                    property bool isExpanded: false
                    Layout.preferredHeight: isExpanded ? addDevContent.implicitHeight + 80 : 80
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                    color: "white"; radius: 8; border.color: "#cdd1d5"; border.width: 1; clip: true

                    ColumnLayout {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 15; spacing: 15

                        RowLayout {
                            Layout.fillWidth: true
                            Label { text: addDevContainer.isExpanded ? "➖ Zwiń panel deweloperów" : "💼 Zarządzaj deweloperami (Studia)"; font.bold: true; font.pixelSize: 16; color: "#212529"; Layout.fillWidth: true }
                            Button {
                                text: addDevContainer.isExpanded ? "Ukryj" : "Rozwiń formularz"
                                background: Rectangle { color: "#e2e6ea"; radius: 5 }
                                onClicked: {
                                    addDevContainer.isExpanded = !addDevContainer.isExpanded;
                                    if (addDevContainer.isExpanded) { addGameContainer.isExpanded = false; addPlatformContainer.isExpanded = false; }
                                }
                            }
                        }

                        ColumnLayout {
                            id: addDevContent
                            Layout.fillWidth: true; spacing: 15; visible: addDevContainer.isExpanded

                            Label { text: "Dodaj nowe studio do bazy:"; font.bold: true; color: "#495057" }

                            GridLayout {
                                columns: 3; Layout.fillWidth: true; columnSpacing: 10
                                TextField { id: inputDevName; placeholderText: "* Nazwa studia (np. CD Projekt Red)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                TextField { id: inputDevCountry; placeholderText: "Kraj (np. Polska)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                TextField { id: inputDevYear; placeholderText: "Rok założenia (np. 1994)"; validator: IntValidator {bottom: 1950; top: 2026} Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                            }

                            RowLayout {
                                Layout.fillWidth: true; Layout.topMargin: 10
                                Label { id: addDevStatusLabel; text: ""; color: "#198754"; font.bold: true; Layout.fillWidth: true }
                                Button {
                                    text: "Dodaj Dewelopera"
                                    background: Rectangle { color: "#0d6efd"; radius: 5 }
                                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: addNewDeveloper()
                                }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6"; Layout.topMargin: 10; Layout.bottomMargin: 10 }
                            Label { text: "Lista zapisanych deweloperów (Słownik):"; font.bold: true; color: "#495057" }

                            Flow {
                                Layout.fillWidth: true; spacing: 10
                                Repeater {
                                    model: root.developersList
                                    delegate: Rectangle {
                                        required property var modelData
                                        property var dev: modelData

                                        color: "#e9ecef"; border.color: "#ced4da"; border.width: 1; radius: 15; width: devTxt.width + 24; height: 28
                                        Text { id: devTxt; text: "🏢 " + dev.name + " (" + dev.country + ")"; anchors.centerIn: parent; font.pixelSize: 13; color: "#495057"; font.bold: true }
                                    }
                                }
                            }
                            Button { text: "Odśwież listę studiów"; flat: true; onClicked: fetchDevelopers() }
                        }
                    }
                }

                // ==========================================
                // NOWE: SEKCJA ZARZĄDZANIA PLATFORMAMI
                // ==========================================
                Rectangle {
                    id: addPlatformContainer
                    Layout.fillWidth: true
                    property bool isExpanded: false
                    Layout.preferredHeight: isExpanded ? addPlatformContent.implicitHeight + 80 : 80
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                    color: "white"; radius: 8; border.color: "#cdd1d5"; border.width: 1; clip: true

                    ColumnLayout {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 15; spacing: 15

                        RowLayout {
                            Layout.fillWidth: true
                            Label { text: addPlatformContainer.isExpanded ? "➖ Zwiń panel platform" : "🎮 Zarządzaj platformami (Konsole / PC)"; font.bold: true; font.pixelSize: 16; color: "#212529"; Layout.fillWidth: true }
                            Button {
                                text: addPlatformContainer.isExpanded ? "Ukryj" : "Rozwiń formularz"
                                background: Rectangle { color: "#e2e6ea"; radius: 5 }
                                onClicked: {
                                    addPlatformContainer.isExpanded = !addPlatformContainer.isExpanded;
                                    if (addPlatformContainer.isExpanded) { addGameContainer.isExpanded = false; addDevContainer.isExpanded = false; }
                                }
                            }
                        }

                        ColumnLayout {
                            id: addPlatformContent
                            Layout.fillWidth: true; spacing: 15; visible: addPlatformContainer.isExpanded

                            Label { text: "Dodaj nową platformę do bazy:"; font.bold: true; color: "#495057" }

                            GridLayout {
                                columns: 3; Layout.fillWidth: true; columnSpacing: 10
                                TextField { id: inputPlatformName; placeholderText: "* Nazwa platformy (np. PlayStation 5)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                TextField { id: inputPlatformManufacturer; placeholderText: "Producent (np. Sony)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                                TextField { id: inputPlatformYear; placeholderText: "Rok premiery (np. 2020)"; validator: IntValidator {bottom: 1950; top: 2026} Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                            }

                            RowLayout {
                                Layout.fillWidth: true; Layout.topMargin: 10
                                Label { id: addPlatformStatusLabel; text: ""; color: "#198754"; font.bold: true; Layout.fillWidth: true }
                                Button {
                                    text: "Dodaj Platformę"
                                    background: Rectangle { color: "#0d6efd"; radius: 5 }
                                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: addNewPlatform()
                                }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6"; Layout.topMargin: 10; Layout.bottomMargin: 10 }
                            Label { text: "Lista zapisanych platform (Słownik):"; font.bold: true; color: "#495057" }

                            Flow {
                                Layout.fillWidth: true; spacing: 10
                                Repeater {
                                    model: root.platformsList
                                    delegate: Rectangle {
                                        required property var modelData
                                        property var plat: modelData

                                        color: "#e9ecef"; border.color: "#ced4da"; border.width: 1; radius: 15; width: platTxt.width + 24; height: 28
                                        Text { id: platTxt; text: "🕹️ " + plat.name + " (" + plat.manufacturer + ")"; anchors.centerIn: parent; font.pixelSize: 13; color: "#495057"; font.bold: true }
                                    }
                                }
                            }
                            Button { text: "Odśwież listę platform"; flat: true; onClicked: fetchPlatforms() }
                        }
                    }
                }

            }
        }
    }


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // ==========================================
        // PASEK NAWIGACJI
        // ==========================================

        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "white"
            radius: 8
            border.color: "#cdd1d5"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                Label {
                    text: "Zalogowany: " + root.loggedUserEmail
                    font.bold: true
                    font.pixelSize: 16
                    color: "#212529"
                    Layout.fillWidth: true
                }

                Button {
                    text: "Odśwież wszystko" // Zmieniono na odświeżanie wszystkiego
                    flat: true
                    onClicked: {
                        fetchGames()
                        fetchDevelopers()
                        fetchPlatforms()
                    }
                }

                Button {
                    text: "Usuń konto"
                    background: Rectangle { color: "transparent"; border.color: "#dc3545"; border.width: 2; radius: 5 }
                    contentItem: Text { text: parent.text; color: "#dc3545"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: deleteAccountPopup.open()
                }

                Button {
                    text: "Wyloguj się"
                    background: Rectangle { color: "#6c757d"; radius: 5 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: stackView.pop()
                }
            }
        }

        // ==========================================
        // SEKCJA FILTROWANIA + LIMIT
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            height: filterLayout.implicitHeight + 40
            color: "white"
            radius: 8
            border.color: "#cdd1d5"
            border.width: 1

            RowLayout {
                id: filterLayout
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Label { text: "Filtruj:"; font.bold: true; color: "#495057" }

                TextField { id: filterGenre; placeholderText: "Gatunek (np. RPG)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } onAccepted: fetchGames() }
                TextField { id: filterTitle; placeholderText: "Tytuł gry"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } onAccepted: fetchGames() }
                TextField { id: filterTheme; placeholderText: "Motyw (np. Dark Fantasy)"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } onAccepted: fetchGames() }

                Label { text: "Pokaż:"; font.bold: true; color: "#495057"; Layout.leftMargin: 10 }

                ComboBox {
                    id: limitCombo
                    model: [5, 10, 20, 30, 40, 50, 100]
                    currentIndex: 1
                    Layout.preferredWidth: 80
                    background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 }
                    onActivated: fetchGames()
                }

                Button { text: "Szukaj"; background: Rectangle { color: "#0d6efd"; radius: 5 } contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } onClicked: fetchGames() }

                Button {
                    text: "Wyczyść"
                    background: Rectangle { color: "transparent"; border.color: "#6c757d"; radius: 5 }
                    contentItem: Text { text: parent.text; color: "#6c757d"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        filterGenre.text = ""
                        filterTheme.text = ""
                        filterTitle.text = ""
                        limitCombo.currentIndex = 1
                        fetchGames()
                    }
                }
            }
        }

        Button {
            text: "☰ Otwórz menu i filtry"
            font.bold: true
            font.pixelSize: 16
            background: Rectangle { color: "#0d6efd"; radius: 5 }
            contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: toolsDrawer.open()
        }



        Label {
            id: statusLabel
            text: "Pobieranie gier..."
            color: "#6c757d"
            font.italic: true
            font.bold: true
            visible: root.gamesList.length === 0
            Layout.alignment: Qt.AlignHCenter
        }

        // ==========================================
        // FEED GIER
        // ==========================================
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 25
            model: root.gamesList

            onContentYChanged: {
                if (contentY > 50) {
                    if (addGameContainer.isExpanded) addGameContainer.isExpanded = false;
                    if (addDevContainer.isExpanded) addDevContainer.isExpanded = false;
                    if (addPlatformContainer.isExpanded) addPlatformContainer.isExpanded = false; // <-- Zamykanie platform
                }
            }

            delegate: Rectangle {
                width: listView.width
                height: Math.max(250, postRow.implicitHeight + 30)
                color: "white"; radius: 12; border.color: "#cdd1d5"; border.width: 1

                required property var modelData
                property var game: modelData

                RowLayout {
                    id: postRow
                    anchors.fill: parent; anchors.margins: 15; spacing: 20

                    Image {
                        Layout.preferredWidth: 220; Layout.preferredHeight: 300
                        source: game.image_url; fillMode: Image.PreserveAspectCrop; visible: game.image_url !== ""; clip: true
                        Rectangle {
                            anchors.fill: parent; color: "#f8f9fa"; visible: parent.status === Image.Loading
                            Label { text: "Ładowanie obrazka..."; anchors.centerIn: parent; color: "#6c757d" }
                        }
                    }

                    ColumnLayout {
                        id: rightColumn
                        Layout.fillWidth: true; Layout.fillHeight: true; Layout.alignment: Qt.AlignTop; spacing: 10

                        ColumnLayout {
                            spacing: 5; Layout.fillWidth: true
                            Label { text: game.title; font.bold: true; font.pixelSize: 24; color: "#212529"; Layout.fillWidth: true; wrapMode: Text.Wrap }
                            // <-- Możesz opcjonalnie wyświetlić tu platformę, dodałem ją jeśli backend ją zapisze
                            Label { text: game.developer + " • " + game.release_year + (game.platform !== undefined && game.platform !== "" ? " • " + game.platform : ""); font.pixelSize: 15; color: "#6c757d"; font.bold: true }
                        }

                        Flow {
                            Layout.fillWidth: true; spacing: 10
                            Rectangle { color: "#e9ecef"; border.color: "#ced4da"; border.width: 1; radius: 15; width: genreTxt.width + 24; height: 28; Text { id: genreTxt; text: "🎭 " + game.genre; anchors.centerIn: parent; font.pixelSize: 13; color: "#495057"; font.bold: true } }
                            Rectangle { color: "#e9ecef"; border.color: "#ced4da"; border.width: 1; radius: 15; width: themeTxt.width + 24; height: 28; Text { id: themeTxt; text: "🎨 " + game.theme; anchors.centerIn: parent; font.pixelSize: 13; color: "#495057"; font.bold: true } }
                            Rectangle { color: "#e9ecef"; border.color: "#ced4da"; border.width: 1; radius: 15; width: engTxt.width + 24; height: 28; Text { id: engTxt; text: "⚙️ " + game.engine; anchors.centerIn: parent; font.pixelSize: 13; color: "#495057"; font.bold: true } }
                            Rectangle { color: "#f8d7da"; border.color: "#f5c2c7"; border.width: 1; radius: 15; width: diffTxt.width + 24; height: 28; Text { id: diffTxt; text: "🔥 " + game.difficulty; anchors.centerIn: parent; font.pixelSize: 13; color: "#842029"; font.bold: true } }

                            Rectangle {
                                color: mouseAreaUp.containsMouse ? "#e2e3e5" : "#f8d7da"; border.color: "#f5c2c7"; border.width: 1; radius: 15; width: ratingUp.width + 24; height: 28
                                Text { id: ratingUp; text: "👍 " + game.rating_up; anchors.centerIn: parent; font.pixelSize: 13; color: "#842029"; font.bold: true }
                                MouseArea { id: mouseAreaUp; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sendRating(game.title, "up") }
                            }
                            Rectangle {
                                color: mouseAreaDown.containsMouse ? "#e2e3e5" : "#f8d7da"; border.color: "#f5c2c7"; border.width: 1; radius: 15; width: ratingDown.width + 24; height: 28
                                Text { id: ratingDown; text: "👎 " + game.rating_down; anchors.centerIn: parent; font.pixelSize: 13; color: "#842029"; font.bold: true }
                                MouseArea { id: mouseAreaDown; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sendRating(game.title, "down") }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; height: 2; color: "#e9ecef"; Layout.topMargin: 5; Layout.bottomMargin: 5 }

                        Label { text: "Komentarze (" + game.comments.length + ")"; font.bold: true; font.pixelSize: 16; color: "#495057" }

                        Repeater {
                            model: game.comments
                            delegate: ColumnLayout {
                                spacing: 4; Layout.fillWidth: true; Layout.bottomMargin: 10
                                required property var modelData; property var comment: modelData
                                Label { text: comment.author_name + " • " + comment.date; font.bold: true; font.pixelSize: 13; color: "#212529" }
                                Rectangle {
                                    Layout.fillWidth: true; height: commentText.implicitHeight + 20; color: "#f8f9fa"; border.color: "#dee2e6"; border.width: 1; radius: 8
                                    Label { id: commentText; text: comment.content; anchors.fill: parent; anchors.margins: 10; wrapMode: Text.Wrap; font.pixelSize: 14; color: "#343a40" }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true; Layout.topMargin: 5
                            TextField { id: commentInput; placeholderText: "Napisz komentarz..."; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 20 } leftPadding: 15 }
                            Button { text: "Wyślij"; background: Rectangle { color: "#0d6efd"; radius: 20 } contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } onClicked: { if(commentInput.text !== "") { sendComment(game.title, commentInput.text, commentInput); } } }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: deleteAccountPopup
        width: 320; height: 180; anchors.centerIn: parent; modal: true; focus: true; closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        Rectangle {
            anchors.fill: parent; color: "white"; radius: 10; border.color: "#dc3545"; border.width: 2
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 15
                Label { text: "Czy na pewno chcesz usunąć swoje konto?"; font.bold: true; font.pixelSize: 16; color: "#212529"; Layout.fillWidth: true; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter }
                Label { text: "Tej operacji nie można cofnąć."; color: "#dc3545"; font.bold: true; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 15
                    Button { text: "Anuluj"; background: Rectangle { color: "#e2e6ea"; radius: 5 } onClicked: deleteAccountPopup.close() }
                    Button { text: "Tak, usuń"; background: Rectangle { color: "#dc3545"; radius: 5 } contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } onClicked: deleteMyAccount() }
                }
            }
        }
    }

    Component.onCompleted: {
        fetchGames();
        fetchDevelopers();
        fetchPlatforms(); // <-- Automatyczne pobieranie na starcie
    }

    // ==========================================
    // FUNKCJE API
    // ==========================================

    function fetchGames() {
        statusLabel.text = "Odświeżanie..."; statusLabel.visible = true;
        var xhr = new XMLHttpRequest();
        var url = "http://localhost:8080/api/games?";
        var params = [];

        if (filterGenre.text !== "") params.push("genre=" + encodeURIComponent(filterGenre.text.trim()));
        if (filterTheme.text !== "") params.push("theme=" + encodeURIComponent(filterTheme.text.trim()));
        if (filterTitle.text !== "") params.push("title="+ encodeURIComponent(filterTitle.text.trim()));

        var currentLimit = limitCombo.currentValue;
        if (currentLimit) params.push("limit=" + currentLimit);
        url += params.join("&");

        xhr.open("GET", url);
        xhr.setRequestHeader("Authorization", root.authToken);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var jsonResponse = JSON.parse(xhr.responseText);
                        if (jsonResponse.status === "ok" && jsonResponse.games) {
                            var flatGames = jsonResponse.games.map(function(game) {
                                return {
                                    title: game.title,
                                    developer: game.developer,
                                    platform: game.platform ? game.platform : "", // <-- Obsługa nowej właściwości w mapowaniu
                                    release_year: game.release_year,
                                    genre: game.classification ? game.classification.genre : "Brak",
                                    theme: game.classification ? game.classification.theme : "Brak",
                                    difficulty: game.classification ? game.classification.difficulty : "Brak",
                                    engine: game.technical_stats ? game.technical_stats.engine : "Brak",
                                    comments: game.comments ? game.comments : [],
                                    image_url: game.image_url ? ("http://localhost:8080" + game.image_url + "?t=" + Date.now()) : "",
                                    rating_up: game.rating_up !== undefined ? game.rating_up : 0,
                                    rating_down: game.rating_down !== undefined ? game.rating_down : 0
                                };
                            });
                            root.gamesList = flatGames;
                            statusLabel.visible = root.gamesList.length === 0;
                            statusLabel.text = "Brak gier spełniających kryteria.";
                        }
                    } catch(e) {
                        statusLabel.text = "Błąd parsowania danych."; statusLabel.visible = true;
                    }
                } else {
                    statusLabel.text = "Błąd pobierania. Status: " + xhr.status;
                }
            }
        };
        xhr.send();
    }

    function addNewGame() {
        if(inputTitle.text === "" || inputDev.currentIndex === 0 || inputPlatform.currentIndex === 0) {
            addStatusLabel.text = "Tytuł, Deweloper i Platforma są wymagane!";
            addStatusLabel.color = "#dc3545";
            return;
        }

        var titleToUpload = inputTitle.text;
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/addgames");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 201) {
                    addStatusLabel.text = "Gra dodana pomyślnie!";
                    addStatusLabel.color = "#198754";

                    if(root.isImageLoaded) {
                        imageUploader.uploadImage(titleToUpload, root.fileUrl, root.authToken);
                        root.isImageLoaded = false;
                        root.fileUrl = "";
                        addStatusLabelImage.text = "Brak zdjęcia";
                    }

                    inputTitle.text = ""; inputDev.currentIndex = 0; inputPlatform.currentIndex = 0;
                    inputYear.text = ""; inputGenre.text = ""; inputSubgenre.text = ""; inputTheme.text = "";
                    inputEngine.text = ""; inputPlaytime.text = ""; inputDifficulty.currentIndex = 1;
                } else {
                    addStatusLabel.text = "Błąd: " + xhr.responseText;
                    addStatusLabel.color = "#dc3545";
                }
            }
        };

        var payload = {
            "title": inputTitle.text,
            "developer": inputDev.currentText,
            "platform": inputPlatform.currentText, // <-- Nowe pole dodane do payloadu
            "release_year": inputYear.text !== "" ? parseInt(inputYear.text) : 2024,
            "classification": {
                "genre": inputGenre.text || "Brak",
                "subgenre": inputSubgenre.text || "Brak",
                "theme": inputTheme.text || "Brak",
                "difficulty": inputDifficulty.currentText
            },
            "technical_stats": {
                "engine": inputEngine.text || "Brak",
                "average_playtime_hours": inputPlaytime.text !== "" ? parseInt(inputPlaytime.text) : 0
            },
            "comments": []
        };
        xhr.send(JSON.stringify(payload));
        fetchGames();
    }

    function sendComment(gameTitle, content, inputFieldReference) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/games/" + encodeURIComponent(gameTitle) + "/comments");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 201) {
                    inputFieldReference.text = ""; fetchGames();
                } else { console.error("Błąd dodawania komentarza:", xhr.responseText); }
            }
        };
        xhr.send(JSON.stringify({ "content": content }));
    }

    function deleteMyAccount() {
        var xhr = new XMLHttpRequest();
        xhr.open("DELETE", "http://localhost:8080/api/users/" + encodeURIComponent(root.loggedUserEmail));
        xhr.setRequestHeader("Authorization", root.authToken);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 204) { deleteAccountPopup.close(); stackView.pop(); }
                else { console.error("Błąd usuwania konta:", xhr.responseText); }
            }
        };
        xhr.send();
    }

    function sendRating(gameTitle, voteType) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/games/" + encodeURIComponent(gameTitle) + "/rating");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) { fetchGames(); } else { console.warn("Błąd głosowania:", xhr.responseText); }
            }
        };
        xhr.send(JSON.stringify({ "email": root.loggedUserEmail, "vote": voteType }));
    }

    // --- DEWELOPERZY ---
    function fetchDevelopers() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/api/developers");
        xhr.setRequestHeader("Authorization", root.authToken);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    if (jsonResponse.status === "ok" && jsonResponse.developers) {
                        root.developersList = jsonResponse.developers;
                        var devNames = ["Wybierz dewelopera..."];
                        for (var i = 0; i < jsonResponse.developers.length; i++) { devNames.push(jsonResponse.developers[i].name); }
                        inputDev.model = devNames;
                    }
                } catch(e) {}
            }
        };
        xhr.send();
    }

    function addNewDeveloper() {
        if(inputDevName.text === "") { addDevStatusLabel.text = "Nazwa studia jest wymagana!"; addDevStatusLabel.color = "#dc3545"; return; }
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/developers");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 201) {
                    addDevStatusLabel.text = "Deweloper dodany pomyślnie!"; addDevStatusLabel.color = "#198754";
                    inputDevName.text = ""; inputDevCountry.text = ""; inputDevYear.text = "";
                    fetchDevelopers();
                } else { addDevStatusLabel.text = "Błąd: " + xhr.responseText; addDevStatusLabel.color = "#dc3545"; }
            }
        };
        xhr.send(JSON.stringify({
            "name": inputDevName.text, "country": inputDevCountry.text !== "" ? inputDevCountry.text : "Nieznany", "founded_year": inputDevYear.text !== "" ? parseInt(inputDevYear.text) : 2000
        }));
    }

    // --- NOWE: FUNKCJE DLA PLATFORM ---
    function fetchPlatforms() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/api/platforms");
        xhr.setRequestHeader("Authorization", root.authToken);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    if (jsonResponse.status === "ok" && jsonResponse.platforms) {
                        root.platformsList = jsonResponse.platforms;

                        var platNames = ["Wybierz platformę..."];
                        for (var i = 0; i < jsonResponse.platforms.length; i++) {
                            platNames.push(jsonResponse.platforms[i].name);
                        }
                        inputPlatform.model = platNames; // Aktualizuj model ComboBoxa
                    }
                } catch(e) {
                    console.error("Błąd parsowania listy platform.");
                }
            }
        };
        xhr.send();
    }

    function addNewPlatform() {
        if(inputPlatformName.text === "") {
            addPlatformStatusLabel.text = "Nazwa platformy jest wymagana!";
            addPlatformStatusLabel.color = "#dc3545";
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/platforms");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 201) {
                    addPlatformStatusLabel.text = "Platforma dodana pomyślnie!";
                    addPlatformStatusLabel.color = "#198754";

                    inputPlatformName.text = "";
                    inputPlatformManufacturer.text = "";
                    inputPlatformYear.text = "";

                    fetchPlatforms();
                } else {
                    addPlatformStatusLabel.text = "Błąd: " + xhr.responseText;
                    addPlatformStatusLabel.color = "#dc3545";
                }
            }
        };

        var payload = {
            "name": inputPlatformName.text,
            "manufacturer": inputPlatformManufacturer.text !== "" ? inputPlatformManufacturer.text : "Nieznany",
            "release_year": inputPlatformYear.text !== "" ? parseInt(inputPlatformYear.text) : 2000
        };

        xhr.send(JSON.stringify(payload));
    }
}

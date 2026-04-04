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

    // --- ZMIENNA: Status Moderatora ---
    property bool isUserMod: false

    property string editingGameTitle: ""

    property var gamesList: []
    property var developersList: []
    property var platformsList: []
    property var premieresList: []
    property string gameTitle: ""
    property string fileUrl: ""
    property bool isImageLoaded: false

    FileDialog {
        id: fileDialog
        onAccepted: root.fileUrl = selectedFile
    }

    Drawer {
        id: toolsDrawer
        width: 900
        height: root.height
        edge: Qt.LeftEdge
        // Blokada wysunięcia palcem dla zwykłych użytkowników
        interactive: root.isUserMod

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
                                    Layout.preferredHeight: 40
                                    model: ["Wybierz dewelopera..."]
                                    background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 }
                                }

                                ComboBox {
                                    id: inputPlatform
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
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
                                    Layout.preferredHeight: 40
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
                        }
                    }
                }

                // ==========================================
                // SEKCJA ZARZĄDZANIA PLATFORMAMI
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
                    text: "Zalogowany: " + (root.isUserMod ? "[MOD] " : "") + root.loggedUserEmail
                    font.bold: true
                    font.pixelSize: 16
                    color: root.isUserMod ? "#dc3545" : "#212529"
                    Layout.fillWidth: true
                }

                Button {
                    text: "Odśwież wszystko"
                    flat: true
                    onClicked: {
                        fetchGames()
                        fetchDevelopers()
                        fetchPlatforms()
                        fetchPremieres()
                    }
                }

                Button {
                    text: "🚨 Zgłoś problem"
                    background: Rectangle { color: "#ffc107"; radius: 5 }
                    contentItem: Text { text: parent.text; color: "#212529"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: reportPopup.open()
                }

                Button {
                    text: "Dezaktywuj konto"
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
        // TAB BAR (ZAKŁADKI)
        // ==========================================
        TabBar {
            id: mainTabs
            Layout.fillWidth: true
            background: Rectangle { color: "transparent" }

            TabButton {
                text: "🎮 Lista Gier"
                font.bold: true
                background: Rectangle {
                    color: mainTabs.currentIndex === 0 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: mainTabs.currentIndex === 0 ? "#0d6efd" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TabButton {
                text: "🏢 Platformy i Studia"
                font.bold: true
                background: Rectangle {
                    color: mainTabs.currentIndex === 1 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: mainTabs.currentIndex === 1 ? "#0d6efd" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TabButton {
                text: "📅 Zapowiedzi i Premiery"
                font.bold: true
                background: Rectangle {
                    color: mainTabs.currentIndex === 2 ? "white" : "#e9ecef"
                    border.color: "#dee2e6"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: mainTabs.currentIndex === 2 ? "#0d6efd" : "#495057"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // ==========================================
        // ZAKŁADKA 1: GRY (FILTROWANIE + LISTA)
        // ==========================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 15
            visible: mainTabs.currentIndex === 0

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
                        Layout.preferredHeight: 40
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

            // Przycisk otwierający menu dodawania - widoczny tylko dla modów
            Button {
                text: "☰ Otwórz menu dodawania gier/słowników"
                font.bold: true
                font.pixelSize: 16
                visible: root.isUserMod
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
                        if (addPlatformContainer.isExpanded) addPlatformContainer.isExpanded = false;
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

                            // NAGŁÓWEK GRY I PRZYCISKI MODA
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    spacing: 5; Layout.fillWidth: true
                                    Label { text: game.title; font.bold: true; font.pixelSize: 24; color: "#212529"; Layout.fillWidth: true; wrapMode: Text.Wrap }
                                    Label { text: game.developer + " • " + game.release_year + (game.platform !== undefined && game.platform !== "" ? " • " + game.platform : ""); font.pixelSize: 15; color: "#6c757d"; font.bold: true }
                                }

                                // PRZYCISKI DO EDYCJI I USUWANIA (TYLKO DLA MODÓW)
                                Button {
                                    text: "✏️ Edytuj"
                                    visible: root.isUserMod
                                    background: Rectangle { color: "#e9ecef"; radius: 5; border.color: "#ced4da"; border.width: 1 }
                                    contentItem: Text { text: parent.text; color: "#495057"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: openEditPopup(game)
                                }
                                Button {
                                    text: "🗑️ Usuń"
                                    visible: root.isUserMod
                                    background: Rectangle { color: "#f8d7da"; radius: 5; border.color: "#dc3545"; border.width: 1 }
                                    contentItem: Text { text: parent.text; color: "#dc3545"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: deleteGame(game.title)
                                }
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

                            // REPEATER DO EDYCJI KOMENTARZY ORAZ WYSZARZANIA (isAuthorEnabled)
                            Repeater {
                                model: game.comments
                                delegate: ColumnLayout {
                                    id: commentDelegate
                                    spacing: 4; Layout.fillWidth: true; Layout.bottomMargin: 10

                                    required property var modelData
                                    required property int index
                                    property var comment: modelData

                                    property bool isAuthorEnabled: comment.author_is_enabled !== false
                                    property bool isEditing: false

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Label {
                                            text: (isAuthorEnabled ? comment.author_name : comment.author_name + " (Konto Wyłączone)") + " • " + comment.date;
                                            font.bold: true;
                                            font.pixelSize: 13;
                                            color: isAuthorEnabled ? "#212529" : "#adb5bd";
                                            Layout.fillWidth: true
                                        }

                                        Button {
                                            text: commentDelegate.isEditing ? "Anuluj" : "✏️ Edytuj"
                                            visible: comment.author_name === root.loggedUserEmail && isAuthorEnabled
                                            background: Rectangle { color: "transparent"; radius: 5 }
                                            contentItem: Text { text: parent.text; color: "#0d6efd"; font.bold: true; horizontalAlignment: Text.AlignRight }
                                            onClicked: {
                                                commentDelegate.isEditing = !commentDelegate.isEditing;
                                                if (commentDelegate.isEditing) {
                                                    editCommentField.text = comment.content;
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: commentDelegate.isEditing ? editRow.implicitHeight + 20 : commentText.implicitHeight + 20
                                        color: "#f8f9fa"; border.color: "#dee2e6"; border.width: 1; radius: 8

                                        Label {
                                            id: commentText
                                            text: comment.content;
                                            anchors.fill: parent; anchors.margins: 10; wrapMode: Text.Wrap;
                                            font.pixelSize: 14;
                                            color: isAuthorEnabled ? "#343a40" : "#adb5bd"
                                            font.italic: !isAuthorEnabled
                                            visible: !commentDelegate.isEditing
                                        }

                                        RowLayout {
                                            id: editRow
                                            anchors.fill: parent; anchors.margins: 10
                                            visible: commentDelegate.isEditing

                                            TextField {
                                                id: editCommentField
                                                Layout.fillWidth: true
                                                background: Rectangle { color: "white"; border.color: "#ced4da"; radius: 4 }
                                            }

                                            Button {
                                                text: "Zapisz"
                                                background: Rectangle { color: "#28a745"; radius: 5 }
                                                contentItem: Text { text: parent.text; color: "white"; font.bold: true }
                                                onClicked: {
                                                    if(editCommentField.text.trim() !== "") {
                                                        updateCommentApi(game.title, index, editCommentField.text.trim());
                                                        commentDelegate.isEditing = false;
                                                    }
                                                }
                                            }
                                        }
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

        // ==========================================
        // ZAKŁADKA 2: PLATFORMY I DEWELOPERZY
        // ==========================================
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            columnSpacing: 20
            visible: mainTabs.currentIndex === 1

            // Lewa kolumna: Deweloperzy
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 8
                border.color: "#cdd1d5"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Label { text: "💼 Zapisani Deweloperzy"; font.bold: true; font.pixelSize: 18; color: "#212529" }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6" }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        Flow {
                            width: parent.width; spacing: 10
                            Repeater {
                                model: root.developersList
                                delegate: Rectangle {
                                    required property var modelData
                                    property var dev: modelData
                                    color: "#e9ecef"; border.color: "#ced4da"; border.width: 1; radius: 15; width: devLayout.implicitWidth + 24; height: 28

                                    RowLayout {
                                        id: devLayout
                                        anchors.centerIn: parent
                                        spacing: 5
                                        Text { text: "🏢 " + dev.name + " (" + dev.country + ")"; font.pixelSize: 13; color: "#495057"; font.bold: true }

                                        // Przycisk usunięcia widoczny tylko dla modów
                                        Rectangle {
                                            width: 16; height: 16; radius: 8; color: "#dc3545"
                                            visible: root.isUserMod
                                            Text { text: "✖"; color: "white"; font.pixelSize: 10; font.bold: true; anchors.centerIn: parent }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: deleteDeveloper(dev.name) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Button { text: "Odśwież deweloperów"; Layout.alignment: Qt.AlignHCenter; onClicked: fetchDevelopers() }
                }
            }

            // Prawa kolumna: Platformy
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 8
                border.color: "#cdd1d5"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Label { text: "🎮 Zapisane Platformy"; font.bold: true; font.pixelSize: 18; color: "#212529" }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6" }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        Flow {
                            width: parent.width; spacing: 10
                            Repeater {
                                model: root.platformsList
                                delegate: Rectangle {
                                    required property var modelData
                                    property var plat: modelData
                                    color: "#e9ecef"; border.color: "#ced4da"; border.width: 1; radius: 15; width: platLayout.implicitWidth + 24; height: 28

                                    RowLayout {
                                        id: platLayout
                                        anchors.centerIn: parent
                                        spacing: 5
                                        Text { text: "🕹️ " + plat.name + " (" + plat.manufacturer + ")"; font.pixelSize: 13; color: "#495057"; font.bold: true }

                                        // Przycisk usunięcia widoczny tylko dla modów
                                        Rectangle {
                                            width: 16; height: 16; radius: 8; color: "#dc3545"
                                            visible: root.isUserMod
                                            Text { text: "✖"; color: "white"; font.pixelSize: 10; font.bold: true; anchors.centerIn: parent }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: deletePlatform(plat.name) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Button { text: "Odśwież platformy"; Layout.alignment: Qt.AlignHCenter; onClicked: fetchPlatforms() }
                }
            }
        }

        // ==========================================
        // ZAKŁADKA 3: PREMIERY GIER
        // ==========================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 15
            visible: mainTabs.currentIndex === 2 // Pokazuje się tylko dla trzeciej zakładki

            Label {
                text: "Brak zaplanowanych premier."
                color: "#6c757d"
                font.italic: true
                font.bold: true
                visible: root.premieresList.length === 0
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
            }

            ListView {
                id: premieresListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 15
                model: root.premieresList

                delegate: Rectangle {
                    width: premieresListView.width
                    height: premiereLayout.implicitHeight + 30
                    color: "white"
                    radius: 8
                    border.color: "#cdd1d5"
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

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                color: "#ffc107"
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
                                color: "#0d6efd"
                            }

                            Label {
                                text: "🔥 Hype Score: " + premiere.hype_score + "/100"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#dc3545"
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // POP-UP EDYCJI GRY (TYLKO DLA MODÓW)
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
            anchors.fill: parent; color: "white"; radius: 12; border.color: "#ced4da"; border.width: 1

            ColumnLayout {
                id: editLayout
                anchors.fill: parent; anchors.margins: 25; spacing: 15

                Label { text: "Edycja Gry: " + root.editingGameTitle; font.bold: true; font.pixelSize: 20; color: "#212529" }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6"; Layout.bottomMargin: 10 }

                TextField { id: editDev; placeholderText: "Deweloper"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: editYear; placeholderText: "Rok wydania"; validator: IntValidator {bottom: 1950; top: 2100} Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }
                TextField { id: editGenre; placeholderText: "Gatunek"; Layout.fillWidth: true; background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 4 } }

                Label { id: editStatus; text: ""; color: "#dc3545"; font.bold: true }

                RowLayout {
                    Layout.alignment: Qt.AlignRight; Layout.topMargin: 10; spacing: 15
                    Button {
                        text: "Anuluj"
                        background: Rectangle { color: "#e9ecef"; radius: 5 }
                        contentItem: Text { text: parent.text; color: "#495057"; font.bold: true }
                        onClicked: editPopup.close()
                    }
                    Button {
                        text: "Zapisz Zmiany"
                        background: Rectangle { color: "#0d6efd"; radius: 5 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true }
                        onClicked: saveGameEdits()
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
                Label { text: "Czy na pewno chcesz zdezaktywować swoje konto?"; font.bold: true; font.pixelSize: 16; color: "#212529"; Layout.fillWidth: true; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter }
                Label { text: "Tej operacji nie można cofnąć."; color: "#dc3545"; font.bold: true; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 15
                    Button { text: "Anuluj"; background: Rectangle { color: "#e2e6ea"; radius: 5 } onClicked: deleteAccountPopup.close() }
                    Button { text: "Tak, dezaktywuj"; background: Rectangle { color: "#dc3545"; radius: 5 } contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } onClicked: toggleAccountStatus() }
                }
            }
        }
    }

    // ==========================================
    // NOWE: POP-UP ZGŁOSZEŃ (TICKETÓW)
    // ==========================================
    Popup {
        id: reportPopup
        width: 450; height: 350; anchors.centerIn: parent; modal: true; focus: true; closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        Rectangle {
            anchors.fill: parent; color: "white"; radius: 10; border.color: "#ffc107"; border.width: 2
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 15
                Label { text: "Napisz zgłoszenie (Ticket)"; font.bold: true; font.pixelSize: 18; color: "#212529"; Layout.fillWidth: true }
                Label { text: "Opisz swój problem lub sugestię. Zgłoszenie trafi do administracji."; color: "#495057"; Layout.fillWidth: true; wrapMode: Text.Wrap }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    TextArea {
                        id: reportInput
                        placeholderText: "Wpisz treść tutaj..."
                        wrapMode: Text.Wrap
                        background: Rectangle { color: "#f8f9fa"; border.color: "#ced4da"; radius: 5 }
                    }
                }

                Label { id: reportStatus; text: ""; color: "#dc3545"; font.bold: true; Layout.fillWidth: true; wrapMode: Text.Wrap }

                RowLayout {
                    Layout.alignment: Qt.AlignRight; spacing: 15
                    Button {
                        text: "Anuluj";
                        background: Rectangle { color: "#e2e6ea"; radius: 5 }
                        onClicked: { reportPopup.close(); reportInput.text = ""; reportStatus.text = ""; }
                    }
                    Button {
                        text: "Wyślij zgłoszenie";
                        background: Rectangle { color: "#0d6efd"; radius: 5 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: sendReport()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        fetchGames();
        fetchDevelopers();
        fetchPlatforms();
        fetchPremieres();
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

    // --- FUNKCJE DLA PREMIER ---
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

    function deleteDeveloper(devName) {
            var xhr = new XMLHttpRequest();
            xhr.open("DELETE", "http://localhost:8080/api/developers/" + encodeURIComponent(devName));
            xhr.setRequestHeader("Authorization", root.authToken);

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200 || xhr.status === 204) {
                        fetchDevelopers();
                    } else {
                        console.error("Błąd usuwania dewelopera: " + xhr.responseText);
                    }
                }
            };
            xhr.send();
        }

        function deletePlatform(platName) {
            var xhr = new XMLHttpRequest();
            xhr.open("DELETE", "http://localhost:8080/api/platforms/" + encodeURIComponent(platName));
            xhr.setRequestHeader("Authorization", root.authToken);

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200 || xhr.status === 204) {
                        fetchPlatforms();
                    } else {
                        console.error("Błąd usuwania platformy: " + xhr.responseText);
                    }
                }
            };
            xhr.send();
        }

    function sendReport() {
        if (reportInput.text.trim() === "") {
            reportStatus.text = "Treść zgłoszenia nie może być pusta.";
            reportStatus.color = "#dc3545";
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/reports");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 201 || xhr.status === 200) {
                    reportPopup.close();
                    reportInput.text = "";
                    reportStatus.text = "";
                } else {
                    reportStatus.text = "Wystąpił błąd: " + xhr.responseText;
                    reportStatus.color = "#dc3545";
                }
            }
        };

        var payload = {
            "email_user": root.loggedUserEmail,
            "message": reportInput.text.trim()
        };

        xhr.send(JSON.stringify(payload));
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

        var currentLimit = limitCombo.currentText;
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
                                    platform: game.platform ? game.platform : "",
                                    release_year: game.release_year,
                                    genre: game.classification ? game.classification.genre : "Brak",
                                    theme: game.classification ? game.classification.theme : "Brak",
                                    difficulty: game.classification ? game.classification.difficulty : "Brak",
                                    engine: game.technical_stats ? game.technical_stats.engine : "Brak",
                                    average_playtime_hours: game.technical_stats ? game.technical_stats.average_playtime_hours : 0,

                                    // Pamiętamy o wyszarzaniu zablokowanych userów
                                    comments: game.comments ? game.comments.map(function(c) {
                                        return {
                                            author_name: c.author_name,
                                            content: c.content,
                                            date: c.date,
                                            author_is_enabled: c.author_is_enabled !== undefined ? c.author_is_enabled : true
                                        };
                                    }) : [],

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
                    fetchGames();
                } else {
                    addStatusLabel.text = "Błąd: " + xhr.responseText;
                    addStatusLabel.color = "#dc3545";
                }
            }
        };

        var payload = {
            "title": inputTitle.text,
            "developer": inputDev.currentText,
            "platform": inputPlatform.currentText,
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

    function updateCommentApi(gameTitle, commentIndex, newContent) {
        var xhr = new XMLHttpRequest();
        xhr.open("PATCH", "http://localhost:8080/api/games/" + encodeURIComponent(gameTitle) + "/comments/" + commentIndex);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("Komentarz zaktualizowany pomyślnie.");
                    fetchGames();
                } else {
                    console.error("Błąd edycji komentarza:", xhr.responseText);
                }
            }
        };

        xhr.send(JSON.stringify({ "content": newContent }));
    }

    function toggleAccountStatus() {
        var xhr = new XMLHttpRequest();
        var flagStr = false;

        xhr.open("PATCH", "http://localhost:8080/api/users/" + encodeURIComponent(root.loggedUserEmail) + "/status/" + flagStr);
        xhr.setRequestHeader("Authorization", root.authToken);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    deleteAccountPopup.close();
                    stackView.pop();
                } else {
                    console.error("Błąd podczas zmiany statusu konta:", xhr.responseText);
                }
            }
        }
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

    // --- NOWE FUNKCJE (DLA MODA) ---
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

    function openEditPopup(game) {
        root.editingGameTitle = game.title;
        editDev.text = game.developer;
        editYear.text = game.release_year.toString();
        editGenre.text = game.genre;
        editStatus.text = "";
        editPopup.open();
    }
}

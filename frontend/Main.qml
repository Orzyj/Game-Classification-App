import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    visible: true
    title: "Aplikacja z Grami"
    color: "#f0f2f5"
    visibility: Window.Maximized

    // Zmienne przechowujące nasz token i dane użytkownika po zalogowaniu
    property string authToken: ""
    property string loggedUserEmail: ""

    // StackView zarządza naszymi ekranami (pozwala przechodzić między widokami)
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginScreen // Ustawiamy ekran logowania jako początkowy
    }

    // ==========================================
    // EKRAN 1: Logowanie i Rejestracja
    // ==========================================
    Component {
        id: loginScreen

        Rectangle {
            id: loginRoot // BEZPIECZNE ID - rozwiązuje problem "non-existent property"
            color: "#f0f2f5"
            property bool isLoginMode: true

            Rectangle {
                width: 400
                height: mainLayout.implicitHeight + 40
                anchors.centerIn: parent
                color: "white"
                radius: 10
                border.color: "#dcdcdc"
                border.width: 1

                ColumnLayout {
                    id: mainLayout
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Label {
                        text: loginRoot.isLoginMode ? "Zaloguj się" : "Zarejestruj się"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 10
                    }

                    Label {
                        id: statusLabel
                        text: ""
                        color: "red"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                        visible: text !== ""
                    }

                    TextField {
                        id: nameField
                        placeholderText: "Imię"
                        Layout.fillWidth: true
                        visible: !loginRoot.isLoginMode // Ukryte podczas logowania
                    }

                    TextField {
                        id: emailField
                        placeholderText: "Adres e-mail"
                        Layout.fillWidth: true
                    }

                    TextField {
                        id: passwordField
                        placeholderText: "Hasło"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                    }

                    Button {
                        text: loginRoot.isLoginMode ? "Zaloguj" : "Zarejestruj"
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        onClicked: {
                            statusLabel.text = "";
                            if (loginRoot.isLoginMode) {
                                loginApi(emailField.text, passwordField.text, statusLabel);
                            } else {
                                registerApi(nameField.text, emailField.text, passwordField.text, statusLabel, loginRoot);
                            }
                        }
                    }

                    Button {
                        text: loginRoot.isLoginMode ? "Nie masz konta? Zarejestruj się" : "Masz już konto? Zaloguj się"
                        flat: true
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            loginRoot.isLoginMode = !loginRoot.isLoginMode;
                            statusLabel.text = ""; // Czyszczenie błędów przy zmianie trybu
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // EKRAN 2: Panel Użytkownika (Po zalogowaniu)
    // ==========================================
    Component {
        id: userDashboardScreen

        Rectangle {
            color: "#f0f2f5"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Label {
                    text: "Witaj w aplikacji!"
                    font.pixelSize: 28
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Zalogowany jako:\n" + loggedUserEmail
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Twój Token (do autoryzacji zapytań API):\n" + authToken
                    font.pixelSize: 12
                    color: "gray"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "Wyloguj się"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        // Czyszczenie danych z pamięci
                        authToken = "";
                        loggedUserEmail = "";
                        // Wyrzucenie obecnego ekranu - powrót do logowania
                        stackView.pop();
                    }
                }
            }
        }
    }

    // ==========================================
    // --- FUNKCJE KOMUNIKACJI Z API ---
    // ==========================================

    function loginApi(email, password, labelRef) {
        if (email === "" || password === "") {
            labelRef.text = "Wypełnij wszystkie pola!";
            labelRef.color = "red";
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/login");
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("LOGOWANIE - Status: " + xhr.status + ", Odpowiedź: '" + xhr.responseText + "'");

                var response = {};
                try {
                    if (xhr.responseText.length > 0) {
                        response = JSON.parse(xhr.responseText);
                    }
                } catch (e) {
                    console.error("Błąd JSON.parse: " + e);
                    labelRef.text = "Błąd komunikacji z serwerem (Serwer nie zwrócił JSONa).";
                    labelRef.color = "red";
                    return;
                }

                if (xhr.status === 200) {
                    authToken = response.token;
                    loggedUserEmail = response.user;
                    labelRef.text = "";
                    var isModFlag = (response.isMod === true);

                    if (response.user === "admin" || response.user === "admin@wp.com") {
                        stackView.push("AdminDashboard.qml", { "authToken": response.token, "loggedUserEmail": response.user });
                    } else {
                        if(response.isEnable) {
                            stackView.push("GamesDashboard.qml",
                                {
                                "authToken": response.token,
                                "loggedUserEmail": response.user,
                                "isUserMod": isModFlag
                            });
                        } else {
                            labelRef.text = "Twoje konto zostało zablokowane, skontaktuj sie z adminem";
                            labelRef.color = "red";
                        }
                    }

                } else if (xhr.status === 0) {
                     labelRef.text = "Brak połączenia z serwerem. Czy serwer C++ działa?";
                     labelRef.color = "red";
                } else {
                    labelRef.text = response.error ? response.error : "Nieznany błąd logowania";
                    labelRef.color = "red";
                }
            }
        }

        var payload = {"email": email, "password": password};
        xhr.send(JSON.stringify(payload));
    }

    function registerApi(name, email, password, labelRef, loginModeRef) {
        if (name === "" || email === "" || password === "") {
            labelRef.text = "Wypełnij wszystkie pola!";
            labelRef.color = "red";
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/register");
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("REJESTRACJA - Status: " + xhr.status + ", Odpowiedź: '" + xhr.responseText + "'");

                var response = {};
                try {
                    if (xhr.responseText.length > 0) {
                        response = JSON.parse(xhr.responseText);
                    }
                } catch (e) {
                    console.error("Błąd JSON.parse: " + e);
                    labelRef.text = "Błąd komunikacji z serwerem.";
                    labelRef.color = "red";
                    return;
                }

                if (xhr.status === 201) {
                    labelRef.text = "Konto utworzone! Możesz się teraz zalogować.";
                    labelRef.color = "green";
                    loginModeRef.isLoginMode = true; // Przełącz na widok logowania
                } else if (xhr.status === 0) {
                     labelRef.text = "Brak połączenia z serwerem. Czy serwer C++ działa?";
                     labelRef.color = "red";
                } else {
                    labelRef.text = response.error ? response.error : "Błąd rejestracji";
                    labelRef.color = "red";
                }
            }
        }

        var payload = {"name": name, "email": email, "password": password, "isMod": false, "isEnable": true};
        xhr.send(JSON.stringify(payload));
    }
}

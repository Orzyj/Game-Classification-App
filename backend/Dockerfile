# --- ETAP 1: Budowanie (Builder) ---
FROM ubuntu:24.04 AS builder

# Instalacja podstawowych narzędzi systemowych
RUN apt-get update && apt-get install -y \
    build-essential cmake git curl zip unzip tar \
    pkg-config libssl-dev

# Pobranie i konfiguracja vcpkg
RUN git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

# 1. Instalacja bibliotek (Ta warstwa zajmie dużo czasu, ale Docker ją zapamięta!)
RUN /opt/vcpkg/vcpkg install mongo-cxx-driver nlohmann-json cpp-httplib

WORKDIR /app

# 2. Kopiujemy WSZYSTKIE pliki źródłowe i CMakeLists.txt do kontenera
# Dzięki temu CMake bez problemu znajdzie main.cpp podczas konfiguracji
COPY . .

# 3. Konfiguracja CMake z użyciem vcpkg
RUN cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake

# 4. Kompilacja projektu
RUN cmake --build build --config Release

# --- ETAP 2: Środowisko uruchomieniowe (Runtime) ---
FROM ubuntu:24.04

# Instalacja wymaganych bibliotek współdzielonych (OpenSSL dla mongocxx/httplib)
RUN apt-get update && apt-get install -y libssl-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Skopiowanie skompilowanej binarki z etapu 1 
# (Zakładam, że w CMakeLists.txt Twoja apka nazywa się my_backend)
COPY --from=builder /app/build/my_backend /app/my_backend

# Otwieramy port, na którym nasłuchuje Twój serwer
EXPOSE 8080

# Uruchamiamy aplikację
CMD ["/app/my_backend"]
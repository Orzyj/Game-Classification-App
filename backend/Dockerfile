# --- ETAP 1: Budowanie ---
FROM ubuntu:24.04 AS builder

# Instalacja podstawowych narzędzi systemowych
RUN apt-get update && apt-get install -y \
    build-essential cmake git curl zip unzip tar \
    pkg-config libssl-dev

# Pobranie i konfiguracja vcpkg
RUN git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

# Instalacja bibliotek (to ten krok, który trochę potrwa)
RUN /opt/vcpkg/vcpkg install mongo-cxx-driver nlohmann-json cpp-httplib

# Kopiowanie kodu źródłowego i konfiguracji CMake
WORKDIR /app
COPY CMakeLists.txt main.cpp Server.cpp Server.hpp ./

# Konfiguracja CMake z użyciem vcpkg
RUN cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake
# Kompilacja projektu
RUN cmake --build build --config Release

# --- ETAP 2: Środowisko uruchomieniowe ---
FROM ubuntu:24.04

# Instalacja wymaganych bibliotek współdzielonych (OpenSSL dla mongocxx/httplib)
RUN apt-get update && apt-get install -y libssl-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Skopiowanie skompilowanej binarce z etapu 1
COPY --from=builder /app/build/my_backend /app/my_backend

EXPOSE 8080

CMD ["/app/my_backend"]
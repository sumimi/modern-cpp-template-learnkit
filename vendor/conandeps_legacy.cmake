message(STATUS "Conan: Using CMakeDeps conandeps_legacy.cmake aggregator via include()")
message(STATUS "Conan: It is recommended to use explicit find_package() per dependency instead")

find_package(spdlog)
find_package(libpqxx)
find_package(cxxopts)
find_package(nlohmann_json)
find_package(libsodium)

set(CONANDEPS_LEGACY  spdlog::spdlog  libpqxx::pqxx  cxxopts::cxxopts  nlohmann_json::nlohmann_json  libsodium::libsodium )
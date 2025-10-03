add_executable(intro main.cpp)

target_link_libraries(
  intro
  PRIVATE sailup::sailup_options
          sailup::sailup_warnings)

target_link_system_libraries(
  intro
  PRIVATE
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog)

target_include_directories(intro PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

add_executable(sailup_bin main.cpp)
set_target_properties(sailup_bin PROPERTIES OUTPUT_NAME sailup)

target_link_libraries(
  sailup_bin
  PRIVATE sailup::sailup_options
          sailup::sailup_warnings
          sailup::sailup)

target_link_system_libraries(
  sailup_bin
  PRIVATE
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog)

target_include_directories(sailup_bin PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

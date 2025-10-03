#include <cstdlib>
#include <exception>
#include <optional>
#include <string>

#include <CLI/CLI.hpp>
#include <fmt/base.h>
#include <fmt/format.h>
#include <spdlog/spdlog.h>

// This file will be generated automatically when cur_you run the CMake
// configuration step. It creates a namespace called `sailup`. You can modify
// the source template at `configured_files/config.hpp.in`.
#include <internal_use_only/config.hpp>
#include <sailup/sailup.hpp>

// NOLINTNEXTLINE(bugprone-exception-escape)
int main(int argc, const char **argv)
{
  try {
    CLI::App app{ fmt::format("{} version {}", sailup::cmake::project_name, sailup::cmake::project_version) };

    std::optional<std::string> message;
    app.add_option("-m,--message", message, "A message to print back out");
    bool show_version = false;  // NOLINT(misc-const-correctness)
    app.add_flag("--version", show_version, "Show version information");

    bool is_turn_based = false;  // NOLINT(misc-const-correctness)
    auto *turn_based = app.add_flag("--turn_based", is_turn_based);

    bool is_loop_based = false;  // NOLINT(misc-const-correctness)
    auto *loop_based = app.add_flag("--loop_based", is_loop_based);

    turn_based->excludes(loop_based);
    loop_based->excludes(turn_based);


    CLI11_PARSE(app, argc, argv);

    if (show_version) {
      fmt::print("{}\n", sailup::cmake::project_version);
      return EXIT_SUCCESS;
    }

    fmt::print("factorial(0) = {}\n", factorial(0));
  } catch (const std::exception &e) {
    spdlog::error("Unhandled exception in main: {}", e.what());
  }
}

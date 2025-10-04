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

    bool install_cppcheck = false;  // NOLINT(misc-const-correctness)
    app.add_flag("--install-cppcheck", install_cppcheck, "Install cppcheck using system package manager");


    CLI11_PARSE(app, argc, argv);

    if (show_version) {
      fmt::print("{}\n", sailup::cmake::project_version);
      return EXIT_SUCCESS;
    }

    if (install_cppcheck) {
      spdlog::info("Installing cppcheck...");

      // Detect OS and install cppcheck
#if defined(_WIN32) || defined(_WIN64)
      spdlog::info("Detected Windows OS, using chocolatey...");
      // NOLINTNEXTLINE(cert-env33-c,concurrency-mt-unsafe)
      int result = std::system("choco install cppcheck -y");
#elifdef __APPLE__
      spdlog::info("Detected macOS, using Homebrew...");
      // NOLINTNEXTLINE(cert-env33-c,concurrency-mt-unsafe)
      int result = std::system("brew install cppcheck");
#elifdef __linux__
      spdlog::info("Detected Linux OS, using apt...");
      // NOLINTNEXTLINE(cert-env33-c,concurrency-mt-unsafe)
      int result = std::system("sudo apt update && sudo apt install -y cppcheck");
#else
      spdlog::error("Unsupported operating system for automatic cppcheck installation");
      return EXIT_FAILURE;
#endif

      if (result == 0) {
        spdlog::info("cppcheck installed successfully");
        return EXIT_SUCCESS;
      } else {
        spdlog::error("Failed to install cppcheck (exit code: {})", result);
        return EXIT_FAILURE;
      }
    }

    fmt::print("factorial(0) = {}\n", factorial(0));
  } catch (const std::exception &e) {
    spdlog::error("Unhandled exception in main: {}", e.what());
  }
}

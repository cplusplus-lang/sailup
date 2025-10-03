include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


include(CheckCXXSourceCompiles)


macro(sailup_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)

    message(STATUS "Sanity checking UndefinedBehaviorSanitizer, it should be supported on this platform")
    set(TEST_PROGRAM "int main() { return 0; }")

    # Check if UndefinedBehaviorSanitizer works at link time
    set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")
    check_cxx_source_compiles("${TEST_PROGRAM}" HAS_UBSAN_LINK_SUPPORT)

    if(HAS_UBSAN_LINK_SUPPORT)
      message(STATUS "UndefinedBehaviorSanitizer is supported at both compile and link time.")
      set(SUPPORTS_UBSAN ON)
    else()
      message(WARNING "UndefinedBehaviorSanitizer is NOT supported at link time.")
      set(SUPPORTS_UBSAN OFF)
    endif()
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    if (NOT WIN32)
      message(STATUS "Sanity checking AddressSanitizer, it should be supported on this platform")
      set(TEST_PROGRAM "int main() { return 0; }")

      # Check if AddressSanitizer works at link time
      set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=address")
      check_cxx_source_compiles("${TEST_PROGRAM}" HAS_ASAN_LINK_SUPPORT)

      if(HAS_ASAN_LINK_SUPPORT)
        message(STATUS "AddressSanitizer is supported at both compile and link time.")
        set(SUPPORTS_ASAN ON)
      else()
        message(WARNING "AddressSanitizer is NOT supported at link time.")
        set(SUPPORTS_ASAN OFF)
      endif()
    else()
      set(SUPPORTS_ASAN ON)
    endif()
  endif()
endmacro()

macro(sailup_setup_options)
  option(sailup_ENABLE_HARDENING "Enable hardening" ON)
  option(sailup_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    sailup_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    sailup_ENABLE_HARDENING
    OFF)

  sailup_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR sailup_PACKAGING_MAINTAINER_MODE)
    option(sailup_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(sailup_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(sailup_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(sailup_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(sailup_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(sailup_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(sailup_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(sailup_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(sailup_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(sailup_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(sailup_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(sailup_ENABLE_PCH "Enable precompiled headers" OFF)
    option(sailup_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(sailup_ENABLE_IPO "Enable IPO/LTO" ON)
    option(sailup_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(sailup_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(sailup_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(sailup_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(sailup_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(sailup_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(sailup_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(sailup_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(sailup_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(sailup_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(sailup_ENABLE_PCH "Enable precompiled headers" OFF)
    option(sailup_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      sailup_ENABLE_IPO
      sailup_WARNINGS_AS_ERRORS
      sailup_ENABLE_USER_LINKER
      sailup_ENABLE_SANITIZER_ADDRESS
      sailup_ENABLE_SANITIZER_LEAK
      sailup_ENABLE_SANITIZER_UNDEFINED
      sailup_ENABLE_SANITIZER_THREAD
      sailup_ENABLE_SANITIZER_MEMORY
      sailup_ENABLE_UNITY_BUILD
      sailup_ENABLE_CLANG_TIDY
      sailup_ENABLE_CPPCHECK
      sailup_ENABLE_COVERAGE
      sailup_ENABLE_PCH
      sailup_ENABLE_CACHE)
  endif()

  sailup_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (sailup_ENABLE_SANITIZER_ADDRESS OR sailup_ENABLE_SANITIZER_THREAD OR sailup_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(sailup_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(sailup_global_options)
  if(sailup_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    sailup_enable_ipo()
  endif()

  sailup_supports_sanitizers()

  if(sailup_ENABLE_HARDENING AND sailup_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR sailup_ENABLE_SANITIZER_UNDEFINED
       OR sailup_ENABLE_SANITIZER_ADDRESS
       OR sailup_ENABLE_SANITIZER_THREAD
       OR sailup_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${sailup_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${sailup_ENABLE_SANITIZER_UNDEFINED}")
    sailup_enable_hardening(sailup_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(sailup_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(sailup_warnings INTERFACE)
  add_library(sailup_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  sailup_set_project_warnings(
    sailup_warnings
    ${sailup_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(sailup_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    sailup_configure_linker(sailup_options)
  endif()

  include(cmake/Sanitizers.cmake)
  sailup_enable_sanitizers(
    sailup_options
    ${sailup_ENABLE_SANITIZER_ADDRESS}
    ${sailup_ENABLE_SANITIZER_LEAK}
    ${sailup_ENABLE_SANITIZER_UNDEFINED}
    ${sailup_ENABLE_SANITIZER_THREAD}
    ${sailup_ENABLE_SANITIZER_MEMORY})

  set_target_properties(sailup_options PROPERTIES UNITY_BUILD ${sailup_ENABLE_UNITY_BUILD})

  if(sailup_ENABLE_PCH)
    target_precompile_headers(
      sailup_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(sailup_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    sailup_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(sailup_ENABLE_CLANG_TIDY)
    sailup_enable_clang_tidy(sailup_options ${sailup_WARNINGS_AS_ERRORS})
  endif()

  if(sailup_ENABLE_CPPCHECK)
    sailup_enable_cppcheck(${sailup_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(sailup_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    sailup_enable_coverage(sailup_options)
  endif()

  if(sailup_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(sailup_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(sailup_ENABLE_HARDENING AND NOT sailup_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR sailup_ENABLE_SANITIZER_UNDEFINED
       OR sailup_ENABLE_SANITIZER_ADDRESS
       OR sailup_ENABLE_SANITIZER_THREAD
       OR sailup_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    sailup_enable_hardening(sailup_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()

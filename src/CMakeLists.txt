include(GenerateExportHeader)


add_library(sailup_lib lib.cpp)



add_library(sailup::sailup ALIAS sailup_lib)

target_link_libraries(sailup_lib PRIVATE sailup_options sailup_warnings)

target_include_directories(sailup_lib ${WARNING_GUARD} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                                                                  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)

target_compile_features(sailup_lib PUBLIC cxx_std_20)

set_target_properties(
  sailup_lib
  PROPERTIES VERSION ${PROJECT_VERSION}
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(sailup_lib
                       BASE_NAME SAILUP
                       EXPORT_MACRO_NAME SAILUP_API
                       EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/include/sailup/sailup_api.hpp)

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(sailup_lib PUBLIC SAILUP_STATIC_DEFINE)
endif()

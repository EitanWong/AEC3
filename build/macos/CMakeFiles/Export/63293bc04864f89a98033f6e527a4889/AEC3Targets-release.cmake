#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "AEC3::AEC3" for configuration "Release"
set_property(TARGET AEC3::AEC3 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(AEC3::AEC3 PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libAEC3.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libAEC3.dylib"
  )

list(APPEND _cmake_import_check_targets AEC3::AEC3 )
list(APPEND _cmake_import_check_files_for_AEC3::AEC3 "${_IMPORT_PREFIX}/lib/libAEC3.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

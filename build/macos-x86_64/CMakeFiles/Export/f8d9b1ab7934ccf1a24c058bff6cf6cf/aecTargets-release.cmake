#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "aec::libaec3" for configuration "Release"
set_property(TARGET aec::libaec3 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(aec::libaec3 PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/aec3.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/aec3.dylib"
  )

list(APPEND _cmake_import_check_targets aec::libaec3 )
list(APPEND _cmake_import_check_files_for_aec::libaec3 "${_IMPORT_PREFIX}/lib/aec3.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

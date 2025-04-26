#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "aec::libaec" for configuration "Debug"
set_property(TARGET aec::libaec APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(aec::libaec PROPERTIES
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/aec.dylib"
  IMPORTED_SONAME_DEBUG "@rpath/aec.dylib"
  )

list(APPEND _cmake_import_check_targets aec::libaec )
list(APPEND _cmake_import_check_files_for_aec::libaec "${_IMPORT_PREFIX}/lib/aec.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

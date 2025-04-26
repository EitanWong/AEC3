
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was AEC3Config.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

include(CMakeFindDependencyMacro)

# Find dependencies (if any)
# find_dependency(SomeDependency REQUIRED)

# Our library targets
include("${CMAKE_CURRENT_LIST_DIR}/aecTargets.cmake")

# Define the library targets
set(AEC_LIBRARIES aec::libaec)

# Component support
set(AEC_FOUND TRUE)

# Check if library was built with C API
if(NOT TARGET AEC3::aec3_c_api)
    set(AEC3_C_API_FOUND FALSE)
endif() 

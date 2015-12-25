include(CheckLibraryExists)
include(FindPackageHandleStandardArgs)

find_path(LIBNACL_INCLUDE_DIRS NAMES nacl/crypto_auth.h)
find_library(LIBNACL_LIBRARIES NAMES nacl)
mark_as_advanced(LIBNACL_INCLUDE_DIRS LIBNACL_LIBRARIES)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(NaCl
    FOUND_VAR NaCl_FOUND
    REQUIRED_VARS LIBNACL_LIBRARIES LIBNACL_INCLUDE_DIRS
)

cmake_minimum_required(VERSION 2.8.4)

project(toxcore C)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_SOURCE_DIR}/cmake")


include(FeatureSummary)
include(CMakeDependentOption)
include(FindPkgConfig)

find_package(Threads REQUIRED QUIET)
set_package_properties(Threads PROPERTIES TYPE REQUIRED DESCRIPTION "pthread_* functions")

pkg_check_modules(Check check)
set_package_properties(Check PROPERTIES TYPE OPTIONAL
    URL "https://libcheck.github.io/check/"
    DESCRIPTION "Testing framework for C"
    PURPOSE "Enables unit tests"
)
pkg_check_modules(Opus opus)
set_package_properties(Opus PROPERTIES TYPE OPTIONAL
    URL "https://www.opus-codec.org/"
    DESCRIPTION "Opus codec library development files"
    PURPOSE "Enables AV support"
)
pkg_check_modules(VPX vpx)
set_package_properties(VPX PROPERTIES TYPE OPTIONAL
    URL "http://www.webmproject.org/"
    DESCRIPTION "VP8 video codec development files"
    PURPOSE "Enables AV support"
)
find_package(NaCl REQUIRED)
set_package_properties(NaCl PROPERTIES TYPE REQUIRED
    URL "http://nacl.cace-project.eu/"
    DESCRIPTION "High-speed software library for network communication"
)
pkg_check_modules(Sodium REQUIRED libsodium)
set_package_properties(Sodium PROPERTIES TYPE REQUIRED
    URL "https://download.libsodium.org/doc/"
    DESCRIPTION "Software library for encryption, decryption, signatures, password hashing and more"
)
find_package(Config REQUIRED)
set_package_properties(Config PROPERTIES TYPE REQUIRED
    URL "http://www.hyperrealm.com/libconfig/"
    DESCRIPTION "Parsing/manipulation of structured config files"
)

include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckTypeSize)

set(HAVE_LIBCHECK ${Check_FOUND})
#libconfig HAVE_LIBCONFIG)
set(HAVE_LIBNACL ${NaCl_FOUND})
set(HAVE_LIBSODIUM ${Sodium_FOUND})
#HAVE_PTHREAD
#HAVE_PTHREAD_PRIO_INHERIT
#HAVE_STDBOOL_H #?!?

CHECK_FUNCTION_EXISTS(fork HAVE_FORK)
CHECK_FUNCTION_EXISTS(malloc HAVE_MALLOC)
CHECK_FUNCTION_EXISTS(memset HAVE_MEMSET)
CHECK_FUNCTION_EXISTS(socket HAVE_SOCKET)
CHECK_FUNCTION_EXISTS(gettimeofday HAVE_GETTIMEOFDAY)
CHECK_FUNCTION_EXISTS(strchr HAVE_STRCHR)
CHECK_FUNCTION_EXISTS(vfork HAVE_VFORK)

CHECK_INCLUDE_FILES(arpa/inet.h HAVE_ARPA_INET_H)
CHECK_INCLUDE_FILES(dlfcn.h HAVE_DLFCN_H)
CHECK_INCLUDE_FILES(inttypes.h HAVE_INTTYPES_H)
CHECK_INCLUDE_FILES(memory.h HAVE_MEMORY_H)
CHECK_INCLUDE_FILES(netdb.h HAVE_NETDB_H)
CHECK_INCLUDE_FILES(netinet/in.h HAVE_NETINET_IN_H)
CHECK_INCLUDE_FILES(stdint.h HAVE_STDINT_H)
CHECK_INCLUDE_FILES(stdlib.h HAVE_STDLIB_H)
CHECK_INCLUDE_FILES(strings.h HAVE_STRINGS_H)
CHECK_INCLUDE_FILES(string.h HAVE_STRING_H)
CHECK_INCLUDE_FILES(sys/socket.h HAVE_SYS_SOCKET_H)
CHECK_INCLUDE_FILES(sys/stat.h HAVE_SYS_STAT_H)
CHECK_INCLUDE_FILES(sys/time.h HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)
CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)
CHECK_INCLUDE_FILES(vfork.h HAVE_VFORK_H)

check_type_size(_Bool BOOL__SIZE)
if (BOOL__SIZE)
    set(HAVE__BOOL 1)
endif()

set(TOX_LOGGER )
set(LOGGER_LEVEL )
set(LOGGER_OUTPUT_FILE )

set(PACKAGE )
set(PACKAGE_BUGREPORT )
set(PACKAGE_NAME )
set(PACKAGE_STRING )
set(PACKAGE_TARNAME )
set(VERSION )


set(USE_RANDOMBYTES_STIR )
set(VANILLA_NACL )

configure_file(${CMAKE_SOURCE_DIR}/cmake/config.h.in ${CMAKE_SOURCE_DIR}/config.h)

# declare options and features

CMAKE_DEPENDENT_OPTION(BUILD_AV "Should we build lib AV?" ON "Opus_FOUND; VPX_FOUND" OFF)
ADD_FEATURE_INFO(BUILD_AV BUILD_AV "build AV support libraries")

option(BUILD_TESTING_TOOLS "Should we build testing tools?" ON)
ADD_FEATURE_INFO(BUILD_TESTING_TOOLS BUILD_TESTING_TOOLS "build various testing tools")

CMAKE_DEPENDENT_OPTION(BUILD_NTOX "Should we build nTox client?" OFF "BUILD_TESTING_TOOLS" OFF)
ADD_FEATURE_INFO(BUILD_NTOX BUILD_NTOX "build nTox client")

CMAKE_DEPENDENT_OPTION(BUILD_DAEMON "Should we build DHT bootstrap daemon?" ON "Config_FOUND" OFF)
ADD_FEATURE_INFO(BUILD_DAEMON BUILD_DAEMON "build DHT bootstrap daemon")

CMAKE_DEPENDENT_OPTION(BUILD_TESTS "Should we build unit tests?" ON "Check_FOUND" OFF)
ADD_FEATURE_INFO(BUILD_TESTS BUILD_TESTS "build unit tests")

FEATURE_SUMMARY(WHAT ALL)

# compile libtoxcore

file(GLOB CORE_SRC "toxcore/*.c")
add_library(toxcore ${CORE_SRC})
target_link_libraries(toxcore ${Sodium_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})

# compile libtoxav

if (BUILD_AV)
    include_directories(/usr/include/opus/)
    file(GLOB AV_SRC "toxav/*.c")
    add_library(toxav ${AV_SRC})
    target_link_libraries(toxav toxcore ${Opus_LIBRARIES} ${VPX_LIBRARIES})
endif()

# compile libtoxdns

file(GLOB DNS_SRC "toxdns/*.c")
add_library(toxdns ${DNS_SRC})
target_link_libraries(toxdns toxcore)

# compile libtoxencryptsave

file(GLOB_RECURSE ENCRYPTSAVE_SRC "toxencryptsave/*.c")
add_library(toxencryptsave ${ENCRYPTSAVE_SRC})

# build daemon

add_executable(tox-bootstrapd "other/bootstrap_daemon/tox-bootstrapd.c")
target_link_libraries(tox-bootstrapd toxcore ${LIBCONFIG_LIBRARIES})

# build various testing tools

if (BUILD_TESTING_TOOLS)
    #c_test(PRETTY_NAME "test::DHT" BIN_NAME "DHT_test" SOURCES "testing/DHT_test.c" LIBS toxcore)
    #c_test(PRETTY_NAME "test::dns3" BIN_NAME "dns3_test" SOURCES "testing/dns3_test.c" LIBS toxdns util)
    #c_test(PRETTY_NAME "test::Messenger" BIN_NAME "Messenger_test" SOURCES "testing/Messenger_test.c" LIBS toxcore)
    #c_test(PRETTY_NAME "tox::sync" BIN_NAME "tox_sync" SOURCES "testing/tox_sync.c" LIBS toxcore util)
    #c_test(PRETTY_NAME "tox::shell" BIN_NAME "tox_shell" SOURCES "testing/tox_shell.c" LIBS toxcore util)
    #c_test(PRETTY_NAME "irc::syncbot" BIN_NAME "irc_syncbot" SOURCES "testing/irc_syncbot.c" LIBS toxcore)
    # nTox
endif()

# install rules

install(TARGETS
    toxav
    toxcore
    toxdns
    toxencryptsave
    DESTINATION lib/
)
install(FILES
    toxav/toxav.h
    toxcore/tox.h
    toxcore/tox_old.h
    toxdns/toxdns.h
    toxencryptsave/toxencryptsave.h
    DESTINATION include/tox/
)

# build unit tests

if (BUILD_TESTS)
    add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure)
    enable_testing()

    include(CMakeParseArguments)
    function(c_test) # function to register tests. see examples below
        set(options )
        set(one_value_args PRETTY_NAME BIN_NAME)
        set(multi_value_args SOURCES LIBS)
        CMAKE_PARSE_ARGUMENTS(TEST "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

        if (NOT TEST_PRETTY_NAME OR NOT TEST_BIN_NAME OR NOT TEST_SOURCES)
            message(FATAL_ERROR "Arguments PRETTY_NAME, BIN_NAME, SOURCES are required!")
        endif()
        if (TEST_UNPARSED_ARGUMENTS)
            message(FATAL_ERROR "Arguments were not parsed during creation of tests: ${TEST_UNPARSED_ARGUMENTS}")
        endif()

        add_executable(${TEST_BIN_NAME} EXCLUDE_FROM_ALL ${TEST_SOURCES})
        target_link_libraries(${TEST_BIN_NAME} ${Check_LIBRARIES} rt m ${TEST_LIBS})

        add_test(NAME ${TEST_PRETTY_NAME} COMMAND ${TEST_BIN_NAME})
        add_dependencies(check ${TEST_BIN_NAME})
    endfunction()

    c_test(PRETTY_NAME "test::encryptsave" BIN_NAME "encryptsave_test" SOURCES "auto_tests/encryptsave_test.c" LIBS toxcore toxencryptsave)
    c_test(PRETTY_NAME "test::messenger" BIN_NAME "messenger_autotest" SOURCES "auto_tests/messenger_test.c" LIBS toxcore)
    c_test(PRETTY_NAME "test::crypto" BIN_NAME "crypto_test" SOURCES "auto_tests/crypto_test.c" LIBS toxcore)
    c_test(PRETTY_NAME "test::network" BIN_NAME "network_test" SOURCES "auto_tests/network_test.c" LIBS toxcore)
    c_test(PRETTY_NAME "test::assoc" BIN_NAME "assoc_test" SOURCES "auto_tests/assoc_test.c" LIBS toxcore)
    c_test(PRETTY_NAME "test::onion" BIN_NAME "onion_test" SOURCES "auto_tests/onion_test.c" LIBS toxcore)
    c_test(PRETTY_NAME "test::TCP" BIN_NAME "TCP_test" SOURCES "auto_tests/TCP_test.c" LIBS toxcore)
    c_test(PRETTY_NAME "test::tox" BIN_NAME "tox_test" SOURCES "auto_tests/tox_test.c" LIBS toxcore)
    c_test(PRETTY_NAME "test::DHT" BIN_NAME "dht_autotest" SOURCES "auto_tests/dht_test.c" LIBS toxcore)
    if (BUILD_AV)
        c_test(PRETTY_NAME "test::av::basic" BIN_NAME "toxav_basic_test" SOURCES "auto_tests/toxav_basic_test.c" LIBS toxav)
        c_test(PRETTY_NAME "test::av::many" BIN_NAME "toxav_many_test" SOURCES "auto_tests/toxav_many_test.c" LIBS toxav)
    endif()
endif()






set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "tox")
set (CPACK_DEBIAN_PACKAGE_DESCRIPTION # The format of Description: http://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Description
"tox
 Tox protocol library
")
set (CPACK_PACKAGE_CONTACT "irungentoo@gmail.com")
set (CPACK_PACKAGE_VERSION_MAJOR "1")
set (CPACK_PACKAGE_VERSION_MINOR "0")
set (CPACK_PACKAGE_VERSION_PATCH "0")
#set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_IGNORE_FILES "build/" "\\\\.kdev.*" "\\\\.git.*" "\\\\.hgignore")
set (CPACK_STRIP_FILES "")


set (CPACK_GENERATOR "DEB")
set (CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/irungentoo/toxcore")
set (CPACK_DEBIAN_PACKAGE_MAINTAINER "irungentoo <irungentoo@gmail.com>")
#set (CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i386")
#set (CPACK_DEBIAN_PACKAGE_DEPENDS "libc6:i386, libgcc1:i386, libstdc++6:i386, libreadline6:i386, libtinfo5:i386")

include(CPack)

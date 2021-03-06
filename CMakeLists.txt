# How to build QtNetworkNg for Linux with cmake
# 1. Build static Qt:
#     ./configure --prefix="/usr/local/Qt5.11.1-linux-static-amd64" -release -opensource -static -no-gui -no-icu -no-glib -no-iconv -nomake tests -nomake examples
#     make -j4 && sudo make install
# 2. Build QtNetworkNg
#     mkdir build
#     cd build
#     cmake -DCMAKE_PREFIX_PATH=/usr/local/Qt5.11.1-linux-static-amd64/lib/cmake/ ..
#     make -j4
#     sudo make install
#
# How to cross build QtNetworkNg for Android with cmake
# 1. Build static Qt:
#     ./configure --prefix="/usr/local/Qt5.11.1-android-static-armv7" -release -opensource -static -no-gui -no-icu -xplatform android-clang -disable-rpath -nomake tests -nomake examples -android-ndk /home/goldfish/bin/android-sdk-linux/ndk-bundle -android-sdk /home/goldfish/bin/android-sdk-linux -android-ndk-platform android-14 -android-arch armeabi-v7a
#     make -j4 && sudo make install
# 2. Build QtNetworkNg
#     mkdir build
#     cd build
#     cmake -DANDROID_ABI=armeabi-v7a -DANDROID_NDK=/home/goldfish/bin/android-sdk-linux/ndk-bundle -DCMAKE_TOOLCHAIN_FILE=/home/goldfish/bin/android-sdk-linux/ndk-bundle/build/cmake/android.toolchain.cmake -DANDROID_TOOLCHAIN=clang -DANDROID_PLATFORM=android-14 -DANDROID_STL=c++_static -DCMAKE_PREFIX_PATH=/usr/local/Qt5.11.1-android-static-armv7/lib/cmake -DANDROID_CPP_FEATURES="exceptions rtti" ..
#     make -j4
#     sudo make install


cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)

project(qtnetworkng VERSION 0.5.2 LANGUAGES C CXX ASM)

option(QTNG_BUILD_TESTS OFF)
set(CMAKE_AUTOMOC ON)
if(ANDROID)
    find_package(Qt5Core CONFIG REQUIRED CMAKE_FIND_ROOT_PATH_BOTH)
    find_package(Qt5Network CONFIG REQUIRED CMAKE_FIND_ROOT_PATH_BOTH)
    find_package(Qt5Test CONFIG CMAKE_FIND_ROOT_PATH_BOTH)
else()
    find_package(Qt5Core REQUIRED)
    find_package(Qt5Network REQUIRED)
    find_package(Qt5Test)
endif()

set(QTNETWORKNG_SRC
    src/socket.cpp
    src/eventloop.cpp
    src/coroutine.cpp
    src/locks.cpp
    src/coroutine_utils.cpp
    src/http.cpp
    src/httpd.cpp
    src/socket_utils.cpp
    src/socket_server.cpp
    src/http_utils.cpp
    src/http_proxy.cpp
    src/socks5_proxy.cpp
    src/eventloop_qt.cpp
    src/msgpack.cpp
    src/data_channel.cpp
)

set(QTNETWORKNG_INCLUDE
    include/config.h
    include/coroutine.h
    include/socket.h
    include/eventloop.h
    include/locks.h
    include/coroutine_utils.h
    include/http.h
    include/httpd.h
    include/socket_utils.h
    include/socket_server.h
    include/http_utils.h
    include/http_proxy.h
    include/socks5_proxy.h
    include/deferred.h
    include/qtnetworkng.h
    include/msgpack.h
    include/data_channel.h
)

SET(QTNETWORKNG_PRIVATE_INCLUDE
    include/private/data_pack.h
    include/private/eventloop_p.h
    include/private/coroutine_p.h
    include/private/socket_p.h
    include/private/http_p.h
)

set(QTCRYPTONG_SRC
    src/ssl.cpp
    src/crypto.cpp
    src/random.cpp
    src/md.cpp
    src/pkey.cpp
    src/cipher.cpp
    src/certificate.cpp
    src/qasn1element.cpp
)

set(QTCRYPTONG_INCLUDE
    include/config.h
    include/crypto.h
    include/ssl.h
    include/md.h
    include/random.h
    include/cipher.h
    include/pkey.h
    include/certificate.h
)

set(QTCRYPTONG_PRIVATE_INCLUDE
    include/private/crypto_p.h
    include/private/qtng_temp.h
    include/private/qasn1element.h
)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    set(OS_DEPENDENDED_SRC
        src/socket_win.cpp
        src/coroutine_win.cpp
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
    # Android support cross build.
    if(${CMAKE_ANDROID_ARCH_ABI} STREQUAL "arm64-v8a")
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_arm64_aapcs_elf_gas.S
            src/context/asm/make_arm64_aapcs_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    elseif(${CMAKE_ANDROID_ARCH_ABI} STREQUAL "armeabi-v7a")
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_arm_aapcs_elf_gas.S
            src/context/asm/make_arm_aapcs_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    elseif(${CMAKE_ANDROID_ARCH_ABI} STREQUAL "mips")
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_mips32_o32_elf_gas.S
            src/context/asm/make_mips32_o32_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    elseif(${CMAKE_ANDROID_ARCH_ABI} STREQUAL "mips64")
        message(FATAL_ERROR Android for mips64 is not supported.)
    elseif(${CMAKE_ANDROID_ARCH_ABI} STREQUAL "x86")
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_i386_sysv_elf_gas.S
            src/context/asm/make_i386_sysv_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    elseif(${CMAKE_ANDROID_ARCH_ABI} STREQUAL "x86_64")
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_x86_64_sysv_elf_gas.S
            src/context/asm/make_x86_64_sysv_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    else()
        message(FATAL_ERROR Android for ${CMAKE_ANDROID_ARCH_ABI} is not supported.)
    endif()
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    set(OS_DEPENDENDED_SRC
        src/socket_unix.cpp
        src/coroutine_unix.cpp
    )
elseif(UNIX)
    # TODO should support cross build.
    if((${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
            OR (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "amd64"))
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_x86_64_sysv_elf_gas.S
            src/context/asm/make_x86_64_sysv_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    elseif((${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i386")
            OR (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686"))
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_i386_sysv_elf_gas.S
            src/context/asm/make_i386_sysv_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    elseif((${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64")
            OR (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm64"))
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_arm64_aapcs_elf_gas.S
            src/context/asm/make_arm64_aapcs_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    elseif((${CMAKE_SYSTEM_PROCESSOR} STREQUAL "armv7")
            OR (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm"))
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_arm_aapcs_elf_gas.S
            src/context/asm/make_arm_aapcs_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    #ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "mips64")
    elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "mips")
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/context/asm/jump_mips32_o32_elf_gas.S
            src/context/asm/make_mips32_o32_elf_gas.S
            src/coroutine_fcontext.cpp
        )
    else()
        # fall back to ucontext
        set(OS_DEPENDENDED_SRC
            src/socket_unix.cpp
            src/coroutine_unix.cpp
        )
    endif()
else()
    message(FATAL_ERROR ${CMAKE_SYSTEM_NAME} is not supported.)
endif()

if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
# intergrate libev
add_definitions(-DQTNETWOKRNG_USE_EV)
add_subdirectory(ev)
set(QTNETWORKNG_EV_SRC src/eventloop_ev.cpp)
set(QTNETWORKNG_EV_LIB ev)
endif()

# intergrate libressl
set(LIBRESSL_APPS OFF)
set(LIBRESSL_TESTS OFF)
add_subdirectory(libressl)

add_library(qtnetworkng STATIC ${QTNETWORKNG_SRC} ${QTNETWORKNG_EV_SRC} ${QTNETWORKNG_INCLUDE} ${QTNETWORKNG_PRIVATE_INCLUDE}
                               ${QTCRYPTONG_SRC} ${QTCRYPTONG_INCLUDE} ${QTCRYPTONG_PRIVATE_INCLUDE} ${OS_DEPENDENDED_SRC})
target_include_directories(qtnetworkng PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

# Fix Qt-static cmake BUG
# https://bugreports.qt.io/browse/QTBUG-38913
if((EXISTS ${_qt5Core_install_prefix}/lib/libQt5Core.so) OR
   (EXISTS ${_qt5Core_install_prefix}/lib64/libQt5Core.so) OR
   (EXISTS ${_qt5Core_install_prefix}/bin/Qt5Core.dll))
    message("Shared Qt is detected.")
else()
    message("Static Qt is detected.")
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
        set(OS_EXTRA_LINK z log qtpcre2)
    elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        set(OS_EXTRA_LINK z pthread dl qtpcre2)
    elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
        set(OS_EXTRA_LINK ws2_32 qtpcre2)
    endif()
    link_directories(${_qt5Core_install_prefix}/lib/)
endif()

target_link_libraries(qtnetworkng PUBLIC Qt5::Core Qt5::Network PRIVATE tls ssl crypto ${QTNETWORKNG_EV_LIB} ${OS_EXTRA_LINK})

set(CMAKE_INSTALL_PREFIX ${_qt5Core_install_prefix})
install(TARGETS qtnetworkng ARCHIVE DESTINATION lib)
install(FILES ${QTNETWORKNG_INCLUDE} ${QTCRYPTONG_INCLUDE} DESTINATION include/qtnetworkng/)
install(FILES ${QTNETWORKNG_PRIVATE_INCLUDE} ${QTCRYPTONG_PRIVATE_INCLUDE} DESTINATION include/qtnetworkng/private/)

IF(Qt5Test_FOUND AND QTNG_BUILD_TESTS)
    add_executable(test_ssl tests/test_ssl.cpp)
    target_link_libraries(test_ssl PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(test_crypto tests/test_crypto.cpp ${TEST_CRYPTO_MOC_FILES})
    target_link_libraries(test_crypto PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(test_coroutines tests/test_coroutines.cpp ${TEST_COROUTINES_MOC_FILES})
    target_link_libraries(test_coroutines PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(sleep_coroutines tests/sleep_coroutines.cpp)
    target_link_libraries(sleep_coroutines PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(simple_test tests/simple_test.cpp)
    target_link_libraries(simple_test PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(many_httpget tests/many_httpget.cpp)
    target_link_libraries(many_httpget PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(test_socket tests/test_socket.cpp)
    target_link_libraries(test_socket PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(test_msgpack tests/test_msgpack.cpp)
    target_link_libraries(test_msgpack PRIVATE Qt5::Core Qt5::Network Qt5::Test qtnetworkng)

    add_executable(simple_httpd tests/simple_httpd.cpp)
    target_link_libraries(simple_httpd PRIVATE Qt5::Core Qt5::Network qtnetworkng)
endif()

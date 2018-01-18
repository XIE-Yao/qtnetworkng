QT = core network testlib

TARGET = qtnetworkng
CONFIG += console
#CONFIG += networkng_ev
CONFIG -= app_bundle
TEMPLATE = app
SOURCES += tests/simple_test.cpp \
    tests/test_data_channel.cpp \
    tests/many_httpget.cpp \
    tests/sleep_coroutines.cpp \
    tests/test_crypto.cpp \
    tests/test_ssl.cpp
#DEFINES += QSOCKETNG_DEBUG

include(qtnetworkng.pri)
include(qtsslng.pri)





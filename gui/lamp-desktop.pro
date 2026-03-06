QT += core gui widgets
TARGET = lamp-desktop
TEMPLATE = app
SOURCES += main.cpp \
           installer.cpp
HEADERS += installer.h
CONFIG += c++17
QMAKE_CXXFLAGS += -std=c++17

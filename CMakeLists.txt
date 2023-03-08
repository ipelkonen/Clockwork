cmake_minimum_required(VERSION 3.16)

project(Clockwork VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON) # Required for automatic .qrc compilation
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 COMPONENTS Quick REQUIRED)
find_package(Qt6 6.2 COMPONENTS ShaderTools REQUIRED) # Required for automatic shader compilation
find_package(Qt6 6.2 COMPONENTS LinguistTools REQUIRED) # Required for automatic language compilation

# Translations
SET(CW_TS_FILES languages/en.ts languages/fi.ts)
qt_add_translation(CW_QM_FILES ${CW_TS_FILES})
add_custom_target(translations DEPENDS ${CW_QM_FILES})
install(FILES ${CW_QM_FILES} DESTINATION languages)

qt_add_executable(appClockwork
    main.cpp resources.qrc mouseeventlistener.h mouseeventlistener.cpp translator.h translator.cpp
    ${CW_QM_FILES}
)

qt_add_qml_module(appClockwork
    URI Clockwork
    VERSION 1.0
    QML_FILES main.qml CustomComboBox.qml CustomPopup.qml
)

qt6_add_shaders(appClockwork "shaders"
  BATCHABLE
  PRECOMPILE
  OPTIMIZED
  PREFIX "/"
  FILES "shaders/wobble.frag"
)

set_target_properties(appClockwork PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appClockwork
    PRIVATE Qt6::Quick)
install(TARGETS appClockwork

    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

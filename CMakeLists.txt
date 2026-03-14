cmake_minimum_required(VERSION 3.16)

project(ScreenTimeAnalyticalTool VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickEffects)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appScreenTimeAnalyticalTool
    main.cpp
    usagetracker.h usagetracker.cpp
)

set_source_files_properties(AppStyle.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appScreenTimeAnalyticalTool
    URI ScreenTimeAnalyticalTool
    QML_FILES
        Main.qml
        AppStyle.qml
    RESOURCES
        ic_dashboard.svg
        ic_apps.svg
        ic_time.svg
        ic_history.svg
        ic_settings.svg
        ic_target.svg
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appScreenTimeAnalyticalTool PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appScreenTimeAnalyticalTool
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appScreenTimeAnalyticalTool
    PRIVATE Qt6::Quick Qt6::QuickEffects Psapi
)

include(GNUInstallDirs)
install(TARGETS appScreenTimeAnalyticalTool
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

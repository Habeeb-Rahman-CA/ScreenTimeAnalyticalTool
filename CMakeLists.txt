cmake_minimum_required(VERSION 3.16)

project(ScreenTimeAnalyticalTool VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickEffects Sql Charts Widgets)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appScreenTimeAnalyticalTool
    src/main.cpp
    src/core/usagetracker.h src/core/usagetracker.cpp
    src/core/databasemanager.h src/core/databasemanager.cpp
)

set_source_files_properties(src/ui/Main.qml PROPERTIES 
    QT_QML_SINGLETON_TYPE FALSE
    QT_RESOURCE_ALIAS "Main.qml"
)
set_source_files_properties(src/ui/AppStyle.qml PROPERTIES 
    QT_QML_SINGLETON_TYPE TRUE
    QT_RESOURCE_ALIAS "AppStyle.qml"
)

qt_add_qml_module(appScreenTimeAnalyticalTool
    URI ScreenTimeAnalyticalTool
    VERSION 1.0
    QML_FILES
        src/ui/Main.qml
        src/ui/AppStyle.qml
    RESOURCES
        resources/icons/ic_dashboard.svg
        resources/icons/ic_apps.svg
        resources/icons/ic_time.svg
        resources/icons/ic_history.svg
        resources/icons/ic_settings.svg
        resources/icons/ic_target.svg
        resources/icons/ic_search.svg
        resources/icons/ic_bell.svg
        resources/icons/ic_user.svg
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
    PRIVATE Qt6::Quick Qt6::QuickEffects Qt6::Sql Qt6::Charts Qt6::Widgets Psapi
)

include(GNUInstallDirs)
install(TARGETS appScreenTimeAnalyticalTool
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

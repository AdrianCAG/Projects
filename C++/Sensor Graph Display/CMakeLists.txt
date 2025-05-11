cmake_minimum_required(VERSION 3.16)
project(SensorGraphDisplay VERSION 1.0 LANGUAGES CXX)

# Option to build tests
option(BUILD_TESTS "Build test suite" OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 COMPONENTS Core Gui Widgets REQUIRED)

set(PROJECT_SOURCES
    src/main.cpp
    src/mainwindow.cpp
    src/mainwindow.h
    src/graphwidget.cpp
    src/graphwidget.h
    src/droparea.cpp
    src/droparea.h
    src/sensordataparser.cpp
    src/sensordataparser.h
    src/detachedgraphwindow.cpp
    src/detachedgraphwindow.h
    src/pythonchartbridge.cpp
    src/pythonchartbridge.h
    src/pythongraphwidget.cpp
    src/pythongraphwidget.h
    src/pythondetachedgraphwindow.cpp
    src/pythondetachedgraphwindow.h
    resources/resources.qrc
)

add_executable(SensorGraphDisplay ${PROJECT_SOURCES})

target_link_libraries(SensorGraphDisplay PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
)

# Install the executable
install(TARGETS SensorGraphDisplay
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# If we are on macOS, set up the bundle
if(APPLE)
    set_target_properties(SensorGraphDisplay PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_GUI_IDENTIFIER com.example.sensorgraphdisplay
        MACOSX_BUNDLE_BUNDLE_NAME "Sensor Graph Display"
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    )
endif()

# Test suite configuration
if(BUILD_TESTS)
    # Find required packages for testing
    find_package(Qt6 COMPONENTS Test REQUIRED)
    
    # Enable testing with CTest
    enable_testing()
    
    # Add test executables
    add_executable(test_pythonchartbridge tests/test_pythonchartbridge.cpp
                                       src/pythonchartbridge.cpp
                                       src/pythonchartbridge.h
                                       src/sensordataparser.cpp
                                       src/sensordataparser.h)
    
    add_executable(test_pythongraphwidget tests/test_pythongraphwidget.cpp
                                        src/pythongraphwidget.cpp
                                        src/pythongraphwidget.h
                                        src/pythonchartbridge.cpp
                                        src/pythonchartbridge.h
                                        src/sensordataparser.cpp
                                        src/sensordataparser.h)
    
    add_executable(test_chart_generation_events tests/test_chart_generation_events.cpp
                                            src/pythongraphwidget.cpp
                                            src/pythongraphwidget.h
                                            src/pythonchartbridge.cpp
                                            src/pythonchartbridge.h
                                            src/sensordataparser.cpp
                                            src/sensordataparser.h)
    
    add_executable(test_resize_triggers tests/test_resize_triggers.cpp
                                      src/pythongraphwidget.cpp
                                      src/pythongraphwidget.h
                                      src/pythonchartbridge.cpp
                                      src/pythonchartbridge.h
                                      src/sensordataparser.cpp
                                      src/sensordataparser.h)
    
    # Link test executables with Qt libraries
    target_link_libraries(test_pythonchartbridge PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        Qt6::Test
    )
    
    target_link_libraries(test_pythongraphwidget PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        Qt6::Test
    )
    
    target_link_libraries(test_chart_generation_events PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        Qt6::Test
    )
    
    target_link_libraries(test_resize_triggers PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        Qt6::Test
    )
    
    # Add tests to CTest
    add_test(NAME TestPythonChartBridge COMMAND test_pythonchartbridge)
    add_test(NAME TestPythonGraphWidget COMMAND test_pythongraphwidget)
    add_test(NAME TestChartGenerationEvents COMMAND test_chart_generation_events)
    add_test(NAME TestResizeTriggers COMMAND test_resize_triggers)
    
    # Add Python tests
    add_test(NAME TestChartGenerator 
        COMMAND python3 ${CMAKE_CURRENT_SOURCE_DIR}/tests/test_chart_generator.py
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    
    # Set up the test environment
    set_tests_properties(TestPythonChartBridge TestPythonGraphWidget TestChartGenerator
        PROPERTIES ENVIRONMENT "PYTHONPATH=${CMAKE_CURRENT_SOURCE_DIR}/python")
    
    # Message indicating tests are enabled
    message(STATUS "Test suite enabled. Run 'make test' or 'ctest' to run tests.")
    message(STATUS "Or use the run_tests.sh script for more detailed output.")
endif()

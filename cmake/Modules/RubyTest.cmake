# RubyTest.cmake
# CMake module for running Ruby tests with minitest
#=============================================================================

# Run Ruby tests
# Usage: ruby_test(TEST_NAME test_file.rb [WORKING_DIR dir])
function(ruby_test)
    cmake_parse_arguments(RUBY_TEST
        ""
        "TEST_NAME;WORKING_DIR"
        ""
        ${ARGN}
    )

    if(NOT RUBY_TEST_TEST_NAME)
        message(FATAL_ERROR "ruby_test: TEST_NAME is required")
    endif()

    if(NOT RUBY_EXECUTABLE)
        message(FATAL_ERROR "ruby_test: Ruby executable not found")
    endif()

    set(TEST_FILE ${RUBY_TEST_TEST_NAME})

    # Check if file exists
    if(NOT EXISTS ${TEST_FILE})
        message(FATAL_ERROR "ruby_test: Test file not found: ${TEST_FILE}")
    endif()

    # Get directory of test file
    get_filename_component(TEST_DIR ${TEST_FILE} DIRECTORY)

    # Run the test
    execute_process(
        COMMAND ${RUBY_EXECUTABLE} ${TEST_FILE}
        WORKING_DIRECTORY ${RUBY_TEST_WORKING_DIR}
        RESULT_VARIABLE TEST_RESULT
        OUTPUT_VARIABLE TEST_OUTPUT
        ERROR_VARIABLE TEST_ERROR
        TIMEOUT 120
    )

    # Print output
    if(TEST_OUTPUT)
        message(STATUS "${TEST_OUTPUT}")
    endif()

    # Check result
    if(NOT TEST_RESULT EQUAL 0)
        message(FATAL_ERROR "Test failed with exit code: ${TEST_RESULT}")
    endif()

    message(STATUS "Test passed: ${TEST_FILE}")
endfunction()

# Run all tests in a directory
# Usage: ruby_test_all(DIRECTORY tests/unit [PATTERN "*.rb"])
function(ruby_test_all)
    cmake_parse_arguments(RUBY_TEST_ALL
        ""
        "DIRECTORY;PATTERN"
        ""
        ${ARGN}
    )

    if(NOT RUBY_TEST_ALL_DIRECTORY)
        message(FATAL_ERROR "ruby_test_all: DIRECTORY is required")
    endif()

    if(NOT RUBY_TEST_ALL_PATTERN)
        set(RUBY_TEST_ALL_PATTERN "*.rb")
    endif()

    # Find test files
    file(GLOB_RECURSE TEST_FILES
        "${RUBY_TEST_ALL_DIRECTORY}/${RUBY_TEST_ALL_PATTERN}"
    )

    if(NOT TEST_FILES)
        message(WARNING "No test files found in ${RUBY_TEST_ALL_DIRECTORY}")
        return()
    endif()

    message(STATUS "Found ${TEST_FILES} test files")

    # Run each test
    foreach(TEST_FILE ${TEST_FILES})
        ruby_test(
            TEST_NAME ${TEST_FILE}
            WORKING_DIR ${RUBY_TEST_ALL_DIRECTORY}
        )
    endforeach()
endfunction()

# Run tests using Bundler/Rake
# Usage: ruby_test_with_rake(TASK test:unit)
function(ruby_test_with_rake)
    cmake_parse_arguments(RUBY_TEST_RAKE
        ""
        "TASK"
        ""
        ${ARGN}
    )

    if(NOT RUBY_TEST_RAKE_TASK)
        set(RUBY_TEST_RAKE_TASK "test:unit")
    endif()

    if(NOT BUNDLE_EXECUTABLE)
        message(FATAL_ERROR "ruby_test_with_rake: Bundler not found")
    endif()

    if(NOT RAKE_EXECUTABLE)
        # Use bundle exec rake
        execute_process(
            COMMAND ${BUNDLE_EXECUTABLE} exec rake ${RUBY_TEST_RAKE_TASK}
            RESULT_VARIABLE TEST_RESULT
            OUTPUT_VARIABLE TEST_OUTPUT
            ERROR_VARIABLE TEST_ERROR
            TIMEOUT 300
        )
    else()
        # Use rake directly
        execute_process(
            COMMAND ${RAKE_EXECUTABLE} ${RUBY_TEST_RAKE_TASK}
            RESULT_VARIABLE TEST_RESULT
            OUTPUT_VARIABLE TEST_OUTPUT
            ERROR_VARIABLE TEST_ERROR
            TIMEOUT 300
        )
    endif()

    if(TEST_OUTPUT)
        message(STATUS "${TEST_OUTPUT}")
    endif()

    if(TEST_ERROR)
        message(STATUS "${TEST_ERROR}")
    endif()

    if(NOT TEST_RESULT EQUAL 0)
        message(FATAL_ERROR "Tests failed with exit code: ${TEST_RESULT}")
    endif()

    message(STATUS "All tests passed!")
endfunction()
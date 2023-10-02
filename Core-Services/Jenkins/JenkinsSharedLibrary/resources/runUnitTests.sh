#!/bin/bash

# Initialize an exit code variable
EXIT_CODE=0

# Function to run unit tests for Python code
run_python_tests() {
    local python_dir="Microservices/Python-App/src"
    echo "Running unit tests for Python code in directory: $python_dir"
    cd "$python_dir" || exit 1  # Change to the Python directory; exit on failure
    # Run the Python unit test command (e.g., pytest)
    # Replace the following line with your Python unit test command
    # pytest

    # Capture the exit code of the unit test command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Function to run unit tests for Go code
run_go_tests() {
    local go_dir="Microservices/Podinfo-Frontend-App/src"
    echo "Running unit tests for Go code in directory: $go_dir"
    cd "$go_dir" || exit 1  # Change to the Go directory; exit on failure
    # Run the Go unit test command (e.g., go test)
    # Replace the following line with your Go unit test command
    # go test

    # Capture the exit code of the unit test command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Run unit tests for both Python and Go code
run_python_tests
run_go_tests

exit $EXIT_CODE

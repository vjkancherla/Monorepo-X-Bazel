#!/bin/bash

# Initialize an exit code variable
EXIT_CODE=0

# Function to build and compile Python code
build_python() {
    local python_dir="Microservices/Python-App/src"
    echo "Building Python code in directory: $python_dir"
    cd "$python_dir" || exit 1  # Change to the Python directory; exit on failure
    # Run the Python build and compile command (e.g., python setup.py build)
    # Replace the following line with your Python build and compile command
    # python setup.py build

    # Capture the exit code of the build and compile command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Function to build and compile Go code
build_go() {
    local go_dir="Microservices/Podinfo-Frontend-App/src"
    echo "Building Go code in directory: $go_dir"
    cd "$go_dir" || exit 1  # Change to the Go directory; exit on failure
    # Run the Go build and compile command (e.g., go build)
    # Replace the following line with your Go build and compile command
    # go build

    # Capture the exit code of the build and compile command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Build and compile both Python and Go code
build_python
build_go

exit $EXIT_CODE

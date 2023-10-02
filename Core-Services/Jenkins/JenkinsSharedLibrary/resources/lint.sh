#!/bin/bash

# Initialize an exit code variable
EXIT_CODE=0

# Function to lint Python code
lint_python() {
    local python_dir="Microservices/Python-App/src"
    echo "Linting Python code in directory: $python_dir"
    cd "$python_dir" || exit 1  # Change to the Python directory; exit on failure
    # Run the Python linting command (e.g., flake8)
    # Replace the following line with your Python linting command
    # flake8 .

    # Capture the exit code of the linting command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Function to lint Go code
lint_go() {
    local go_dir="Microservices/Podinfo-Frontend-App/src"
    echo "Linting Go code in directory: $go_dir"
    cd "$go_dir" || exit 1  # Change to the Go directory; exit on failure
    # Run the Go linting command (e.g., golangci-lint)
    # Replace the following line with your Go linting command
    # For example: golangci-lint run ./...

    # Capture the exit code of the linting command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Run both linting functions
lint_python
lint_go

exit $EXIT_CODE

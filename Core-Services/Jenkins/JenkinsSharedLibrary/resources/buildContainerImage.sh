#!/bin/bash

# Assign variables from ENV VARS
python_image_tag="${PY_IMAGE_TAG}"
go_image_tag="${GOO_IMAGE_TAG}"

# Initialize an exit code variable
EXIT_CODE=0

# Function to build Docker images from Python code
build_python_docker_image() {
    local python_dir="Microservices/Python-App/src"
    echo "Building Docker image for Python code in directory: $python_dir"
    cd "$python_dir" || exit 1  # Change to the Python directory; exit on failure
    
    # Build the Docker image using the Dockerfile in this directory
    sudo docker build -t "$python_image_tag" -f Dockerfile .

    # Capture the exit code of the Docker build command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Function to build Docker images from Go code
build_go_docker_image() {
    local go_dir="Microservices/Podinfo-Frontend-App/src"
    echo "Building Docker image for Go code in directory: $go_dir"
    cd "$go_dir" || exit 1  # Change to the Go directory; exit on failure
    
    # Build the Docker image using the Dockerfile in this directory
    sudo docker build -t "$go_image_tag" -f Dockerfile .

    # Capture the exit code of the Docker build command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Call the functions to build Docker images
build_python_docker_image
build_go_docker_image

exit $EXIT_CODE

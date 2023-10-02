#!/bin/bash

# Assign variables from ENV VARS
full_python_image_tag="${PY_IMAGE_TAG}"
full_go_image_tag="${GOO_IMAGE_TAG}"

# Initialize an exit code variable
EXIT_CODE=0

# Function to run HELM DRY_RUN for Python App
helm_dry_run_for_python() {
    local python_dir="Microservices/Python-App/helm-chart"
    echo "Invoking HELM DRY_RUN for Python code in directory: $python_dir"
    cd "$python_dir" || exit 1  # Change to the Python directory; exit on failure

    repository=$(echo "$full_python_image_tag" | cut -d ':' -f 1)
    tag=$(echo "$inpufull_python_image_tagt" | cut -d ':' -f 2)
    
    helm upgrade --install helm-py-app-dev \
    -n ci-pr-"${tag:0:5}" \
    --create-namespace \
    --values namespaces/dev/values.yaml \
    --set image.repository=${repository()} \
    --set image.tag=${tag} \
    --debug --dry-run \
    .

    # Capture the exit code of the helm command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Function to run HELM DRY_RUN for Python App
helm_dry_run_for_go() {
    local go_dir="Microservices/Podinfo-Frontend-App/helm-chart"
    echo "Invoking HELM DRY_RUN for Go code in directory: $go_dir"
    cd "$go_dir" || exit 1  # Change to the Go directory; exit on failure
    
    repository=$(echo "$full_go_image_tag" | cut -d ':' -f 1)
    tag=$(echo "$full_go_image_tag" | cut -d ':' -f 2)

    helm upgrade --install helm-pi-fe-dev
    -n ci-pr-"${tag:0:5}" \
    --create-namespace \
    --values namespaces/dev/values.yaml \
    --set image.repository=${repository()} \
    --set image.tag=${tag} \
    --debug --dry-run \
    .

    # Capture the exit code of the helm command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Call the functions to build Docker images
helm_dry_run_for_python
helm_dry_run_for_go

exit $EXIT_CODE

#!/bin/bash

# Assign variables from ENV VARS
short_commit_hash="${COMMIT_HASH:0:5}"
namespace="ci-main-${short_commit_hash}"

# Initialize an exit code variable
EXIT_CODE=0

# Function to run test Python App
tests_for_python() {
    echo "Invoking Tests for Python code"

    deployment_name=$(kubectl get deployment -n ${namespace} -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "py-app")

    i=1
    while [ "$i" -le 30 ]; do
        if kubectl rollout status deployment/${deployment_name} -n ${namespace}; then
            echo "Deployment is ready!"
            break
        elif [ "$i" -eq 30 ]; then
            echo "Deployment failed to become ready within the expected time."
            exit 1
        else
            echo "Waiting for Deployment to become ready..."
            sleep 5
            i=$((i+5))
        fi
    done

    service_name=$(kubectl get service -n ${namespace} -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "py-app")

    kubectl run -n ${namespace} curl --image=curlimages/curl -i --rm --restart=Never -- curl http://${service_name}:80

    # Capture the exit code of the helm command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Function to run test Python App
tests_for_go()) {
    echo "Invoking Tests for GO code"

    deployment_name=$(kubectl get deployment -n ${namespace} -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "frontend-podinfo")

    i=1
    while [ "$i" -le 30 ]; do
        if kubectl rollout status deployment/${deployment_name} -n ${namespace}; then
            echo "Deployment is ready!"
            break
        elif [ "$i" -eq 30 ]; then
            echo "Deployment failed to become ready within the expected time."
            exit 1
        else
            echo "Waiting for Deployment to become ready..."
            sleep 5
            i=$((i+5))
        fi
    done

    service_name=$(kubectl get service -n ${namespace} -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "frontend-podinfo")

    kubectl run -n ${namespace} curl --image=curlimages/curl -i --rm --restart=Never -- curl http://${service_name}:9898

    # Capture the exit code of the helm command and update the overall exit code
    dir_exit_code=$?
    if [ "$dir_exit_code" -ne 0 ]; then
        EXIT_CODE=$dir_exit_code
    fi

    cd -  # Return to the previous directory
}

# Call the functions to build Docker images
tests_for_go
tests_for_python

exit $EXIT_CODE


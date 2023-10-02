#!/bin/bash

# Read the namespace from the environment variable
NAMESPACE="$NAMESPACE_ENV_VAR"

# Confirm that the namespace variable is not empty
if [ -z "$NAMESPACE" ]; then
  echo "Namespace environment variable (NAMESPACE_ENV_VAR) is empty. Please set the variable."
  exit 1
fi

# Initialize an exit code variable
EXIT_CODE=0

# Function to delete all resources in the specified namespace
delete_all_resources() {
  echo "Deleting all resources in namespace $NAMESPACE..."
  kubectl delete all --all -n "${NAMESPACE}"
  
  # Capture the exit code of the kubectl delete command and update the overall exit code
  local delete_exit_code=$?
  if [ "$delete_exit_code" -ne 0 ]; then
    EXIT_CODE=$delete_exit_code
  fi
}

# Execute the function to delete all resources
delete_all_resources

# Return the exit code based on the success or failure of resource deletion
exit $EXIT_CODE

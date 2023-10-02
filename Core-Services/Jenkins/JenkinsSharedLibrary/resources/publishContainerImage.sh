#!/bin/bash

# Assign variables from ENV VARS
python_image_tag="${PY_IMAGE_TAG}"
go_image_tag="${GOO_IMAGE_TAG}"
dockerhub_user="${DOCKER_USERNAME}"
dockerhub_pwd="${DOCKER_PASSWORD}"

# Initialize an exit code variable
EXIT_CODE=0

# login to DocherHub
echo ${dockerhub_pwd} | sudo docker login -u ${dockerhub_user} --password-stdin

# Push the Python Docker image
sudo docker push "$python_image_tag"
if [ $? -ne 0 ]; then
    EXIT_CODE=1  # Update the exit code if push fails
fi

# Push the Go Docker image
sudo docker push "$go_image_tag"
if [ $? -ne 0 ]; then
    EXIT_CODE=1  # Update the exit code if push fails
fi

exit $EXIT_CODE


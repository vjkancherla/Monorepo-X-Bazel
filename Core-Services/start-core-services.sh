#!/bin/bash

# Automatically identify the username
username=$(whoami)

# Function to print and highlight the current step
function print_step {
  local step_name=$1
  local yellow=$(tput setaf 3) # Yellow text color
  local reset=$(tput sgr0)     # Reset text color
  echo "${yellow}--- Running Step: $step_name ---${reset}"
}

# Step 1: Start Docker desktop
print_step "Start Docker desktop"
open -a Docker

# Step 1.1: Verify that Docker desktop has started correctly
# Wait for Docker to start (you can adjust the sleep duration as needed)
sleep 10
docker info >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "Error: Docker desktop did not start correctly."
  exit 1
else
  echo "Docker desktop started successfully."
fi

# Step 2: Start K3D cluster
print_step "Start K3D cluster"
create_cluster_attempt=1
create_cluster_max_attempts=3

while [[ $create_cluster_attempt -le $create_cluster_max_attempts ]]; do
  k3d cluster create mycluster -a 1 --subnet 172.19.0.0/16
  if [[ $? -eq 0 ]]; then
    echo "K3D cluster created successfully."
    break
  else
    k3d_cluster_error=$(k3d cluster create mycluster -a 1 2>&1)
    if [[ $k3d_cluster_error == *"Failed to create cluster 'mycluster' because a cluster with that name already exists"* ]]; then
      echo "K3D cluster 'mycluster' already exists. Stopping and retrying... (Attempt $create_cluster_attempt of $create_cluster_max_attempts)"
      k3d cluster delete mycluster
      ((create_cluster_attempt++))
    else
      echo "Error: K3D cluster creation failed."
      exit 1
    fi
  fi
done

if [[ $create_cluster_attempt -gt $create_cluster_max_attempts ]]; then
  echo "Error: Failed to create K3D cluster after $create_cluster_max_attempts attempts."
  exit 1
fi

# Step 3: Verify that K3D cluster has started correctly
k3d_cluster_ready=false
max_attempts=30
attempt=1

while [[ $attempt -le $max_attempts ]]; do
  cluster_info=$(kubectl cluster-info 2>&1)
  if [[ $cluster_info == *"is running at"* ]]; then
    echo "K3D cluster started successfully."
    k3d_cluster_ready=true
    break
  else
    echo "Waiting for K3D cluster to start... (Attempt $attempt of $max_attempts)"
    sleep 5
    ((attempt++))
  fi
done

if [[ $k3d_cluster_ready == false ]]; then
  echo "Error: K3D cluster did not start correctly."
  exit 1
fi

# Step 4: Identify K3D's k3d-mycluster-server-0 docker container's IP
k3d_mycluster_server_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3d-mycluster-server-0)
echo "K3D server IP address: $k3d_mycluster_server_ip"

# Step 5: Start Jenkins in detached mode
print_step "Start Jenkins in detached mode"
docker run -d --name jenkins-docker \
-p 8080:8080 -p 50000:50000 \
-v /Users/${username}/Downloads/jenkins-volume:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
--network=k3d-mycluster \
--ip 172.19.0.6 \
-e TZ=Asia/Kolkata \
vjkancherla/my-jenkins:v1

# Step 6: Start SonarQube in detached mode
print_step "Start SonarQube in detached mode"
docker run -d --name sonarqube \
-p 9000:9000 -p 9092:9092 \
-v /Users/${username}/Downloads/sonarqube-volume:/opt/sonarqube/data \
--network=k3d-mycluster \
--ip 172.19.0.7 \
-e TZ=Asia/Kolkata \
sonarqube:lts-community

# Step 7: Start JFrog Artifactory in detached mode
print_step "Start JFrog Artifactory in detached mode"
docker run -d --name jfrog-artifactory \
-p 8081:8081 -p 8082:8082 \
-v /Users/${username}/Downloads/jfrog-artifactory-volume:/var/opt/jfrog/artifactory \
--network=k3d-mycluster \
--ip 172.19.0.8 \
-e TZ=Asia/Kolkata \
docker.bintray.io/jfrog/artifactory-oss:latest

# Step 8: Verify Jenkins, SonarQube, and JFrog Artifactory containers
jenkins_status=$(docker inspect -f '{{.State.Status}}' jenkins-docker)
sonarqube_status=$(docker inspect -f '{{.State.Status}}' sonarqube)
artifactory_status=$(docker inspect -f '{{.State.Status}}' jfrog-artifactory)

if [[ $jenkins_status == "running" && $sonarqube_status == "running" && $artifactory_status == "running" ]]; then
  echo "Jenkins, SonarQube, and JFrog Artifactory containers have started successfully."
else
  echo "Error: Jenkins, SonarQube, and/or JFrog Artifactory containers failed to start."
fi

# # Step 9: Get SonarQube server IP address
# sonarqube_server_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube)
# echo "SonarQube server IP address: $sonarqube_server_ip"

# Step 10: Copy ~/.kube/config to k3d-kubeconfig
print_step "Copy ~/.kube/config to k3d-kubeconfig"
cp ~/.kube/config k3d-kubeconfig

# Step 11: Update k3d-kubeconfig with the correct server IP
print_step "Update k3d-kubeconfig with the correct server IP"
sed -i '' "s|server: .*|server: https://$k3d_mycluster_server_ip:6443|g" k3d-kubeconfig

# ANSI escape codes for text color
green=$(tput setaf 2)  # Green text color
yellow=$(tput setaf 3) # Yellow text color
reset=$(tput sgr0)     # Reset text color

# Print the instructions in highlighted color
echo ""
echo ""
echo "${green}Instructions:${reset}"
echo "${yellow}1. Create/Update Jenkins Global Credential as follows:${reset}"
echo "${yellow}   Type: secret file${reset}"
echo "${yellow}   ID: \"k3d-config\"${reset}"
echo "${yellow}   File: $(pwd)/k3d-kubeconfig${reset}"
echo ""
echo "${yellow}   If required, delete any existing credential with ID -  k3d-config - and create a new one.${reset}"

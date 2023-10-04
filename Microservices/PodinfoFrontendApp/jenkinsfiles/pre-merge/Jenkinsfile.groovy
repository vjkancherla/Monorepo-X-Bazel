def getImageRepo() {
  return "${env.REGISTRY_USER}/podinfo_application_jenkins"
}

def getFullImageTag() {
    return "${getImageRepo()}:${env.GIT_COMMIT_HASH}"
}

stage("SonarQube-Analysis") {
  dir('Microservices/Podinfo-Frontend-App/src') {
      script {
           withSonarQubeEnv(installationName: 'SonarQube-on-Docker') {
              // Run the SonarScanner for your project with the stored token
              sh "sonar-scanner"
          }

          timeout(time: 2, unit: 'MINUTES') {
           def qg = waitForQualityGate()
           if (qg.status != 'OK') {
             error "Pipeline aborted due to quality gate failure: ${qg.status}"
           }
         }
      }
  }
}

stage("Package-Image") {
  dir('Microservices/Podinfo-Frontend-App/src')
  {
    script {
        echo "Environment variables:"
        echo "PROJECT: ${env.PROJECT}"
        echo "REGISTRY_USER: ${env.REGISTRY_USER}"
        echo "GIT_COMMIT_HASH: ${env.GIT_COMMIT_HASH}"
        echo "IMAGE_REPO: ${env.IMAGE_REPO}"
        echo "IMAGE_TAG: ${env.IMAGE_TAG}"

        sh "sudo docker build -t ${getFullImageTag()} -f Dockerfile ."
    }
  }
}

stage("Push-Image-To-DockerHub") {
  script {
    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
        sh """
            echo ${DOCKER_PASSWORD} | sudo docker login -u ${DOCKER_USERNAME} --password-stdin
            sudo docker push ${getFullImageTag()}
        """
    }
  }
}

stage('Deploy App to K3D Dev') {
  dir('Microservices/Podinfo-Frontend-App/helm-chart') {
      script {
        withCredentials([file(credentialsId: 'k3d-config', variable: 'KUBECONFIG')]) {
          sh """
            export KUBECONFIG=${KUBECONFIG}
            helm upgrade --install helm-pi-fe-dev -n dev --create-namespace \
            --values namespaces/dev/values.yaml \
            --set image.repository=${getImageRepo()} \
            --set image.tag=${env.GIT_COMMIT_HASH} \
            .
          """
        }
      }
  }
}

stage('Test App in K3D Dev') {
  script {
      withCredentials([file(credentialsId: 'k3d-config', variable: 'KUBECONFIG')]) {
          sh script: '''
              export KUBECONFIG=${KUBECONFIG}

              deployment_name=$(kubectl get deployment -n dev -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "frontend-podinfo")

              i=1
              while [ "$i" -le 30 ]; do
                  if kubectl rollout status deployment/${deployment_name} -n dev; then
                      echo "Deployment is ready!"
                      break
                  elif [ "$i" -eq 30 ]; then
                      echo "Deployment failed to become ready within the expected time."
                      currentBuild.result = 'FAILURE'
                      exit 1
                  else
                      echo "Waiting for Deployment to become ready..."
                      sleep 5
                      i=$((i+5))
                  fi
              done

              service_name=$(kubectl get service -n dev -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "podinfo")

              kubectl run -n dev curl --image=curlimages/curl -i --rm --restart=Never -- curl http://${service_name}:9898
          '''
      }
  }
}

stage('[Optional] Delete K3D Dev Helm Release') {
  script {
    try {
      // timeout(time: 30, unit: 'SECONDS') {
      //   input message: 'Do you want to delete the helm release?', ok: 'Yes'
      // }
      withCredentials([file(credentialsId: 'k3d-config', variable: 'KUBECONFIG')]) {
        sh """
          export KUBECONFIG=${KUBECONFIG}
          helm delete helm-pi-fe-dev -n dev
        """
      }
    } catch (Exception e) {
      // echo 'User did not respond within 30 seconds. Proceeding with default behavior.'
      println "Exception Message: ${e.getMessage()}"
      // Fail the pipeline
      error("Pipeline failed due to an exception")
    }
  }
}

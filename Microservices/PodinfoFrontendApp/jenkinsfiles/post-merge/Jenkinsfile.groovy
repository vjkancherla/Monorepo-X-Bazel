#!/usr/bin/groovy

pipeline {
  agent {
    kubernetes {
      yamlFile "jenkinsfiles/jenkins-agent-pod.yaml"
    }
  }

  options {
      disableConcurrentBuilds()
  }

  environment {
    PROJECT = "jenkins-demo"
    REGISTRY_USER = "vjkancherla"
    GIT_COMMIT_HASH = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true)
    IMAGE_REPO = "vjkancherla/podinfo_application_jenkins"
    IMAGE_TAG = "${GIT_COMMIT_HASH}"
  }

  stages  {
    stage("Build") {
      steps {
        package_and_push_image()
      }
    }

    stage("Deploy-To-UAT") {
      when {
        // skip this stage unless on main branch
        branch "main"
      }
      steps {
        approve_deploy("uat")
        deploy("uat")
      }
    }

    stage("Verify-Deployment-To-UAT") {
      when {
        // skip this stage unless on main branch
        branch "main"
      }
      steps {
        verify_deployment("uat")
      }
    }

    stage("Deploy-To-Canary") {
      when {
        // skip this stage unless on main branch
        branch "main"
        expression {
          check_prod_deploy_exists()
        }
      }
      steps {
        approve_deploy("canary")
        deploy("canary")
      }
    }

    stage("Verify-Deployment-To-Canary") {
      when {
        // skip this stage unless on main branch
        branch "main"
        expression {
          check_prod_deploy_exists()
        }
      }
      steps {
        verify_deployment("prod")
      }
    }

    stage("Deploy-To-Prod") {
      when {
        // skip this stage unless on main branch
        branch "main"
      }
      steps {
        approve_deploy("prod")
        deploy("prod")
      }
    }

    stage("Verify-Deployment-To-Prod") {
      when {
        // skip this stage unless on main branch
        branch "main"
      }
      steps {
        verify_deployment("prod")
      }
    }

  }
}

def package_and_push_image() {
  container("kaniko") {
    sh "/kaniko/executor --context `pwd`/podinfo-application-frontend --dockerfile Dockerfile --destination ${IMAGE_REPO}:${IMAGE_TAG}"
  }
}

def deploy(env) {
  container("k8s") {
    sh "helm upgrade --install -n ${env} --create-namespace --values helm-chart-podinfo-frontend/namespaces/${env}/values.yaml --set image.repository=${IMAGE_REPO} --set image.tag=${IMAGE_TAG} helm-pi-fe-${env} helm-chart-podinfo-frontend/"
  }
}

def approve_deploy(env) {
  timeout(time:1, unit:'HOURS') {
		input("Approve deploy to ${env}")
	}
}

def verify_deployment(env) {
  sleep(30)
  container("k8s") {
    sh "kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl frontend-podinfo-${env}.${env}.svc.cluster.local:9898"
  }
}

def check_prod_deploy_exists() {
  container("k8s") {
    prod_ns_exists = sh(script:"kubectl get ns prod", returnStatus: true)
    println("prod_ns_exists: ${prod_ns_exists}")
    if (prod_ns_exists == 0) {
      return true
    }
    println("THERE IS NO PROD DEPLOYMENT YET. SKIP CANARY")
    return false
  }
}

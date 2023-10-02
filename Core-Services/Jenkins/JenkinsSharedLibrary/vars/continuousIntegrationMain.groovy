
def call() {
    REGISTRY_USER = "vjkancherla"
    PYTHON_IMAGE_REPO = "${REGISTRY_USER}/python_app_jenkins"
    GO_IMAGE_REPO = "${REGISTRY_USER}/go_app_jenkins"
    PYTHON_IMAGE_TAG = ""
    GO_IMAGE_TAG = ""
    GIT_COMMIT_HASH = ""
    
    pipeline {
        agent any
        
        stages {
            
            stage('Lint Code') {
                steps {
                    sh(libraryResource('lint.sh'))
                }
            }

            stage('Compile and Build Code') {
                steps {
                    sh(libraryResource('buildAndCompile.sh'))
                }
            }

            stage('Unit Tests') {
                steps {
                    sh(libraryResource('runUnitTests.sh'))
                }
            }

            stage('Static Code Analysis') {
                steps {
                    script {
                        withSonarQubeEnv(installationName: 'SonarQube-on-Docker') {
                            // sonarEnvVars = env
                            sh(libraryResource('sonarScanner.sh'))
                        }

                        timeout(time: 2, unit: 'MINUTES') {
                            def qG = waitForQualityGate()
                            if (qG.status != 'OK') {
                                error "Pipeline aborted due to quality gate failure: ${qG.status}"
                            }
                        }
                    }
                }                  
            }

            stage('Build Container') {
                steps {
                    script {
                        GIT_COMMIT_HASH = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true)
                        PYTHON_IMAGE_TAG = "${PYTHON_IMAGE_REPO}:${GIT_COMMIT_HASH}"
                        GO_IMAGE_TAG = "${GO_IMAGE_REPO}:${GIT_COMMIT_HASH}"

                        println("${PYTHON_IMAGE_TAG} :: ${GO_IMAGE_TAG}")
                        
                        withEnv(["PY_IMAGE_TAG=${PYTHON_IMAGE_TAG}", "GOO_IMAGE_TAG=${GO_IMAGE_TAG}"]) {
                            sh(libraryResource('buildContainerImage.sh'))
                        }
                    }
                }
            }

            stage('Scan Container Image') {
                steps {
                    echo "Scanning the built container images locally."
                }
            }

            stage('Push Container to Docker Hub') {
                steps {
                    println("${PYTHON_IMAGE_TAG} :: ${GO_IMAGE_TAG}")

                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        withEnv(["PY_IMAGE_TAG=${PYTHON_IMAGE_TAG}", "GOO_IMAGE_TAG=${GO_IMAGE_TAG}"]) {
                            sh(libraryResource('publishContainerImage.sh'))
                        }
                    
                    }
                }
            }

            stage('Deploy Apps using Helm') {
                steps {
                    withCredentials([file(credentialsId: 'k3d-config', variable: 'KUBECONFIG')]) {
                        withEnv(["PY_IMAGE_TAG=${PYTHON_IMAGE_TAG}", "GOO_IMAGE_TAG=${GO_IMAGE_TAG}"]) {
                            sh(libraryResource('helmWetRun.sh'))
                        }
                    }
                }
            }
            
            stage('Run TestSuite: Integration tests') {
                 steps {
                    withCredentials([file(credentialsId: 'k3d-config', variable: 'KUBECONFIG')]) {
                        withEnv(["COMMIT_HASH=${GIT_COMMIT_HASH}"]) {
                            sh(libraryResource('runTestSuite.sh'))
                        }
                    }
                }
            }

            stage('TearDown NS') {
                steps {
                    withCredentials([file(credentialsId: 'k3d-config', variable: 'KUBECONFIG')]) {
                        withEnv(["NAMESPACE_ENV_VAR=ci-main-${GIT_COMMIT_HASH}.substring(0, 4)"]) {
                            sh(libraryResource('teardownNamespace.sh'))
                        }
                    }
                }
            }
        }
    
    }
}
pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {
          IMAGE_NAME       = 'petclinic'
          IMAGE_TAG        = 'latest'
          TENANT_ID        = '6bb8aa1e-d7a1-4e0d-aae3-073137d6fded'
          ACR_NAME         = 'ekampetclinic'
          ACR_LOGIN_SERVER = 'ekampetclinic.azurecr.io'
          FULL_IMAGE_NAME  = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
          RG               = 'petclinic-rg'
          AKS_NAME         = 'myAKSCluster'
      }

        stages {
            stage('Checkout'){
                steps {
                    git branch: 'main',
                        url: 'https://github.com/bhat0155/spring-petclinic.git'
                }
            }

            stage('Maven Build'){
                steps {
                    sh 'mvn compile'
                }
            }

            stage('Unit Test'){
                steps {
                    sh 'mvn test'
                }
            }

             stage('Artifact Packaging'){
                steps {
                    sh 'mvn package -DskipTests'
                }
            }

             stage('SonarQube Analysis') {
                  steps {
                      withSonarQubeEnv('sonarserver') {
                          withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_TOKEN')]) {
                              sh """
                                  mvn sonar:sonar \
                                  -Dsonar.host.url=https://sonarcloud.io \
                                  -Dsonar.organization=spring-petclinic-ekam \
                                  -Dsonar.projectKey=spring-petclinic-ekam_jenkins-cicd \
                                  -Dsonar.token=\$SONAR_TOKEN \
                                  -DskipTests
                              """
                          }
                      }
                  }
              }
        }
}
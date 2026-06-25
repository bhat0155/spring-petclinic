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
              stage('Quality Gate') {
                  steps {
                      withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_TOKEN')]) {
                          sh """
                              sleep 15
                              STATUS=\$(curl -s -u \$SONAR_TOKEN: \
                                  "https://sonarcloud.io/api/qualitygates/project_status?projectKey=spring-petclinic-ekam_jenkins-cicd" \
                                  | python3 -c "import sys,json; print(json.load(sys.stdin)['projectStatus']['status'])")
                              echo "Quality Gate status: \$STATUS"
                              if [ "\$STATUS" != "OK" ]; then
                                  echo "Quality Gate FAILED"
                                  exit 1
                              fi
                          """
                      }
                  }
              }
              stage('Docker Build'){
                steps{
                    sh "docker buildx build --platform linux/arm64 -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
              }
              stage('Trivy Scan'){
                steps {
                    sh "trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}"
                }
              }
               stage('Push to ACR') {
                  steps {
                      withCredentials([usernamePassword(
                          credentialsId: 'azure-acr-spn',
                          usernameVariable: 'AZURE_USERNAME',
                          passwordVariable: 'AZURE_PASSWORD'
                      )]) {
                          sh """
                              az login --service-principal \
                                  -u \$AZURE_USERNAME \
                                  -p \$AZURE_PASSWORD \
                                  --tenant ${TENANT_ID}

                              az acr login --name ${ACR_NAME}

                              docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}
                              docker push ${FULL_IMAGE_NAME}
                          """
                      }
                  }
              }

              stage('Deploy to AKS') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'azure-acr-spn',
            usernameVariable: 'AZURE_USERNAME',
            passwordVariable: 'AZURE_PASSWORD'
        )]) {
            sh """
                az login --service-principal \
                    -u \$AZURE_USERNAME \
                    -p \$AZURE_PASSWORD \
                    --tenant ${TENANT_ID}

                az aks get-credentials \
                    --resource-group ${RG} \
                    --name ${AKS_NAME} \
                    --overwrite-existing

                kubectl apply -f k8s/db.yml
                kubectl apply -f k8s/petclinic.yml
                kubectl rollout restart deployment/petclinic-app
                kubectl rollout status deployment/petclinic-app --timeout=300s || {
                    echo "=== Pod Status ==="
                    kubectl get pods -l app=petclinic-app
                    echo "=== Pod Events ==="
                    kubectl describe pods -l app=petclinic-app | tail -30
                    exit 1
                }
            """
        }
    }
}

        }
}
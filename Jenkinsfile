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
            
        }
}
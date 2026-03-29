@Library('Shared') _
pipeline {
    agent any

    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: 'v1', description: 'Frontend image tag')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: 'v1', description: 'Backend image tag')
    }

    environment {
        SONAR_HOME = tool "Sonar"
        DOCKERHUB_USER = "sachitrrazdan1710"
    }

    stages {

        stage("Validate Parameters") {
            steps {
                script {
                    if (params.FRONTEND_DOCKER_TAG == '' || params.BACKEND_DOCKER_TAG == '') {
                        error("Both image tags must be provided.")
                    }
                }
            }
        }

        stage("Workspace Cleanup") {
            steps {
                cleanWs()
            }
        }

        stage("Git Checkout") {
            steps {
                script {
                    clone("https://github.com/sachitrrazdan1710/Wanderlust-Mega-Project.git","devops")
                }
            }
        }

        stage("Trivy: Filesystem Scan") {
            steps {
                script {
                    trivy_scan()
                }
            }
        }

        stage("OWASP: Dependency Check") {
            steps {
                script {
                    owasp_dependency()
                }
            }
        }

        stage("SonarQube: Code Analysis") {
            steps {
                script {
                    sonarqube_analysis("Sonar","wanderlust","wanderlust")
                }
            }
        }

        stage("SonarQube: Quality Gate") {
            steps {
                script {
                    sonarqube_code_quality()
                }
            }
        }

        stage("Docker: Build Images") {
            steps {
                script {
                    dir('backend') {
                        docker_build("wanderlust-backend", "${params.BACKEND_DOCKER_TAG}", "${DOCKERHUB_USER}")
                    }
                    dir('frontend') {
                        docker_build("wanderlust-frontend", "${params.FRONTEND_DOCKER_TAG}", "${DOCKERHUB_USER}")
                    }
                }
            }
        }

        stage("Trivy: Image Scan") {
            steps {
                script {
                    sh """
                    trivy image ${DOCKERHUB_USER}/wanderlust-backend:${params.BACKEND_DOCKER_TAG}
                    trivy image ${DOCKERHUB_USER}/wanderlust-frontend:${params.FRONTEND_DOCKER_TAG}
                    """
                }
            }
        }

        stage("Docker: Push to DockerHub") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                    echo $PASS | docker login -u $USER --password-stdin

                    docker push ${DOCKERHUB_USER}/wanderlust-backend:${params.BACKEND_DOCKER_TAG}
                    docker push ${DOCKERHUB_USER}/wanderlust-frontend:${params.FRONTEND_DOCKER_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            build job: "Wanderlust-CD", parameters: [
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG}")
            ]
        }
    }
}

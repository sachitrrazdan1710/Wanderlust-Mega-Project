@Library('Shared') _
pipeline {
    agent none

    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: 'v1', description: 'Frontend image tag')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: 'v1', description: 'Backend image tag')
    }

    stages {

        stage("Validate Parameters") {
            agent any
            steps {
                script {
                    if (params.FRONTEND_DOCKER_TAG == '' || params.BACKEND_DOCKER_TAG == '') {
                        error("Both image tags must be provided.")
                    }
                }
            }
        }

        stage("Workspace Cleanup") {
            agent any
            steps {
                cleanWs()
            }
        }

        stage("Git Checkout") {
            agent { label 'master-node' }
            steps {
                script {
                    clone("https://github.com/sachitrrazdan1710/Wanderlust-Mega-Project.git","devops")
                }
                stash name: 'source-code', includes: '**/*'
            }
        }

        stage("Trivy: Filesystem Scan") {
            agent { label 'docker-agent' }
            steps {
                unstash 'source-code'
                script {
                    trivy_scan()
                }
            }
        }

        stage("Backend Docker Build") {
            agent { label 'docker-agent' }
            steps {
                unstash 'source-code'
                script {
                    dir('backend') {
                        docker_build(
                            "wanderlust-backend",
                            "${params.BACKEND_DOCKER_TAG}",
                            "sachitrrazdan1710"
                        )
                    }
                }
            }
        }

        stage("Frontend Build (Host)") {
            agent { label 'master-node' }
            steps {
                unstash 'source-code'
                script {
                    dir('frontend') {
                        sh 'cp .env.docker .env || true'
                        sh 'npm install'
                        sh 'npm run build'
                    }
                }
            }
        }

        stage("Frontend Docker Build") {
            agent { label 'docker-agent' }
            steps {
                unstash 'source-code'
                script {
                    dir('frontend') {
                        docker_build(
                            "wanderlust-frontend",
                            "${params.FRONTEND_DOCKER_TAG}",
                            "sachitrrazdan1710"
                        )
                    }
                }
            }
        }

       stage("Trivy: Image Scan") {
    agent { label 'docker-agent' }
    steps {
        script {
            sh """
            set +e

            echo "Scanning backend image..."
            trivy image --severity HIGH,CRITICAL \
            --scanners vuln \
            --exit-code 0 \
            --timeout 10m \
            sachitrrazdan1710/wanderlust-backend:${params.BACKEND_DOCKER_TAG}

            echo "Scanning frontend image..."
            trivy image --severity HIGH,CRITICAL \
            --scanners vuln \
            --exit-code 0 \
            --timeout 10m \
            sachitrrazdan1710/wanderlust-frontend:${params.FRONTEND_DOCKER_TAG}

            exit 0
            """
        }
    }
}
        stage("Docker: Push to DockerHub") {
            agent { label 'docker-agent' }
            steps {
                script {

                    docker_push(
                        imageName: "sachitrrazdan1710/wanderlust-backend",
                        imageTag: "${params.BACKEND_DOCKER_TAG}"
                    )

                    docker_push(
                        imageName: "sachitrrazdan1710/wanderlust-frontend",
                        imageTag: "${params.FRONTEND_DOCKER_TAG}"
                    )
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

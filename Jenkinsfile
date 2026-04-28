@Library('Shared') _
pipeline {
    agent none

    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: '', description: 'Frontend image tag')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: '', description: 'Backend image tag')
    }
    
    stages {

          stage("Validate Parameters") {
            agent any
            steps {
                script {
                    if (!params.FRONTEND_DOCKER_TAG?.trim() || !params.BACKEND_DOCKER_TAG?.trim()) {
                        error("Both FRONTEND_DOCKER_TAG and BACKEND_DOCKER_TAG must be provided.")
                    }
                    echo "Frontend tag: ${params.FRONTEND_DOCKER_TAG}"
                    echo "Backend tag: ${params.BACKEND_DOCKER_TAG}"
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
                    clone("https://github.com/sachitrrazdan1710/Wanderlust-Mega-Project.git", "devops")
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
                        sh '''
                        cp .env.docker .env || true
                        npm install
                        npm run build
                        '''
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
         failure {
             node('docker-agent'){
        withCredentials([usernamePassword(
            credentialsId: 'servicenow-creds',
            usernameVariable: 'SN_USER',
            passwordVariable: 'SN_PASS'
        )]) {
            sh '''
            curl -X POST "https://dev392424.service-now.com/api/now/table/incident" \
              --user "$SN_USER:$SN_PASS" \
              --header "Content-Type: application/json" \
              --data "{
                \\"short_description\\": \\"Wanderlust CI Pipeline Failed\\",
                \\"description\\": \\"Job: $JOB_NAME | Build: $BUILD_NUMBER | URL: $BUILD_URL\\",
                \\"urgency\\": \\"2\\",
                \\"impact\\": \\"2\\"
              }"
            '''
          }
       }
     }
   }
 }

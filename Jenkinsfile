
pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REGISTRY = '207235249613.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPOSITORY = 'calculator-app'
        IMAGE_TAG = "ci-${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }


        stage('Check Commit Message') {
            steps {
                script {
                    def message = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()

                    env.SKIP_GITOPS_ONLY = message.contains('[gitops skip]') ? 'true' : 'false'

                    if (env.SKIP_GITOPS_ONLY == 'true') {
                        echo 'GitOps-only commit detected. Skipping CI build.'
                    }
                }
            }
        }

        stage('Maven Build and Test') {
            when { expression { env.SKIP_GITOPS_ONLY != 'true' } }
            steps {
                sh 'mvn -B clean verify'
            }
        }

        stage('SonarQube Scan and Quality Gate') {
            when { expression { env.SKIP_GITOPS_ONLY != 'true' } }
            steps {
                withSonarQubeEnv('SonarCloud') {
                    withCredentials([
                        string(
                            credentialsId: 'sonarqube-token',
                            variable: 'SONAR_TOKEN'
                        )
                    ]) {
                        sh '''
                            mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:5.5.0.6356:sonar \
                              -Dsonar.projectKey=Loky22p_devops-cicd-assignment-Copy \
                              -Dsonar.organization=loky22p \
                              -Dsonar.qualitygate.wait=true \
                              -Dsonar.qualitygate.timeout=300
                        '''
                    }
                }
            }
        }

        stage('Docker Build') {
            when { expression { env.SKIP_GITOPS_ONLY != 'true' } }
            steps {
                sh '''
                    docker build -t calculator-app:${IMAGE_TAG} .
                    docker images calculator-app
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            when { expression { env.SKIP_GITOPS_ONLY != 'true' } }
            steps {
                sh '''
                    set -eu

                    export DOCKER_CONFIG="$(mktemp -d)"
                    trap 'rm -rf "$DOCKER_CONFIG"' EXIT

                    aws ecr get-login-password --region "$AWS_REGION" | \
                      docker login --username AWS --password-stdin "$ECR_REGISTRY"

                    docker tag "calculator-app:${IMAGE_TAG}" \
                      "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

                    docker push \
                      "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                '''
            }
        }

        stage('Update GitOps Image Tag') {
            when { expression { env.SKIP_GITOPS_ONLY != 'true' } }
            steps {
                withCredentials([
                    string(
                        credentialsId: 'github-gitops-token',
                        variable: 'GITHUB_TOKEN'
                    )
                ]) {
                    sh 'bash scripts/update-gitops-image.sh'
                }
            }
        }

    }

    post {
        always {
            junit allowEmptyResults: true,
                  testResults: 'target/surefire-reports/*.xml'
        }

        success {
            echo "CI/CD Pipeline SUCCESS!"
            script {
                if (env.SKIP_GITOPS_ONLY == 'true') {
                    echo 'GitOps-only commit. Docker build skipped.'
                } else {
                    echo "Docker image pushed to AWS ECR."
                    echo "Image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }

        failure {
            echo 'CI/CD Pipeline FAILED. Check console output.'
        }
    }
}

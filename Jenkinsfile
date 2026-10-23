
pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build and Test') {
            steps {
                sh 'mvn -B clean verify'
            }
        }

        stage('SonarQube Scan and Quality Gate') {
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
    }

    post {
        always {
            junit allowEmptyResults: true,
                  testResults: 'target/surefire-reports/*.xml'
        }
    }
}

pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: maven-build
spec:
  containers:
    - name: maven
      image: maven:3.9.2-amazoncorretto-17
      command:
        - cat
      tty: true
"""
        }
    }

    environment {
        SONARQUBE_SERVER = 'http://sonarqube-service:9000/sonarqube/'
        SONARQUBE_TOKEN = credentials('sonarqube-user-token')
        SONARQUBE_PROJECT_KEY = credentials('sonarqube-simple-java-maven-app')
        SONARQUBE_PROJECT_NAME = "simple-java-maven-app-${env.BRANCH_NAME ?: 'master'}"
    }

    options {
        buildDiscarder(logRotator(
            numToKeepStr: '5',
            artifactDaysToKeepStr: '10'
        ))
    }

    stages {
        stage('Checkout') {
            steps {
                container('maven') {
                    checkout scm
                }
            }
        }

        stage('Set Build Name') {
            steps {
                script {
                    def timestamp = new Date().format("yyyy.MM.dd.HHmm")
                    currentBuild.displayName = "${timestamp}"
                }
            }
        }

        stage('Build maven app') {
            steps {
                container('maven') {
                    sh 'mvn -B -DskipTests clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('maven') {
                    script {
                        withSonarQubeEnv('SonarQube') {
                            // Run SonarQube scanner
                            sh """
                                mvn sonar:sonar \
                                    -Dsonar.host.url=${env.SONARQUBE_SERVER} \
                                    -Dsonar.login=${env.SONARQUBE_TOKEN} \
                                    -Dsonar.projectKey=${env.SONARQUBE_PROJECT_KEY} \
                                    -Dsonar.projectName=${env.SONARQUBE_PROJECT_NAME}
                            """
                        }
                        timeout(time: 60, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                }
            }
        }

        stage('Test maven app') {
            steps {
                container('maven') {
                    script{
                        sh 'mvn test'
                    }
                    junit 'target/surefire-reports/*.xml'
                    archiveArtifacts artifacts: 'target/surefire-reports/*.xml'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

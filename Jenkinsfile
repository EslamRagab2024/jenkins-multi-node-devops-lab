pipeline {
    agent none

    stages {
        stage('Build & Test on Container Agent') {
            agent {
                node {
                    label 'docker-ssh-agent'
                }
            }
            steps {
                echo 'Building and testing on Container Agent...'
                sh 'whoami && pwd'
                sh 'java -version || echo "Java is executing inside container"'
            }
        }

        stage('Deploy to AWS EC2 Agent') {
            agent {
                node {
                    label 'aws-ec2-agent' 
                }
            }
            steps {
                echo 'Deploying application to AWS EC2 Instance...'
                sh 'docker --version'
                sh 'uname -a'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
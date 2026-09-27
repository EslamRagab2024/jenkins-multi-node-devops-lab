pipeline {
    agent none

    stages {
        stage('Build & Test on Container Agent') {
            agent {
                node {
                    label 'docker-agent' 
                }
            }
            steps {
                echo 'Building and testing application on Docker Agent...'
                //  sh 'docker build -t my-app .'
                sh 'python3 --version || docker --version'
            }
        }

        stage('Deploy to AWS EC2 Agent') {
            agent {
                node {
                    label 'instance-agent' 
                }
            }
            steps {
                echo 'Deploying application to AWS EC2 Instance...'
                sh 'docker --version'
                //  Application container
                // sh 'docker run -d -p 8080:8080 --name my-app-container my-app'
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
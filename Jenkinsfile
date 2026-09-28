pipeline {
    agent none

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'islamragab/flask-app'
    }

    stages {
        stage('Lint & Test') {
            agent { label 'docker-ssh-agent' }
            steps {
                echo '=== Stage 1: Testing Application inside Isolated Python Container ==='
                sh '''
                    docker run --rm -v "$(pwd)":/workspace -w /workspace python:3.10-slim sh -c "pip install -r app/requirements.txt && python3 -m py_compile app/app.py"
                '''
            }
        }

        stage('Build & Push to Docker Hub') {
            agent { label 'docker-ssh-agent' }
            steps {
                echo '=== Stage 2: Building and Pushing Image from Container Agent ==='
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker build -f Dockerfile_app -t ${DOCKER_IMAGE}:${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Deploy on AWS EC2') {
            agent { label 'aws-ec2-agent' }
            steps {
                echo '=== Stage 3: Pulling and Deploying Container on EC2 ==='
                sh '''
                    docker pull ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker stop flask-app || true
                    docker rm flask-app || true
                    docker run -d -p 5000:5000 --name flask-app ${DOCKER_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }
    }

    post {
        success {
            echo ' Application deployed successfully on AWS EC2!'
        }
        failure {
            echo ' Pipeline failed! Check logs.'
        }
    }
}
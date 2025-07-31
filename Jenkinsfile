pipeline {
    agent {
        label 'local-agent'
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        SSH_KEY = credentials('ssh-key')
        GITHUB_TOKEN = credentials('github-token')
    }

    stages {
        stage('Clone Repo') {
            steps {
                git credentialsId: 'github-token', url: 'https://github.com/masdikaaa/absensi-karyawan-gps-barcode.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t masdika/absensi-app:latest .'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                        echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
                        docker push masdika/absensi-app:latest
                    """
                }
            }
        }

        stage('Deploy to Docker Server') {
            steps {
                script {
                    // Ganti dengan perintah deploy kamu ke 103.168.146.164
                    sh """
                    ssh -o StrictHostKeyChecking=no root@103.168.146.164 <<EOF
                        docker pull masdika/absensi-app:latest
                        docker stop absensi-app || true
                        docker rm absensi-app || true
                        docker run -d --name absensi-app -p 80:80 masdika/absensi-app:latest
                    EOF
                    """
                }
            }
        }
    }
}

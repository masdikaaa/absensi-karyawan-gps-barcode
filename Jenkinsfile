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
                    sh """
                    ssh -o StrictHostKeyChecking=no root@103.168.146.164 <<'EOF'
                        cd /root/app-absensi || git clone https://github.com/masdikaaa/absensi-karyawan-gps-barcode.git app-absensi && cd app-absensi
                        git pull origin master

                        echo "Pull image dari DockerHub..."
                        docker-compose pull

                        echo "Restart aplikasi..."
                        docker-compose down
                        docker-compose up -d --remove-orphans
                    EOF
                    """
                }
            }
        }
    }
}

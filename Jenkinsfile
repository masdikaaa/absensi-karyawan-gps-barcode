pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'masdika/absensi-karyawan:latest'
        REMOTE_DOCKER_HOST = 'ssh://root@103.168.146.164'
    }

    stages {
        stage('Clone Repository') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PAT')]) {
                    sh '''
                        rm -rf absensi-karyawan-gps-barcode
                        git clone https://$GIT_USER:$GIT_PAT@github.com/masdikaaa/absensi-karyawan-gps-barcode.git
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    cd absensi-karyawan-gps-barcode
                    docker build -t $DOCKER_IMAGE .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Deploy to Remote Docker Server') {
            steps {
                sshagent(credentials: ['ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no root@103.168.146.164 '
                            set -e
                            if [ ! -d absensi-app ]; then
                                git clone https://github.com/masdikaaa/absensi-karyawan-gps-barcode.git absensi-app
                            fi

                            cd absensi-app
                            git reset --hard
                            git checkout master
                            git pull origin master

                            # Pastikan file .env ada
                            if [ ! -f .env ]; then
                                echo "[INFO] .env tidak ditemukan, membuat dari .env.example"
                                cp .env.example .env
                            fi

                            docker compose pull
                            docker compose down
                            docker compose up -d --build
                        '
                    '''
                }
            }
        }
    }
}

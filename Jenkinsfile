pipeline {
    agent any

    stages {
        stage("Clone repository") {
            steps {
                git branch: 'main', url: 'https://github.com/chrisdylan237/mboa.git'
            }
        }
        stage("Build Dockerfile") {
            steps {
                script {
                    sh 'docker build -t mboa .'
                }
            }
        }
        stage("Deploy to container") {
            steps {
                script {
                    sh 'docker run -itd --name mboa -p 8086:80 mboa'
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

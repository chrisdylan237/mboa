pipeline {
    agent any

    parameters {
        string(name: 'github-url', defaultValue: '', description: 'Enter your GitHub URL')
        string(name: 'image-name', defaultValue: 'dockerhubusername/repo-name', description: 'Enter your image name')
        string(name: 'image-tag', defaultValue: '', description: 'Enter your image tag')
    }

    environment {
        scanner = tool 'sonar'
    }

    stages {
        stage("Clone repository") {
            steps {
                git branch: 'main', url: "${params['github-url']}", credentialsId: "github-dylan"
            }
        }
        stage("Code scan") {
            steps {
                script {
                    withSonarQubeEnv('sonar') {
                        sh '''
                        $scanner/bin/sonar-scanner \
                        -Dsonar.login=sonar \
                        -Dsonar.host.url=http://18.219.90.216:9000/ \
                        -Dsonar.projectKey=inance \
                        -Dsonar.sources=./inance
                        '''
                    }
                }
            }
        }
        stage("Build Dockerfile") {
            steps {
                script {
                    sh "docker build -t ${params['image-name']}:${params['image-tag']} ."
                }
            }
        }
        stage("Connect to DockerHub") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "DOCKERHUB-DYLAN", 
                    usernameVariable: "dockerusername", passwordVariable: "dockerhubpassword")]) {
                        sh "docker login -u $dockerusername -p $dockerhubpassword"
                    }
                }
            }
        }
        stage("Push to DockerHub") {
            steps {
                script {
                    sh "docker push ${params['image-name']}:${params['image-tag']}"
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

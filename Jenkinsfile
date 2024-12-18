pipeline {
    agent any

    parameters {
        string(name: 'github-url', defaultValue: '', description: 'Enter your GitHub URL')
        string(name: 'image-name', defaultValue: 'dockerhubusername/repo-name', description: 'Enter your image name')
        string(name: 'image-tag', defaultValue: '', description: 'Enter your image tag')
        string(name: 'password', defaultValue: '', description: 'Enter your password for remote server')
        string(name: 'remote_user', defaultValue: '', description: 'Enter your remote user')
        string(name: 'server_dns', defaultValue: '', description: 'Enter your server DNS')
        booleanParam(name: 'skip', defaultValue: false, description: "Mark for yes or leave empty for false")
        booleanParam(name: 'skip_deployment', defaultValue: false, description: 'skip_deployment')
        booleanParam(name: 'clean_deployment', defaultValue: false, description: 'clean_deployment')
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
            when {
                expression { !params.skip }
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_TOKEN')]) {
                        withSonarQubeEnv('sonar') {
                            sh '''
                            $scanner/bin/sonar-scanner \
                            -Dsonar.login=$SONAR_TOKEN \
                            -Dsonar.host.url=http://18.219.90.216:9000/ \
                            -Dsonar.projectKey=inance \
                            -Dsonar.sources=./inance
                            '''
                        }
                    }
                }
            }
        }
        stage("Build Dockerfile") {
            when {
                expression { !params.skip }
            }
            steps {
                script {
                    sh "docker build -t ${params['image-name']}:${params['image-tag']} ."
                }
            }
        }
        stage("Connect to DockerHub") {
            when {
                expression { !params.skip }
            }
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
            when {
                expression { !params.skip }
            }
            steps {
                script {
                    sh "docker push ${params['image-name']}:${params['image-tag']}"
                }
            }
        }
        stage("Connect to remote and deploy") {
            when {
                expression { !params.skip_deployment }
            }
            steps {
                script {
                    sh "sshpass -p '${params['password']}' ssh -o StrictHostKeyChecking=no ${params['remote_user']}@${params['server_dns']} 'docker run -itd --name inance -p 8086:80 chrisdylan/inance:1.0'"
                }
            }
        }
        stage("Clean deployment server") {
            when {
                expression { !params.clean_deployment }
            }
            steps {
                script {
    
                    sh " sshpass -p '${params['password']}' ssh -o StrictHostKeyChecking=no ${params['remote_user']}@${params['server_dns']} "
                    sh " docker stop $(docker ps -q) "
                    sh " docker rm $(docker ps -aq) "
                    sh " docker rmi $(docker images -q)"
                    
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

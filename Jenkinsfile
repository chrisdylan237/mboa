pipeline {
    agent any

    parameters {
        string(name: 'github-url', defaultValue: '', description: 'Enter your GitHub URL')
        string(name: 'branch-name', defaultValue: 'main', description: 'Enter the branch name to clone')
        string(name: 'image-name', defaultValue: 'dockerhubusername/repo-name', description: 'Enter your image name')
        string(name: 'image-tag', defaultValue: '', description: 'Enter your image tag')
        string(name: 'source-dir', defaultValue: './inance', description: 'Enter the source directory for SonarQube scan')
        booleanParam(name: 'skip-stage', defaultValue: false, description: "Mark for yes or leave empty for false")
    }

    environment {
        scanner = tool 'sonar'
    }

    stages {
        stage("Clone repository") {
            steps {
                git branch: "${params['branch-name']}", url: "${params['github-url']}", credentialsId: "github-dylan"
            }
        }
        stage("Code scan") {
            steps {
                script {
                    withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_TOKEN')]) {
                        withSonarQubeEnv('sonar') {
                            sh '''
                            $scanner/bin/sonar-scanner \
                            -Dsonar.login=$SONAR_TOKEN \
                            -Dsonar.host.url=http://18.219.90.216:9000/ \
                            -Dsonar.projectKey=inance \
                            -Dsonar.sources=${params['source-dir']}
                            '''
                        }
                    }
                }
            }
        }
        stage("Build Dockerfile") {
            when {
                expression { !params.skip-stage }
            }
            steps {
                script {
                    sh "docker build -t ${params['image-name']}:${params['image-tag']} ."
                }
            }
        }
        stage("Connect to DockerHub") {
            when {
                expression { !params.skip-stage }
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
                expression { !params.skip-stage }
            }
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

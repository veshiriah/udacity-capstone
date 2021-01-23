// Functions
def loadEnvironmentVariables(path){
    def props = readProperties  file: path
    keys= props.keySet()
    for(key in keys) {
        value = props["${key}"]
        env."${key}" = "${value}"
    }
} 

pipeline {
    agent any
    stages {
        stage('Get env variables') {
            steps {
                script {
                    echo "Building project"
                    loadEnvironmentVariables('environment/env.properties')
                    echo "Params:"
                    echo "action: ${action}"
                    echo "Environment Variables:"
                    echo sh(script: 'env|sort', returnStdout: true)
                }
            
            }
        }

        stage('Linting') {
            steps {
                sh 'tidy -q -e index.html'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t kchachowska/udacity-capstone-kc .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([url: "", credentialsId: "dockerhub"]) {
                    sh 'docker push kchachowska/udacity-capstone-kc'
                }
            }
        }

        stage('Create kube config file') {
            steps {
                withAWS(region:'${AWS_DEFAULT_REGION}', credentials:'awsCreds') {
                sh '''
                    aws eks --region ${AWS_DEFAULT_REGION} update-kubeconfig --name UdacityDev-EKS-Cluster
                    kubectl get svc
                    kubectl config use/context arn:aws:eks:ap-southeast-2:${AWS_ACCOUNT_ID}:cluster/UdacityDev-EKS-Cluster
                    kubectl set image deployment/udacity-capstone-kc udacity-capstone-kc=kchachowska/udacity-capstone-kc
                '''
                }
            }
        }

        stage('Deployment') {
            steps {
                withAWS(region:'${AWS_DEFAULT_REGION}', credentials:'awsCreds') {
                sh '''
                    kubectl apply -f deployment/deployment.yaml
                    kubectl get service/udacity-capstone-kc
                '''
                }
            }
        }
    }
}
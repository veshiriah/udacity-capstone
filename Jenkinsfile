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
    environment {
        PATH = "/home/jenkins/.local/bin:/opt/node/bin:$PATH"
    }
    stages {
        stage('Get env variables') {
            steps {
                script {
                    echo "Building project"
                    loadEnvironmentVariables('environment/env.properties')
                }
            }
        }

        stage('Print env variables') {
            steps {
                script {
                    echo "AWS Env Is: ${env.AWS_DEFAULT_REGION}"
                    sh"cat index.html"
                }
            }
        }

        stage('Linting') {
            steps {
                sh 'tidy -q -e index.html'
                echo "Linting finished"
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
                withAWS(region:"${env.AWS_DEFAULT_REGION}", credentials:'awsCreds') {
                sh"aws eks update-kubeconfig --name UdacityDev-EKS-Cluster --region ${env.AWS_DEFAULT_REGION}"
                // sh"kubectl edit -n kube-system deployment/aws-auth-cm.yaml"
                sh"kubectl get svc"
                sh"kubectl config set-context arn:aws:eks:${env.AWS_DEFAULT_REGION}${env.AWS_ACCOUNT_ID}::cluster/UdacityDev-EKS-Cluster"
                sh"kubectl config use-context arn:aws:eks:${env.AWS_DEFAULT_REGION}:${env.AWS_ACCOUNT_ID}:cluster/UdacityDev-EKS-Cluster"
                //  In case the image needed updatingx
                sh"kubectl set image deployment/udacity-capstone-kc udacity-capstone-kc=kchachowska/udacity-capstone-kc"
                }
            }
        }

        stage('Deployment') {
            steps {
                withAWS(region:"${env.AWS_DEFAULT_REGION}", credentials:'awsCreds') {
                sh """
                    kubectl apply -f deployment/aws-auth-cm.yaml
                    kubectl apply -f deployment/deployment.yaml
                    kubectl get nodes
                    kubectl get deployment
                    kubectl get pod -o wide
                    kubectl describe pods
                    kubectl get service/udacity-capstone-kc
                """
                }
            }
        }

        stage('Prune') {
            steps {
                sh """
                    docker system prune --force
                """
            }
        }
    }
}
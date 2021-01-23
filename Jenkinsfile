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
                }
            }
        }

        stage('Deploy cloud formation') {
            steps {
                withAWS(region:"${env.AWS_DEFAULT_REGION}", credentials:'awsCreds') {
                    script {
                        echo "AWS Env Is: ${env.AWS_DEFAULT_REGION}"
                        sh"chmod +x function.sh"
                        sh".. function.sh 'eks-test' 'eks-changeset' 'eks.yaml' 'eks-params.json'"
                        sh".. function.sh 'eks-nodes-test' 'eks-nodes-changeset' 'nodes.yaml' 'nodes-params.json'"
                    }
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
                withAWS(region:"${env.AWS_DEFAULT_REGION}", credentials:'awsCreds') {
                sh"aws eks update-kubeconfig --name UdacityDev-EKS-Cluster --region ${env.AWS_DEFAULT_REGION}"
                sh"kubectl edit -n kube-system deployment/aws-auth-cm.yaml"
                sh"kubectl get svc"
                sh"kubectl config use/context arn:aws:eks:ap-southeast-2:${env.AWS_ACCOUNT_ID}:cluster/UdacityDev-EKS-Cluster"
                sh"kubectl set image deployment/udacity-capstone-kc udacity-capstone-kc=kchachowska/udacity-capstone-kc"
                }
            }
        }

        stage('Deployment') {
            steps {
                withAWS(region:"${env.AWS_DEFAULT_REGION}", credentials:'awsCreds') {
                sh '''
                    kubectl apply -f deployment/deployment.yaml
                    kubectl get service/udacity-capstone-kc
                '''
                }
            }
        }
    }
}
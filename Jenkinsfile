pipeline {
    agent any

    tools {
        terraform 'Terraform'
        ansible 'Ansible'
    }

    environment {
        TF_VAR_region = 'us-west-2'
        TF_VAR_key_name = 'oregon-key'
        TF_IN_AUTOMATION = 'true'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        ANSIBLE_REMOTE_USER = 'ubuntu'
    }

    stages {
        stage('User Input - Create or Destroy?') {
            steps {
                script {
                    def infraAction = input message: 'Create or Destroy Infrastructure?', parameters: [
                        choice(name: 'INFRA_ACTION', choices: ['Create', 'Destroy'], description: 'Select whether to create or destroy infrastructure.')
                    ]
                    env.INFRA_ACTION = infraAction
                }
            }
        }

        stage('User Input - Clone Repository?') {
            when {
                expression { return env.INFRA_ACTION == 'Create' }
            }
            steps {
                script {
                    def cloneInput = input message: 'Clone Repository?', parameters: [
                        choice(name: 'CLONE', choices: ['Yes', 'No'], description: 'Do you want to clone the repository?')
                    ]
                    env.CLONE_REPOSITORY = cloneInput
                }
            }
        }

        stage('Clone Repository') {
            when {
                expression { return env.INFRA_ACTION == 'Create' && env.CLONE_REPOSITORY == 'Yes' }
            }
            steps {
                echo "Cloning the repository..."
                sh 'rm -rf mongodb_infra_tool'
                sh 'git clone https://github.com/meer727/mongodb_infra_tool.git'
            }
        }

        stage('Terraform Init') {
            when {
                expression { return env.INFRA_ACTION == 'Create' }
            }
            steps {
                script {
                    withAwsAndDir {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform fmt') {
            when {
                expression { return env.INFRA_ACTION == 'Create' }
            }
            steps {
                script {
                    withAwsAndDir {
                        sh 'terraform fmt'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            when {
                expression { return env.INFRA_ACTION == 'Create' }
            }
            steps {
                script {
                    withAwsAndDir {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { return env.INFRA_ACTION == 'Create' }
            }
            steps {
                script {
                    withAwsAndDir {
                        sh 'terraform plan'
                    }
                }
            }
        }

        stage('User Input - Confirm Terraform Apply?') {
            when {
                expression { return env.INFRA_ACTION == 'Create' }
            }
            steps {
                script {
                    def applyConfirm = input message: 'Confirm Terraform Apply?', parameters: [
                        choice(name: 'APPLY_CONFIRM', choices: ['Yes', 'No'], description: 'Do you want to proceed with Terraform apply?')
                    ]
                    env.APPLY_CONFIRM = applyConfirm
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return env.INFRA_ACTION == 'Create' && env.APPLY_CONFIRM == 'Yes' }
            }
            steps {
                echo "You have chosen to apply the Terraform changes."
                script {
                    withAwsAndDir {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Run Ansible Playbook via Bastion Host') {
            when {
                expression { return env.INFRA_ACTION == 'Create' }
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'private-ssh-key', keyFileVariable: 'SSH_PRIVATE_KEY')]) {
                    script {
                        sh '''
                            echo "Fetching bastion host ip for proxy from dynamic inventory..."
                            BASTION_PUBLIC_IP=$(ansible-inventory -i mongodb_infra_tool/mongodb-role/aws_ec2.yml --list | jq -r '._meta.hostvars[._Bastion_server.hosts[0]].public_ip_address')
                            cd mongodb_infra_tool/mongodb-role
                            
                            echo "BASTION_PUBLIC_IP: $BASTION_PUBLIC_IP"
                            echo "SSH_PRIVATE_KEY path: $SSH_PRIVATE_KEY"
                            
                            echo "Testing SSH connection to bastion..."
                            ssh -i $SSH_PRIVATE_KEY -o StrictHostKeyChecking=no ubuntu@$BASTION_PUBLIC_IP "echo Connected to bastion successfully"
                            
                            export ANSIBLE_SSH_COMMON_ARGS="-o ProxyCommand='ssh -i $SSH_PRIVATE_KEY -W %h:%p -o StrictHostKeyChecking=no ubuntu@$BASTION_PUBLIC_IP'"
                            
                            ANSIBLE_HOST_KEY_CHECKING=False \
                            ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ConnectTimeout=60 -o ServerAliveInterval=60' \
                            ansible-playbook -i aws_ec2.yml mongodb_playbook.yml \
                            --private-key=$SSH_PRIVATE_KEY \
                            -u ubuntu \
                            --timeout=60
                        '''
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { return env.INFRA_ACTION == 'Destroy' }
            }
            steps {
                echo "You have chosen to destroy the Terraform infrastructure."
                script {
                    withAwsAndDir {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
            mail to: 'mansooralam@gmail.com', subject: "Jenkins Pipeline Status: ${currentBuild.result}", body: """
            Pipeline execution completed.
            Status: ${currentBuild.result}
            Build URL: ${BUILD_URL}
            """
        }
        success {
            echo 'Pipeline executed successfully!'
            mail to: 'mansooralam5256@gmail.com', subject: "Jenkins Pipeline Success", body: "Pipeline executed successfully! Build URL: ${BUILD_URL}"
        }
        failure {
            echo 'Pipeline failed.'
            mail to: 'mansooralam5256@gmail.com', subject: "Jenkins Pipeline Failure", body: "Pipeline failed. Build URL: ${BUILD_URL}"
        }
        aborted {
            echo 'Pipeline was manually aborted.'
            mail to: 'mansooralam5256@gmail.com', subject: "Jenkins Pipeline Aborted", body: "Pipeline was manually aborted. Build URL: ${BUILD_URL}"
        }
    }
}

def withAwsAndDir(Closure body) {
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
        dir('mongodb_infra_tool/mongodb-terraform') {
            body()
        }
    }
}


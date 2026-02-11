
Commands Used

This document lists all major commands used during:

Infrastructure provisioning (Terraform)

Cluster access (SSM + kubectl)

Application build & deployment

Worker node health checks (NTP and iptables) using Ansible + SSM

Troubleshooting

Terraform – Provision EKS Cluster

Initialize Terraform:

cd terraform
terraform init


Validate configuration:

terraform validate


Plan deployment:

terraform plan


Apply infrastructure:

terraform apply


Destroy infrastructure (if needed):

terraform destroy

Access Bastion (SSM – No SSH Used)

Start interactive session:

aws ssm start-session --region us-west-1 --target <BASTION_INSTANCE_ID>

Configure kubectl from Bastion

Update kubeconfig:

aws eks update-kubeconfig --region us-west-1 --name eks-ssm-prod


Verify cluster:

kubectl get nodes
kubectl get pods -A

Build & Push Docker Image

Build image:

docker build -t rahul183/devops-practical:latest .


Push image:

docker push rahul183/devops-practical:latest

Deploy Application Using Helm

Install Swimlane chart:

helm install swimlane . -n swimlane --create-namespace

If PVC Is Not Binding

Annotate StorageClass:

kubectl annotate storageclass gp2 storageclass.kubernetes.io/is-default-class="true"


Verify services:

kubectl get svc -n swimlane

Verify Application

Check pods and services:

kubectl get pods -n swimlane
kubectl get svc -n swimlane


Open the External IP in your browser.

Worker Node Checks (Ansible via SSM)

Run NTP check:

cd /root/ansible
ansible-playbook playbooks/ntp_check.yml


Run iptables & network tools check:

ansible-playbook playbooks/net_tools_check.yml

Direct SSM Commands (Without Ansible)

Run command on worker nodes:

aws ssm send-command --region us-west-1 --document-name "AWS-RunShellScript" --targets "Key=tag:eks:cluster-name,Values=eks-ssm-prod" --parameters 'commands=["hostname","timedatectl status"]'

Troubleshooting Commands

Check SSM instances:

aws ssm describe-instance-information --region us-west-1 --query "InstanceInformationList[*].[InstanceId,PingStatus]" --output table


Check CoreDNS:

kubectl get pods -n kube-system -l k8s-app=kube-dns


Check EKS add-ons:

aws eks list-addons --region us-west-1 --cluster-name eks-ssm-prod


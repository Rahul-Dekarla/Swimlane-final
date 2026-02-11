#Commands Used

This document lists all major commands used during:

- Infrastructure provisioning (Terraform)
- Cluster access (SSM + kubectl)
- Application build & deployment
- Worker node health checks(NTP and Iptables) (Ansible + SSM)
- Troubleshooting


#Terraform – Provision EKS Cluster

#Initialize Terraform

cd terraform
terraform init

#Validate configuration
terraform validate

#Plan deployment
terraform plan

#Apply infrastructure
terraform apply

#Destroy infrastructure (if needed)
terraform destroy

Access Bastion (SSM – No SSH)
 NOT used SSH.

Start interactive session to bastion
aws ssm start-session --region us-west-1 --target <BASTION_INSTANCE_ID>

Configure kubectl from Bastion
Update kubeconfig
aws eks update-kubeconfig --region us-west-1  --name eks-ssm-prod

Verify cluster
kubectl get nodes
kubectl get pods -A

Build & Push Docker Image
Build and pushed to own dockerhub repo publicly available

Build image
docker build -t rahul183/devops-practical:latest .
Tag image
docker tag rahul183/devops-practical:latest  \
docker push  rahul183/devops-practical:latest

#Deploy Application
Using Helm
Go to Swimlane directory
helm install swimlane . -n swimlane --create-namespace 

If the PVC is not binding, annotate the StorageClass to set it as the default:

kubectl annotate storageclass gp2 storageclass.kubernetes.io/is-default-class="true"

After annotating, delete the PVC so it can be recreated automatically. If necessary, restart the deployment or delete the pods so they come back up.
Finally, run:

kubectl get svc -n <namespace>

Verify Application
Check pods and services
kubectl get pods -n swimlane 
kubectl  get svc -n swimlane 

get the endpoint from external_ip and paste it in your browser

#Worker Node Checks (Ansible via SSM)

login into bastion host using ssm

#Run NTP check
cd /root/ansible
ansible-playbook playbooks/ntp_check.yml

#Run iptables & network tools check
ansible-playbook playbooks/net_tools_check.yml

Direct SSM Commands (Without Ansible)
Run command on all worker nodes

aws ssm send-command   --region us-west-1 --document-name "AWS-RunShellScript"  --targets "Key=tag:eks:cluster-name,Values=eks-ssm-prod" --parameters 'commands=["hostname","timedatectl status"]'
  
  

#Troubleshooting Commands

Check SSM online instances
aws ssm describe-instance-information  --region us-west-1 --query "InstanceInformationList[*].[InstanceId,PingStatus]" --output table

#Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns

#Check EKS addons
aws eks list-addons --region us-west-1 --cluster-name eks-ssm-prod

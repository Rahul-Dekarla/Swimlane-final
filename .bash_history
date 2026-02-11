curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
apt install unzip
mkdir eks-ssm-secure
cd eks-ssm-secure/
cd terraform
mkdir terraform
cd terraform/
vim versions.tf
vim providers.tf
vim variables.tf
vim main.tf
vim vpc.tf
vim endpoints.tf
vim eks.tf
vim bastion.tf
vim ebs-csi.tf
vim outputs.tf
terraform init
vim variables.tf 
terraform fmt
terraform init
terraform validate
vim providers.tf 
vim versions.tf 
rm -rf .terraform .terraform.lock.hcl
terraform init -upgrade
terraform validate
terraform plan
terraform apply
terraform output bastion_instance_id
aws ssm start-session   --region us-west-1   --target i-05b9d75bb36145274
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
session-manager-plugin
aws ssm start-session   --region us-west-1   --target i-05b9d75bb36145274
history
cd
ls
git init
git branch -M main
git add .
git commit -m "Initial: EKS secure cluster + app deploy + IaC"
git remote add origin https://github.com/<YOUR_GH_USER>/eks-ssm-prod-demo.git
git remote add origin https://github.com/Rahul-Dekarla/swimlane.git
git push -u origin main
git remote add origin https://github.com/Rahul-Dekarla/swimlane.git
git push -u origin main
git remote -v
git remote add origin git@github.com:Rahul-Dekarla/swimlane.git
git remote set-url origin git@github.com:Rahul-Dekarla/swimlane.git
git remote -v
ssh -T git@github.com
ls
exit
ls
pwd
exit
ls
ssh -T git@github.com
cat ~/.ssh/id_ed25519.pub
exit

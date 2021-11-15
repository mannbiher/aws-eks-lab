#!/bin/bash
set -e
echo "Deploying forward proxy"
cd ec2
terraform init -input=false
terraform plan -out=tfplan -input=false
terraform apply -input=false tfplan
rm tfplan

echo "Deploying eks control plane and managed groups"
cd ../eks
terraform init -input=false
terraform plan -out=tfplan -input=false
terraform apply -input=false tfplan
rm tfplan

echo "Deplying argocd helm chart"
cd ../argocd
terraform init -input=false
terraform plan -out=tfplan -input=false
terraform apply -input=false tfplan
rm tfplan

echo "Deploying iam roles for service accounts"
cd ../irsa
terraform init -input=false
terraform plan -out=tfplan -input=false
terraform apply -input=false tfplan
rm tfplan


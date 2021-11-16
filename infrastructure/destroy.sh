#!/bin/bash
cd irsa
terraform init
terraform destroy -input=false -auto-approve

cd ../argocd
terraform init
terraform destroy -input=false -auto-approve

cd ../eks
terraform init
terraform destroy -input=false -auto-approve

cd ../ec2
terraform init
terraform destroy -input=false -auto-approve





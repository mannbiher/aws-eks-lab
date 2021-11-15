#!/bin/bash
cd irsa
terraform init
terraform destroy -input=false

cd ../argocd
terraform init
terraform destroy -input=false

cd ../eks
terraform init
terraform destroy -input=false

cd ../ec2
terraform init
terraform destroy -input=false





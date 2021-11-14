#!/bin/bash
aws ecr create-repository \
    --repository-name apps/hello \
    --image-tag-mutability IMMUTABLE \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256
aws_account_id=$(aws sts get-caller-identity --query "Account" --out text)
aws ecr get-login-password --region us-east-2 | podman login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.us-east-2.amazonaws.com
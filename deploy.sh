#!/usr/bin/env bash

read -p "Enter AWS Profile name: " aws_profile
read -p "Enter application versoin: " app_version

export AWS_PROFILE=$app_version
export AWS_REGION=eu-west-1
export TF_VAR_app_version=$app_version
export account_id=$(aws sts get-caller-identity --query "Account" --output text)


pushd docker

docker build . -t "${account_id}".dkr.ecr.eu-west-1.amazonaws.com/abc-service:"${app_version}"

docker push "${account_id}".dkr.ecr.eu-west-1.amazonaws.com/abc-service:"${app_version}"

popd

terraform apply -auto-approve


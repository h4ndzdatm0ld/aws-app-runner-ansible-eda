# Ansible Event Driven Automation with AWS App Runner!

Ansible EDA with AWS App Runner Demo Project. Check out the associated blogpost! [Ansible EDA with AWS App Runner](https://www.dev-knot.com)

This repo has accomplished the following:

## Terraform

1. Created an AWS ECR and an AWS App Runner Service w/ IAM Role
2. Terraform Cloud Remote Workspace to manage state with GitOps

## Github Actions

1. Package a container image with Github Actions that will host the Ansible EDA service
2. Publish the Image to the private AWS Elastic Container Registry
3. Host the Ansible EDA listening service with AWS App Runner

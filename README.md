# Nodejs-cicd
This project is a fully automated CI/CD pipeline for a Node.js app using GitHub Actions, Docker and Terraform. It is deployed to AWS servers using github Actions.
## Overview
CI/CD pipeline using GitHub Actions  
Dockerized Node.js app  
Infrastructure provisioned with Terraform  
## Pipeline Flow
-Developer pushes code  
-GitHub Actions triggers  
-Install dependencies   
-Run tests  
-Build Docker image  
-Push to DockerHub  
-Terraform provisions AWS  
-App deployed to EC2
## Tools Used
GitHub Actions  
Docker  
Terraform  
AWS EC2  
## Project Structure

```
nodejs-cicd-project/
├── app/
│   ├── index.js
│   ├── package.json
│   └── test/
├── Dockerfile
├── .github/workflows/
│   └── ci-cd.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── .gitignore
└── README.md
```

## Local development

1. Install dependencies:

```bash
cd app
npm install
```

2. Start the app:

```bash
npm start
```

3. Open `http://localhost:3000`

## Docker

Build the Docker image:

```bash
docker build -t node-cicd-app .
```

Run the container:

```bash
docker run -d -p 3000:3000 node-cicd-app
```

## Terraform

Setup AWS credentials and run from `terraform/`:

```bash
cd terraform
terraform init
terraform plan   
terraform apply -auto-approve
```

### Terraform variables

The Terraform configuration supports:

- `aws_region`
- `instance_type`
- `aws_ami`
- `ssh_key_name`

## GitHub Actions CI/CD

The workflow is defined in `.github/workflows/ci-cd.yml`.

It performs:

1. checkout code
2. install dependencies
3. run tests
4. build Docker image
5. push image to DockerHub
6. run Terraform provision
7. deploy the container to EC2 via SSH

## Required GitHub Secrets

Add the following secrets to your repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `TF_VAR_KEY_NAME`
- `EC2_PUBLIC_IP`
- `EC2_SSH_KEY`

## Access the app

After deployment, visit:

```text
http://<EC2_PUBLIC_IP>:3000
```

Replace `<EC2_PUBLIC_IP>` with the public IP of the EC2 instance.

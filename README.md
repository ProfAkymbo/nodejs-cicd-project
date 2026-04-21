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
docker run -p 3000:3000 node-cicd-app
```

## Terraform

Setup AWS credentials and run from `terraform/`:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### Terraform variables

The Terraform configuration supports:

- `aws_region`
- `instance_type`
- `aws_ami`
- `ssh_key_name`

You can pass these by environment variables (for example `TF_VAR_aws_region=us-east-1`) or a `terraform.tfvars` file.

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
EOF

cat > app/index.js <<'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('CI/CD Pipeline is working 🚀');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

cat > app/package.json <<'EOF'
{
  "name": "node-cicd-app",
  "version": "1.0.0",
  "description": "Simple Node.js app for CI/CD demo",
  "main": "index.js",
  "scripts": {
    "test": "echo "No tests yet" && exit 0",
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat > Dockerfile <<'EOF'
FROM node:18

WORKDIR /app
COPY app/ .

RUN npm install --production

EXPOSE 3000
CMD ["npm", "start"]
EOF

cat > .github/workflows/ci-cd.yml <<'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [main]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install dependencies
        run: |
          cd app
          npm install

      - name: Run tests
        run: |
          cd app
          npm test

      - name: Build Docker image
        run: |
          docker build -t node-cicd-app .

      - name: Login to DockerHub
        env:
          DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
        run: |
          echo "${DOCKER_PASSWORD}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Push image to DockerHub
        run: |
          docker tag node-cicd-app ${{ secrets.DOCKER_USERNAME }}/node-cicd-app:latest
          docker push ${{ secrets.DOCKER_USERNAME }}/node-cicd-app:latest

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: |
          cd terraform
          terraform init

      - name: Terraform Apply
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
        run: |
          cd terraform
          terraform apply -auto-approve

      - name: Deploy to EC2 via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_PUBLIC_IP }}
          username: ec2-user
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            docker pull ${{ secrets.DOCKER_USERNAME }}/node-cicd-app:latest
            docker stop app || true
            docker rm app || true
            docker run -d -p 3000:3000 --name app ${{ secrets.DOCKER_USERNAME }}/node-cicd-app:latest
EOF

cat > terraform/main.tf <<'EOF'
provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH access"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = var.aws_ami
  instance_type          = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "NodeAppServer"
  }
}
EOF

cat > terraform/variables.tf <<'EOF'
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "aws_ami" {
  description = "Amazon Linux 2 AMI"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}
EOF

cat > terraform/outputs.tf <<'EOF'
output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}
EOF

cat > .gitignore <<'EOF'
node_modules/
.terraform/
terraform/.terraform/
*.tfstate
*.tfstate.*
.crash.log
npm-debug.log*
.DS_Store
EOF

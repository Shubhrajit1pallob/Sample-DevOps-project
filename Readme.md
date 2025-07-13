# Complete App Deployment using Terraform and CI/CD Pipeline

## Overview

This project demonstrates how to automate the deployment of a Node.js application on AWS EC2 using Terraform for infrastructure provisioning and GitHub Actions for CI/CD. The workflow includes building a Docker image, pushing it to Amazon ECR, and deploying it to an EC2 instance.

---

## Workflow Diagram

```text
GitHub → GitHub Actions → Terraform → Amazon EC2 → Docker → Amazon ECR → Amazon EC2
```

---

## Prerequisites

- AWS account with permissions for EC2, ECR, IAM, and S3
- Terraform CLI installed (v1.0+)
- Node.js and npm installed (for local testing)
- SSH key pair for EC2 access
- GitHub repository with the following secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_SSH_KEY_PRIVATE`
  - `AWS_SSH_KEY_PUBLIC`
  - `AWS_TF_STATE_BUCKET_NAME`
  - `TF_API_TOKEN` (for Terraform Cloud, if used)

---

## Project Structure

``` text
.
├── .gitignore
├── LICENSE
├── Readme.md
├── nodeapp/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   ├── devops_sample
│   └── devops_sample.pub
├── Terraform/
│   ├── instance.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── variables.tf
└── .github/
    └── workflows/
        └── deployment.yaml
```

---

## Steps

### 1. Create the Application

- Build a simple Node.js app (`server.js`) using Express.
- Example:

    ```js
    import express from 'express';
    const app = express();
    const port = 3000;
    app.get('/', (req, res) => {
        res.send("Hello, World! This is a Node.js application running on AWS EC2 with Terraform.");
    });
    app.listen(port, () => {
        console.log(`Server is running on port ${port}`)
    });
    ```

### 2. Create the Dockerfile

- Example Dockerfile:

    ```dockerfile
    FROM node:18-alpine
    WORKDIR /usr/app
    COPY package*.json ./
    RUN npm install && npm audit fix --force
    COPY . .
    EXPOSE 3000
    CMD ["node", "server.js"]
    ```

### 3. Write Terraform Scripts to Deploy EC2 Instance

- Use Terraform to:
  - Configure the AWS provider and backend (S3 for state).
  - Create an EC2 instance using the latest Ubuntu AMI.
  - Create a custom security group allowing SSH (22) and HTTP (80).
  - Create and use an SSH key pair.
  - Attach an IAM role to allow EC2 to pull from ECR.
  - Output the instance's public IP.

- Example commands:

    ```bash
    terraform init
    terraform plan -var "public_key=$(cat path/to/public_key.pub)" -var "private_key=$(cat path/to/private_key)"
    terraform apply -var "public_key=$(cat path/to/public_key.pub)" -var "private_key=$(cat path/to/private_key)"
    ```

### 4. Configure GitHub Actions for CI/CD

- Create `.github/workflows/deployment.yaml` to:
  - Checkout code
  - Set up Terraform and apply infrastructure changes
  - Capture the EC2 instance public IP as a job output
  - Log in to AWS ECR
  - Create ECR repository if it doesn't exist
  - Build and push Docker image to ECR
  - SSH into EC2 and deploy the Docker container

### 5. Set Up GitHub Secrets

- In your GitHub repository, add the following secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_SSH_KEY_PRIVATE`
  - `AWS_SSH_KEY_PUBLIC`
  - `AWS_TF_STATE_BUCKET_NAME`
  - `TF_API_TOKEN` (if using Terraform Cloud)

### 6. Deploy Docker Image to EC2

- The workflow will:
  - SSH into the EC2 instance
  - Install Docker and AWS CLI if not present
  - Authenticate Docker to ECR
  - Pull the latest image
  - Stop and remove any existing container
  - Run the new container mapping port 80 on the host to port 3000 in the container

---

## Useful Commands

- **Initialize Terraform:**

    ```bash
    terraform init
    ```

- **Plan Infrastructure:**

    ```bash
    terraform plan -var "public_key=$(cat devops_sample.pub)" -var "private_key=$(cat devops_sample)"
    ```

- **Apply Infrastructure:**

    ```bash
    terraform apply -var "public_key=$(cat devops_sample.pub)" -var "private_key=$(cat devops_sample)"
    ```

- **Destroy Infrastructure:**

    ```bash
    terraform destroy -var "public_key=$(cat devops_sample.pub)" -var "private_key=$(cat devops_sample)"
    ```

- **Delete Docker Image from ECR:**

    ```bash
    aws ecr batch-delete-image --repository-name sample-devops-project --image-ids imageTag=<your-image-tag> --region us-east-1
    ```

- **Delete ECR Repository:**

    ```bash
    aws ecr delete-repository --repository-name sample-devops-project --region us-east-1 --force
    ```

---

## Best Practices

- Use a **custom VPC** for production deployments (default VPC is used here for simplicity).
- Never commit private keys or sensitive data to your repository.
- Use GitHub secrets for all credentials and sensitive variables.
- Regularly clean up unused resources to avoid unnecessary AWS charges.

---

## Cleanup

To remove all resources and images:

1. Run `terraform destroy` as shown above.
2. Delete Docker images and ECR repositories using the AWS CLI commands above.

---

## License

This project is licensed under the MIT License.

---

**Feel free to fork and adapt this project for your own cloud automation needs!**

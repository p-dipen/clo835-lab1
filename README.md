# Build docker image and deploy docker container on Amazon Linux EC2

<p align="center">
    <img width="50%" src="https://i.imgur.com/KEczoI8.png" />
</p>

In this project, I will walk through the process of building a Docker image and deploying the image to Amazon ECR, and demonstrate deploying a Docker image to Amazon Elastic Compute Cloud (Amazon EC2). Additionally, we are using github actions to deploy the images into Amazon Elastic Container Registry (Amazon ECR). The project is using Terraform to deploy EC2, Security policy and ECR.

This is the example of creating a simple infrastructure using Terraform. It consists of:
- Virtual Private Cloud (VPC) with 1 public subnets in availability zones
- Amazon Elastic Container Registry (ECR)

## How to create the infrastructure?
This example implies that you have already AWS account and Terraform CLI installed.
1. `git clone https://github.com/p-dipen/clo835-lab1.git`
2. cd Terraform
3. terraform init
4. terraform plan
5. terraform apply

Note: it can take about 5 minutes to provision all resources.
## How to delete the infrastructure?
1. Terminate instances
2. Run `terraform destroy`


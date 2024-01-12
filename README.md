# Terraform_AltSch_3rd-Semester-

# Terraform AWS Multi-Region Deployment

This repository contains Terraform code for deploying an AWS instance (Ubuntu) in multiple regions (free-tier) - specifically in `eu-west-1` and `eu-central-1`. The infrastructure is designed to meet the following requirements:

- Deployed across a minimum of 2 availability zones.
- Reusable and modularized for multiple environments (dev, staging, prod).
- Includes a script that creates Ansible and Docker containers.
  
## Project Structure

### Compute Module

- **File**: `compute.tf`
  
  ```hcl
  module "networking" {
    source             = "../modules/networking"
    vpc_cidr           = "10.0.0.0/16"
    public_subnet_cidr = "10.0.2.0/24"
  }
  
  module "compute" {
    source          = "../modules/compute"
    public_key_path = "~/.ssh/kaysea_key.pub"
    public_subnet   = module.networking.public_subnet
    public_sg       = module.networking.public_sg
    user_data       = file("userdata.tpl")
    volume_size     = 30
    instance_type   = "t2.micro"
  }
  ```

- **File**: `datasource.tf`
  
  ```hcl
  # Specify the AMI image details
  data "aws_ami" "server_ami" {
    most_recent = true
    owners      = ["099720109477"]
  
    filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
  }
  ```

- **File**: `variable.tf`
  
  ```hcl
  variable "user_data" {}
  variable "public_key_path" {}
  variable "instance_type" {}
  variable "public_subnet" {}
  variable "public_sg" {}
  variable "volume_size" {}
  ```

### Development Environment

- **File**: `dev/main.tf`
  
  ```hcl
  module "networking" {
    source             = "../modules/networking"
    vpc_cidr           = "10.0.0.0/16"
    public_subnet_cidr = "10.0.2.0/24"
  }
  
  module "compute" {
    source          = "../modules/compute"
    public_key_path = "~/.ssh/kaysea_key.pub"
    public_subnet   = module.networking.public_subnet
    public_sg       = module.networking.public_sg
    user_data       = file("userdata.tpl")
    volume_size     = 30
    instance_type   = "t2.micro"
  }
  ```

### Production Environment

- **File**: `prod/main.tf`
  
  ```hcl
  module "networking" {
    source             = "../modules/networking"
    vpc_cidr           = "10.0.0.0/16"      
    public_subnet_cidr = "10.0.1.0/24"      
  }
  
  module "compute" {
    source          = "../modules/compute"
    public_key_path = "~/.ssh/kaysea_key.pub"
    public_subnet   = module.networking.public_subnet
    public_sg       = module.networking.public_sg
    user_data       = file("userdata.tpl")
    volume_size     = 30
    instance_type   = "t2.micro"
  }
  ```

### Networking Module

- **File**: `networking/resource.tf`
  
  ```hcl
  resource "aws_vpc" "kaysea_vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
  }
  
  resource "aws_internet_gateway" "kaysea_igw" {
    vpc_id = aws_vpc.kaysea_vpc.id
  }
  
  resource "aws_subnet" "kaysee_public_subnet" {
    vpc_id                  = aws_vpc.kaysea_vpc.id
    cidr_block              = var.public_subnet_cidr
    map_public_ip_on_launch = true
  }
  
  resource "aws_route_table" "kaysea_public_route_table" {
    vpc_id = aws_vpc.kaysea_vpc.id
  }
  
  resource "aws_route" "default_route" {
    route_table_id         = aws_route_table.kaysea_public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.kaysea_igw.id
  }
  
  resource "aws_route_table_association" "kaysee_public_subnet_rt_assoc" {
    subnet_id      = aws_subnet.kaysee_public_subnet.id
    route_table_id = aws_route_table.kaysea_public_route_table.id
  }
  
  # Create the webserver security group
  resource "aws_security_group" "kaysee_webserver_sg" {
    name        = "Webserver"
    description = "Security group for frontend webserver"
    vpc_id      = aws_vpc.kaysea_vpc.id
  }
  ```

- **File**: `networking/output.tf`
  
  ```hcl
  output "test_public_subnet" {
    value = aws_subnet.kaysee_public_subnet
  }
  
  output "allow_all" {
    value = aws_security_group.kaysee_webserver_sg
  }
  ```

- **File**: `networking/variable.tf`
  
  ```hcl
  variable "vpc_cidr" {}
  variable "public_subnet_cidr" {}
  ```

### Provisioning Configuration

- **File**: `provision.tf`
  
  ```hcl
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 5.31.0"
      }
    }
  }
  
  provider "aws" {
    region = "eu-central-1"
  }
  ```
In conclusion, this Terraform project demonstrates a streamlined approach to deploying AWS Ubuntu instances across multiple regions. The modular and reusable design, coupled with the integration of Ansible and Docker, ensures flexibility and efficiency. With support for various environments like dev, staging, and prod, this infrastructure setup is adaptable and ready for diverse deployment scenarios. The organized structure and clear configurations make it easy to extend and customize based on specific project requirements.

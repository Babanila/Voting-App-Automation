# Setup and Usage Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start with Docker Compose](#quick-start-with-docker-compose)
4. [Local Development Setup](#local-development-setup)
5. [Cloud Deployment with Terraform & Ansible](#cloud-deployment-with-terraform--ansible)
6. [Environment Configuration](#environment-configuration)
7. [Accessing Services](#accessing-services)
8. [Troubleshooting](#troubleshooting)

---

## Project Overview

This is a **Multi-Stack Voting Application** demonstrating a distributed system with multiple services written in different languages:

- **Vote (Python Flask)**: Web interface for voting
- **Result (Node.js Express)**: Web interface showing vote results in real-time
- **Worker (.NET)**: Service that processes votes from Redis and stores them in the database
- **Redis**: In-memory queue storing incoming votes
- **PostgreSQL**: Database for persistent vote storage

### Architecture

```
                    ┌──────────────────┐
                    │   Users/Internet │
                    └────────┬─────────┘
                             │
                ┌────────────┴────────────┐
                │                        │
          Vote Service (8080)     Result Service (8081)
          (Public - Frontend)      (Public - Frontend)
                │                        │
                └────────────┬───────────┘
                             │
                    ┌────────▼────────┐
                    │  Redis Queue    │  (Backend)
                    │   (6379)        │
                    └─────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Worker Service │
                    │   (.NET)        │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  PostgreSQL DB  │
                    │   (5432)        │
                    └─────────────────┘
```

---

## Prerequisites

### For Local Development (Docker Compose)
- **Docker** (v20.10+)
- **Docker Compose** (v2.0+)
- **Git**

### For Cloud Deployment
- **Terraform** (v1.0+)
- **Ansible** (v2.9+)
- **AWS CLI** configured with credentials
- **SSH key pair** for EC2 instances
- **AWS Account** with appropriate permissions

### For Local Component Development
- **Python 3.10+** (for Vote service)
- **Node.js 18+** (for Result service)
- **.NET SDK 8.0+** (for Worker service)
- **PostgreSQL** (for database)
- **Redis** (for message queue)

---

## Quick Start with Docker Compose

### 1. Clone the Repository
```bash
git clone <repository-url>
cd ironhack-project-1
```

### 2. Setup Environment File
The `.env` file already contains default values. You can modify them if needed:
```bash
# View current configuration
cat .env

# Edit if needed (optional)
nano .env
```

Key environment variables:
```env
FRONTEND_VOTE_IMAGE=babanila/vote:1.0
FRONTEND_RESULT_IMAGE=babanila/result:1.0
BACKEND_WORKER_IMAGE=babanila/worker:1.0
REDIS_IMAGE=redis:7-alpine
DB_IMAGE=postgres:15-alpine

PORT=80
FLASK_ENV=development
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=postgres
```

### 3. Start the Application
```bash
# Start all services in the background
docker compose up -d

# Or view logs as services start
docker compose up

# Or start specific services
docker compose up -d vote result redis db worker
```

### 4. Verify Services Are Running
```bash
# Check status of all containers
docker compose ps

# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f vote
docker compose logs -f worker
```

### 5. Access the Services
- **Vote Interface**: http://localhost:8080
- **Result Interface**: http://localhost:8081
- **PostgreSQL**: localhost:5432 (internal only)
- **Redis**: localhost:6379 (internal only)

### 6. Stop and Clean Up
```bash
# Stop all services (keeps data)
docker compose down

# Stop and remove all volumes (cleans everything)
docker compose down -v

# View running services
docker compose ps
```

---

## Local Development Setup

### Running Vote Service (Python) Locally

```bash
cd vote

# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py

# Access at http://localhost:5000
```

**Environment variables:**
```bash
FLASK_ENV=development
PORT=80
REDIS_HOST=localhost
REDIS_PORT=6379
```

### Running Result Service (Node.js) Locally

```bash
cd result

# Install dependencies
npm install

# Run the application
node server.js

# Access at http://localhost:4000
```

**Connections:**
- Requires PostgreSQL running at `localhost:5432`
- Requires Worker service processing votes

### Running Worker Service (.NET) Locally

```bash
cd worker

# Restore dependencies
dotnet restore

# Run the application
dotnet run

# Or build and run
dotnet build
./bin/Debug/net8.0/Worker
```

**Environment variables:**
```bash
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=postgres
REDIS_HOST=localhost
REDIS_PORT=6379
```

### Running Redis Locally

```bash
# Using Homebrew (macOS)
brew install redis
brew services start redis

# Using Docker
docker run -d -p 6379:6379 redis:7-alpine

# Access via CLI
redis-cli
```

### Running PostgreSQL Locally

```bash
# Using Homebrew (macOS)
brew install postgresql
brew services start postgresql

# Create database
createdb voting_app

# Access via psql
psql -U postgres -d voting_app
```

---

## Cloud Deployment with Terraform & Ansible

### Architecture Overview

The deployment creates a 3-tier infrastructure on AWS:
1. **Frontend EC2** (Public Subnet): Vote and Result services
2. **Backend EC2** (Private Subnet): Worker service and Redis
3. **Database EC2** (Private Subnet): PostgreSQL

### Prerequisites for Cloud Deployment

1. **AWS Credentials** configured:
```bash
aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (e.g., us-east-1)
# Enter: Default output format (json)
```

2. **SSH Key Pair** created:
```bash
# Create a new key pair
aws ec2 create-key-pair --key-name babajide-useast1-dvft \
  --region us-east-1 \
  --query 'KeyMaterial' --output text > babajide-useast1-dvft.pem

chmod 400 babajide-useast1-dvft.pem
```

3. **Update `.env` file** with your SSH key path:
```env
SSH_KEY_PATH=./babajide-useast1-dvft.pem
```

### Step 1: Deploy Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the infrastructure plan
terraform plan

# Apply the infrastructure
terraform apply -auto-approve

# View outputs (note the public IPs)
terraform output -json
```

**What gets created:**
- VPC with public and private subnets
- EC2 instances for frontend, backend, and database
- Security groups with appropriate ingress/egress rules
- S3 bucket for storage
- Network infrastructure (NAT Gateway, Internet Gateway)

### Step 2: Configure and Deploy with Ansible

```bash
cd ../ansible

# Update inventory with Terraform outputs (done automatically in site.yml)
# Or manually update inventory/dynamic.yml with EC2 instance IPs

# Run the Ansible playbook
ansible-playbook site.yml

# Or with verbose output
ansible-playbook -v site.yml
```

**What Ansible does:**
- Installs Docker and Docker Compose on all instances
- Deploys Vote service on frontend
- Deploys Result service on frontend
- Deploys Worker service on backend
- Deploys Redis on backend
- Deploys PostgreSQL on database instance
- Configures networking between services

### Step 3: Access Deployed Services

After deployment, Terraform outputs will show public IP addresses:

```bash
# Get Terraform outputs
terraform output

# Frontend public IP will be displayed
# Access Vote: http://<FRONTEND_PUBLIC_IP>:8080
# Access Result: http://<FRONTEND_PUBLIC_IP>:8081
```

### Step 4: Monitor and Troubleshoot

```bash
# SSH into frontend
ssh -i ./babajide-useast1-dvft.pem ubuntu@<FRONTEND_PUBLIC_IP>

# SSH into backend (via frontend as bastion)
ssh -i ./babajide-useast1-dvft.pem ubuntu@<BACKEND_PRIVATE_IP>

# Check docker containers
docker compose ps

# View application logs
docker compose logs -f vote
docker compose logs -f worker
docker compose logs -f result
```

### Step 5: Cleanup Cloud Resources

```bash
cd terraform

# Destroy all infrastructure
terraform destroy -auto-approve

# Or selectively destroy
terraform destroy -target=aws_instance.frontend
```

---

## Environment Configuration

### Using the `.env` File

The `.env` file contains all configuration for the application:

```env
# Container Images
FRONTEND_VOTE_IMAGE="babanila/vote:1.0"
FRONTEND_RESULT_IMAGE=b"abanila/result:1.0"
BACKEND_WORKER_IMAGE="babanila/worker:1.0"
REDIS_IMAGE="redis:7-alpine"
DB_IMAGE="postgres:15-alpine"

# SSH Configuration (for Ansible)
SSH_KEY_PATH=./babajide-useast1-dvft.pem

# Database Configuration
DB_USER="postgres"
DB_PASSWORD="postgres"
DB_NAME="postgres"
DB_PORT=5432

# Redis Configuration
REDIS_PORT=6379

# Flask Configuration
FLASK_ENV="development"

# Application Configuration
PORT=80
PG_USER="postgres"
PG_PASSWORD="postgres"
PG_DATABASE="postgres"
```

### Modifying Configuration

1. **Edit `.env` file**:
```bash
nano .env
```

2. **For Docker Compose**, restart services:
```bash
docker compose down
docker compose up -d
```

3. **For Terraform/Ansible**, re-run playbook:
```bash
cd ansible
ansible-playbook site.yml
```

---

## Accessing Services

### Local Development
| Service | URL | Port |
|---------|-----|------|
| Vote | http://localhost:8080 | 8080 |
| Result | http://localhost:8081 | 8081 |
| Redis | localhost:6379 | 6379 |
| PostgreSQL | localhost:5432 | 5432 |

### Cloud Deployment
| Service | URL | Port |
|---------|-----|------|
| Vote | http://<FRONTEND_IP>:8080 | 8080 |
| Result | http://<FRONTEND_IP>:8081 | 8081 |

### Accessing Databases

**PostgreSQL (local):**
```bash
psql -h localhost -U postgres -d postgres
```

**PostgreSQL (cloud - via SSH tunnel):**
```bash
ssh -i ./babajide-useast1-dvft.pem -L 5432:db:5432 ubuntu@<FRONTEND_PUBLIC_IP>
psql -h localhost -U postgres -d postgres
```

**Redis CLI (local):**
```bash
redis-cli
```

**Redis CLI (cloud - via SSH tunnel):**
```bash
ssh -i ./babajide-useast1-dvft.pem -L 6379:redis:6379 ubuntu@<FRONTEND_PUBLIC_IP>
redis-cli
```

---

## Troubleshooting

### Docker Compose Issues

**Services not starting:**
```bash
# Check logs
docker compose logs

# Verify images are available
docker images

# Pull missing images
docker compose pull

# Rebuild images
docker compose build --no-cache
```

**Connection refused errors:**
```bash
# Check if services are healthy
docker compose ps

# Verify network connectivity
docker compose exec vote ping redis
docker compose exec worker ping db
```

**Database connection errors:**
```bash
# Ensure database container is healthy
docker compose exec db pg_isready -U postgres

# Check environment variables
docker compose exec worker env | grep DB_
```

### Terraform Issues

**AWS credentials not found:**
```bash
aws configure
# Or set environment variables:
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_REGION=us-east-1
```

**SSH key permission errors:**
```bash
chmod 400 ./babajide-useast1-dvft.pem
```

**Terraform state conflicts:**
```bash
# Remove lock file if needed (use with caution)
rm .terraform.tfstate.lock.hcl
```

### Ansible Issues

**SSH connection timeouts:**
```bash
# Verify security group allows SSH (port 22)
aws ec2 describe-security-groups

# Check EC2 instance status
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name]'
```

**Inventory issues:**
```bash
# Verify inventory file
cat inventory/dynamic.yml

# Test connectivity
ansible all -i inventory/dynamic.yml -m ping
```

### Application Issues

**Votes not being processed:**
1. Check Worker container logs: `docker compose logs worker`
2. Verify Redis connection: `docker compose exec redis redis-cli`
3. Check database schema: `docker compose exec db psql -U postgres -d postgres -c "\dt"`

**Results not displaying:**
1. Check if Worker is processing votes
2. Verify database connectivity
3. Check Result service logs: `docker compose logs result`

### Network Issues

**Services can't communicate:**
```bash
# Check network
docker compose exec vote ping redis

# Verify DNS resolution
docker compose exec vote nslookup redis

# Check network configuration
docker network inspect <network_name>
```

---

## Common Commands Reference

### Docker Compose
```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Execute command in container
docker compose exec vote bash

# Rebuild images
docker compose build --no-cache

# View resource usage
docker compose stats

# Remove volumes
docker compose down -v
```

### Terraform
```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure
terraform destroy

# View outputs
terraform output

# View state
terraform state list
```

### Ansible
```bash
# Run playbook
ansible-playbook site.yml

# Run with verbose output
ansible-playbook -v site.yml

# Run specific role
ansible-playbook site.yml --tags backend

# Dry run
ansible-playbook site.yml --check
```

### AWS CLI
```bash
# List EC2 instances
aws ec2 describe-instances

# Get specific output
aws ec2 describe-instances --query 'Reservations[].Instances[].[PublicIpAddress,PrivateIpAddress]'

# View security groups
aws ec2 describe-security-groups

# View VPC details
aws ec2 describe-vpcs
```

---

## Next Steps

1. **Test the application** by voting on the Vote interface
2. **Monitor the system** through logs and dashboards
3. **Customize services** by modifying Dockerfiles and application code
4. **Scale infrastructure** by adjusting Terraform variables
5. **Implement monitoring** with CloudWatch or Prometheus
6. **Add CI/CD** with GitHub Actions or GitLab CI
7. **Implement backups** for PostgreSQL data

---

## Documentation Links

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)

---

## Support

For issues or questions:
1. Check logs: `docker compose logs`
2. Review this guide's Troubleshooting section
3. Check individual service documentation
4. Review architecture in `Repo_Architecture.md`

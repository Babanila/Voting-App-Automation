# Multi-Stack Voting Application Automation

A production-ready distributed voting system demonstrating modern DevOps practices with infrastructure as code, containerization, and configuration management.

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Files Arrangement](#files-arrangement)
3. [Architecture](#architecture)
4. [Features](#features)
5. [Product Automation Board](#product-board)
6. [How to Run / Demo](#how-to-run--demo)
7. [Debugging](#debugging)
8. [What Can Be Improved](#what-can-be-improved)

---

## Getting Started

### Prerequisites

**For Local Development (Docker Compose):**
- Docker v20.10+
- Docker Compose v2.0+
- Git

**For Cloud Deployment (AWS):**
- Terraform v1.0+
- Ansible v2.9+
- AWS CLI configured
- SSH key pair for EC2 instances

**For Local Component Development:**
- Python 3.10+ (Vote service)
- Node.js 18+ (Result service)
- .NET SDK 8.0+ (Worker service)
- PostgreSQL 15+
- Redis 7+

### Quick Start (Local with Docker Compose)

```bash
# Clone repository
git clone [Voting-App-Automation](https://github.com/Babanila/Voting-App-Automation)
cd Voting-App-Automation

# View/edit environment configuration
nano .env

# Start all services
docker compose up -d

# Access the application
# Vote Interface: http://localhost:8080
# Result Interface: http://localhost:8081

# Stop services
docker compose down
```

### Quick Start (Cloud with Terraform & Ansible)

```bash
# Configure AWS credentials
aws configure

# Create SSH key pair
aws ec2 create-key-pair --key-name babajide-useast1-dvft \
  --region us-east-1 \
  --query 'KeyMaterial' --output text > ansible/babajide-useast1-dvft.pem
chmod 400 ansible/babajide-useast1-dvft.pem

# Deploy infrastructure (Short Way)
# From the root folder (Voting-App-Automation)
./deploy.sh

# Deploy infrastructure (Long Way)
cd terraform
terraform init
terraform apply -auto-approve

# Deploy services with Ansible
cd ../ansible
ansible-playbook site.yml -v

# Get frontend IP and access services
cd terraform
terraform output frontend_public_ip
# http://<FRONTEND_IP>:8080 (Vote)
# http://<FRONTEND_IP>:8081 (Result)
```

---

## Files Arrangement

```
    .
    ├── .env
    ├── README.md
    ├── docker-compose.yml
    ├── Dockerfile
    │
    ├── vote/
    │   ├── app.py
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   ├── static/
    │   │   └── stylesheets/
    │   │       └── style.css
    │   └── templates/
    │       └── index.html
    │
    ├── result/
    │   ├── server.js
    │   ├── Dockerfile
    │   ├── package.json
    │   ├── views/
    │   │   ├── app.js
    │   │   ├── index.html
    │   │   ├── socket.io.js
    │   │   ├── angular.min.js
    │   │   └── stylesheets/
    │   │       └── style.css
    │
    ├── worker/
    │   ├── Program.cs
    │   ├── Dockerfile
    │   ├── Worker.csproj
    │   └── obj/
    │
    ├── healthchecks/
    │   ├── postgres.sh
    │   └── redis.sh
    │
    ├── terraform/
    │   ├── main.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── terraform.tfvars
    │   ├── terraform.tfstate
    │   ├── terraform.tfstate.backup
    │   └── modules/
    │       ├── vpc/
    │       │   ├── main.tf
    │       │   ├── outputs.tf
    │       │   └── variables.tf
    │       └── custom-bucket/
    │           ├── main.tf
    │           ├── outputs.tf
    │           └── variables.tf
    │
    └── ansible/
        ├── site.yml
        ├── ansible.cfg
        ├── group_vars/
        │   └── all.yml
        ├── inventory/
        │   └── dynamic.yml
        └── roles/
            ├── common/
            │   └── tasks/
            │       └── main.yml
            ├── cloudwatch/
            │   └── tasks/
            │       └── main.yml
            ├── frontend/
            │   └── tasks/
            │       └── main.yml
            ├── backend/
            │   └── tasks/
            │       └── main.yml
            └── database/
                └── tasks/
                    └── main.yml
```

---

## Architecture

### What

This is a **polyglot voting application** with multiple microservices in different languages:

| Service | Technology | Purpose |
|---------|-----------|---------|
| **Vote** | Python Flask | User interface for casting votes |
| **Result** | Node.js Express | Real-time vote counting interface |
| **Worker** | .NET 8.0 | Process votes from queue to database |
| **Redis** | In-memory store | Vote queue/temporary storage |
| **PostgreSQL** | SQL Database | Persistent vote storage |

### Architecture Diagram

**Local Development:**
```
┌──────────────────────────────┐
│    Docker Network (Local)    │
│                              │
│  ┌──────────┐  ┌──────────┐  │
│  │   Vote   │  │  Result  │  │
│  │ (8080)   │  │  (8081)  │  │
│  └────┬─────┘  └────┬─────┘  │
│       │             │        │
│       └──────┬──────┘        │
│              │               │
│        ┌─────▼──────┐        │
│        │   Redis    │        │
│        │  (6379)    │        │
│        └─────┬──────┘        │
│              │               │
│        ┌─────▼──────┐        │
│        │   Worker   │        │
│        │   (.NET)   │        │
│        └─────┬──────┘        │
│              │               │
│        ┌─────▼──────┐        │
│        │  PostgreSQL│        │
│        │  (5432)    │        │
│        └────────────┘        │
└──────────────────────────────┘
```

**Cloud Deployment (AWS):**
```
                        Internet
                           │
                      ┌────▼────┐
                      │ Bastion │ (Public EC2)
                      │ Host    │ SSH Entry Point
                      └────┬────┘
                           │
           ┌───────────────┼──────────────────┐
           │               │                  │
           │ SSH ProxyJump │                  │
           │               │                  │
    ┌──────▼────────┐  ┌───▼──────────┐  ┌----▼─────────┐
    │  Frontend     │  │   Backend    │  │  Database    │
    │  EC2 (Public) │  │ EC2(Private) │  │ EC2(Private) │
    │               │  │              │  │              │
    │ ┌──────────┐  │  │ ┌──────────┐ │  │ ┌──────────┐ │
    │ │   Vote   │  │  │ │ Worker   │ │  │ │PostgreSQL│ │
    │ │ (8080)   │  │  │ │  (C#)    │ │  │ │ (5432)   │ │
    │ └──────────┘  │  │ └────┬─────┘ │  │ └──────────┘ │
    │ ┌──────────┐  │  │ ┌────▼─────┐ │  └──────────────┘
    │ │  Result  │  │  │ │  Redis   │ │
    │ │ (8081)   │  │  │ │ (6379)   │ │
    │ └──────────┘  │  │ └──────────┘ │
    └──────────────┘  └──────────────┘
         ▲                    ▲               ▲
         └────────────────────┼───────────────┘
                    Managed by Ansible
                 (via Bastion ProxyJump)
```

### Who

This project is designed for:
- **DevOps Engineers** learning infrastructure as code (Terraform)
- **SysAdmins** learning configuration management (Ansible)
- **Developers** learning containerization and distributed systems
- **Teams** practicing multi-language microservices architecture

### Why

This project demonstrates:
- **Infrastructure as Code (IaC)** - Terraform provisioning on AWS
- **Configuration Management** - Ansible for deployment automation
- **Containerization** - Docker & Docker Compose for consistency
- **Multi-tier Architecture** - Separation of concerns (Frontend, Backend, Database)
- **Security Best Practices** - Private subnets, security groups, bastion hosts
- **Networking** - VPC, subnets, NAT gateways, security group rules
- **Polyglot Development** - Python, Node.js, .NET working together

---

## Features

✅ **Infrastructure as Code (Terraform)**
- Automatic AWS VPC provisioning
- Multi-tier subnet architecture (public/private)
- Auto-scaling security groups
- S3 bucket for storage
- Terraform state management

✅ **Configuration Management (Ansible)**
- Automatic Docker installation
- Service deployment and orchestration
- SSH key-based authentication
- Bastion host support (ProxyJump)
- Template-based configuration files (Jinja2)

✅ **Containerization (Docker & Docker Compose)**
- Pre-built images for all services
- Health checks and automated restarts
- Network isolation and communication
- Volume management for persistent data

✅ **Multi-Language Support**
- Python (Vote service)
- Node.js (Result service)
- .NET (Worker service)
- Works together in a single application

✅ **Production-Ready**
- Environment variable configuration
- Error handling and retry logic
- Service health checks
- Logging and monitoring hooks
- Security hardening (non-root users, closed ports)

---

## JIRA Board
This project can be view on the Atlassian board using the link below:
[Product Automation Board](https://product-automation.atlassian.net/jira/software/c/projects/VAA/boards/2)


## How to Run / Demo

### Local Development (Docker Compose)

**1. Start the application:**
```bash
docker compose up -d
```

**2. Cast a vote:**
- Open http://localhost:8080
- Vote for your choice
- Submit your vote

**3. View results:**
- Open http://localhost:8081
- Results update in real-time

**4. Check logs:**
```bash
# View all logs
docker compose logs -f

# View specific service
docker compose logs -f vote
docker compose logs -f worker
docker compose logs -f result
```

**5. Verify data in database:**
```bash
# Connect to PostgreSQL
docker compose exec db psql -U postgres -d postgres

# View votes table
\dt
SELECT * FROM votes;
```

### Cloud Deployment (Terraform + Ansible)

**1. Deploy infrastructure:**
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
terraform output  # Save these values
```

**2. Deploy services:**
```bash
cd ../ansible
ansible-playbook site.yml -v
```

**3. Access application:**
```bash
# Get frontend public IP
terraform output frontend_public_ip

# Vote: http://<IP>:8080
# Results: http://<IP>:8081
```

**4. Monitor services:**
```bash
# SSH into frontend
ssh -i ansible/babajide-useast1-dvft.pem ubuntu@<FRONTEND_IP>

# Check containers
docker compose ps

# View logs
docker compose logs -f vote
```

**5. Clean up:**
```bash
cd terraform
terraform destroy -auto-approve
```

---

## Debugging

### Common Issues & Solutions

#### Docker Compose Issues

**Services failing to start:**
```bash
# Check container logs
docker compose logs vote

# Verify images exist
docker images | grep babanila

# Rebuild images
docker compose build --no-cache
```

**"Image must be a string" error:**
- Environment variables not loaded
- Solution: Export `.env` before running
  ```bash
  export $(cat .env | grep -v '^#' | xargs)
  docker compose up -d
  ```

**Connection refused between services:**
```bash
# Check service health
docker compose ps

# Test connectivity
docker compose exec vote ping redis

# Check network
docker network ls
docker network inspect <network_name>
```

#### Terraform Issues

**"AWS credentials not found":**
```bash
aws configure
# Or set environment variables:
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_REGION=us-east-1
```

**"Permission denied" for SSH key:**
```bash
sudo chmod 400 ansible/babajide-useast1-dvft.pem
```

**Terraform state locked:**
```bash
# Remove lock file (use carefully!)
rm .terraform.tfstate.lock.hcl
```

#### Ansible Issues

**"Could not match supplied host pattern":**
- Hosts haven't been created yet
- Solution: Run full playbook first
  ```bash
  ansible-playbook site.yml
  ```

**SSH connection timeout:**
```bash
# Verify security group allows SSH (port 22)
aws ec2 describe-security-groups

# Check instance status
aws ec2 describe-instances --query \
  'Reservations[].Instances[].[InstanceId,State.Name]'
```

**Null variable in Jinja2 template:**
```bash
# Ensure environment variables are exported
set -a && source .env && set +a
ansible-playbook site.yml -v
```

#### Application Issues

**Votes not processing:**
1. Check Worker logs: `docker compose logs worker`
2. Verify Redis: `docker compose exec redis redis-cli PING`
3. Check database connection: `docker compose logs db`

**Results not displaying:**
1. Verify Worker is running
2. Check database has votes: `docker compose exec db psql -U postgres -d postgres -c "SELECT * FROM votes;"`
3. Check Result service logs: `docker compose logs result`

**Database errors:**
```bash
# Check database health
docker compose exec db pg_isready -U postgres

# View database logs
docker compose logs db

# Connect to database
docker compose exec db psql -U postgres
```

### Debugging Commands

```bash
# Container inspection
docker compose ps
docker compose logs -f <service>
docker compose exec <service> bash

# Network debugging
docker compose exec <service> ping <other_service>
docker compose exec <service> nslookup <other_service>

# Database access
docker compose exec db psql -U postgres -d postgres
redis-cli  # if running locally

# AWS resources
aws ec2 describe-instances
aws ec2 describe-security-groups
aws vpc describe-vpcs

# Ansible debugging
ansible-playbook site.yml --check  # Dry run
ansible-playbook site.yml -vvv     # Very verbose
ansible all -m ping                # Test connectivity
```

---

## What Can Be Improved

   - [ ] Add Application Load Balancer (ALB)
   - [ ] Configure Auto Scaling Groups
   - [ ] Implement multi-AZ deployment
   - [ ] Integrate CloudWatch for AWS monitoring
   - [ ] GitHub Actions workflow for automated testing
   - [ ] Implement secrets management (AWS Secrets Manager)
   - [ ] Rotate database credentials automatically
   - [ ] Automated rollback on failure
   - [ ] PostgreSQL automated backups to S3
   - [ ] Add caching layer (CloudFront CDN)
   - [ ] Migrate to Kubernetes (EKS) for orchestration


---

## Quick Reference

### Docker Compose Commands
```bash
docker compose up -d              # Start all services
docker compose down               # Stop all services
docker compose logs -f            # View logs
docker compose ps                 # List running containers
docker compose exec <svc> bash    # Access container shell
```

### Terraform Commands
```bash
terraform init                    # Initialize
terraform plan                    # Preview changes
terraform apply -auto-approve     # Deploy
terraform destroy -auto-approve   # Destroy all resources
terraform output                  # Show outputs
```

### Ansible Commands
```bash
ansible-playbook site.yml         # Run playbook
ansible-playbook -v site.yml      # Verbose output
ansible-playbook --check site.yml # Dry run
ansible all -m ping               # Test connectivity
```

---

## Support & Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## License

© 2026 Babajide

---

**Last Updated:** April 28, 2026

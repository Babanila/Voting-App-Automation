# Repository Structure

## Architecture Diagram (3-Tier + Redis on Backend)

                         ┌──────────────────────────┐
                         │        Internet          │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │     Frontend EC2         │
                         │  (Public Subnet)         │
                         │                          │
                         │  ┌────────────────────┐  │
                         │  │ vote (port 8081)   │◄─┼── Users access app
                         │  └────────────────────┘  │
                         │                          │
                         │  ┌────────────────────┐  │
                         │  │ result (port 8080) │◄─┼── Users view results
                         │  └────────────────────┘  │
                         └────────────┬─────────────┘
                                      │
                     Redis (6379)     │      Postgres (5432)
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │     Backend EC2          │
                         │   (Private Subnet)       │
                         │                          │
                         │  ┌────────────────────┐  │
                         │  │ worker             │  │
                         │  │ (process votes)    │  │
                         │  └─────────┬──────────┘  │
                         │            │             │
                         │  ┌─────────▼──────────┐  │
                         │  │ redis (port 6379) │◄─┼── Frontend connects here
                         │  └────────────────────┘  │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │     Database EC2         │
                         │   (Private Subnet)       │
                         │                          │
                         │  ┌────────────────────┐  │
                         │  │ postgres (5432)    │◄─┼── Backend connects here
                         │  └────────────────────┘  │
                         └──────────────────────────┘

## Repository Arrangment
voting-app-devops/
    │
    ├── vote/
    ├── result/
    ├── worker/
    ├── docker-compose.yml
    └── README.md
    └── README-Arc-Docs.md
    │
    ├── terraform/
    │   ├── modules
    │   |     ├── custom-bucket
    │   |     |     ├── main.tf
    │   |     |     ├── outputs.tf
    │   |     |     ├── variables.tf
    │   |     ├── vpc
    │   |     |     ├── main.tf
    │   |     |     ├── outputs.tf
    │   |     |     ├── variables.tf
    │   ├── main.tf
    │   ├── providers.tf
    │   ├── outputs.tf
    │   ├── variables.tf
    │
    ├── ansible/
    |   ├── site.yml
    │   ├── inventory/
    │   │   └── dynamic.yml
    │   ├── group_vars/
    │   │   └── all.yml
    │   │
    │   ├── roles/
    │   │   ├── common/
    │   │   │   └── tasks/main.yml
    │   │   │
    │   │   ├── frontend/
    │   │   │   ├── tasks/main.yml
    │   │   │   └── templates/docker-compose.yml.j2
    │   │   │
    │   │   ├── backend/
    │   │   │   ├── tasks/main.yml
    │   │   │   └── templates/docker-compose.yml.j2
    │   │   │
    │   │   └── database/
    │   │       ├── tasks/main.yml
    │   │       └── templates/docker-compose.yml.j2


## Execution Flow
site.yml
   │
   ├── Runs Terraform (provision EC2)
   │
   ├── Builds dynamic inventory (frontend, backend, database)
   │
   ├── Applies "common" role → installs Docker everywhere
   │
   ├── Applies "frontend" role
   │       └── Renders docker-compose.yml (Jinja2)
   │       └── Runs vote + result containers
   │
   ├── Applies "backend" role
   │       └── Renders docker-compose.yml
   │       └── Runs worker + redis
   │
   └── Applies "database" role
           └── Renders docker-compose.yml
           └── Runs postgres


## Ansible orchestrator (Ansible SSHes THROUGH frontend)
Ansible (local/CI)
    │
    └── SSH → Frontend (public EC2)
            │
            |── SSH → Backend (private EC2)
            └── SSH → Database (private EC2)

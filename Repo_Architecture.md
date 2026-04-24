# Repository Structure

voting-app-devops/
    │
    ├── vote/
    ├── result/
    ├── worker/
    ├── docker-compose.yml
    │
    ├── terraform/
    │   ├── main.tf
    │   ├── variables.tf
    │
    ├── ansible/
    │   ├── inventory
    │   ├── playbook.yml
    │
    └── README.md
    └── README-Arc-Docs.md


## Branch Strategy
-   main → stable
-   dev → integration
    - Feature branches:  
        - feature/dockerize-vote  
        - feature/terraform-setup  
        - feature/ansible-deploy



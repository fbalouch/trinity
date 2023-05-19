# Ansible vs. Terraform

- [Ansible vs. Terraform](#ansible-vs-terraform)
  - [Overview](#overview)
  - [Tulladew (Flask App)](#tulladew-flask-app)
      - [App Request Sequence Diagram](#app-request-sequence-diagram)
      - [Infrastructure Diagram](#infrastructure-diagram)
  - [Ansible](#ansible)
    - [How to Deploy using Ansible](#how-to-deploy-using-ansible)
  - [Terraform](#terraform)
    - [How to Deploy using Terraform](#how-to-deploy-using-terraform)
  - [Summary](#summary)

## Overview
Ansible and Terraform are both DevOps tools that facilitate efficient management and configuration of IT infrastructure. However, they have distinct differences in terms of design, functionality, and use-cases. Ansible, an open-source automation tool, is known for its robust configuration management and app-deployment capabilities. In contrast, Terraform specializes in provisioning modular infrastructure across various cloud service providers, such as AWS. This project builds a containerized Python Flask app and examines how it can be deployed on AWS using both Ansible and Terraform. The infrastructure used is a development environment with a single EC2 t2.micro instance deployed in the default VPC, accessible via its public IP.

![arch](ansible-vs-terraform.png)

## Tulladew (Flask App)
Tulladew is a containerized Flask app. It uses the native Python HTTP client to get instance metadata from EC2 [Instance Metadata Service v2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html). Additional request information (incoming user-agent and remote IP) is retrieved from the Flask request. Jinja2 template is used to build and return HTML. Gunicorn is used as the Python Web Server Gateway Interface. 

#### App Request Sequence Diagram
![arch](tulladew.puml.png)

#### Infrastructure Diagram
![arch](tulladew.png)


## Ansible

| Pros | Cons |
| --- | --- |
| 1. Ease of use - Ansible uses YAML syntax, easy to read and write. | 1. Procedural style - You need to define the order of execution, which can be complex for large deployments. |
| 2. Agentless - There's no need to install additional software or agents on the managed nodes. | 2. Scalability - While Ansible can be used for large deployments, it may not scale as efficiently as Terraform. |
| 3. Configuration Management - Ansible excels at configuration management tasks. | 3. Infrastructure management - Not as good when compared with Terraform |

### How to Deploy using Ansible


## Terraform

| Pros | Cons |
| --- | --- |
| 1. Declarative language - You define what the infrastructure should be and Terraform figures out how to achieve that state. | 1. Learning curve - HashiCorp Configuration Language (HCL) can have a steeper learning curve for those new to it. |
| 2. Provider agnostic - Terraform supports a multitude of providers, so it can manage a diverse range of infrastructures. | 2. No configuration management - Terraform lacks in-built configuration management features and needs to be integrated with other tools for this. |
| 3. Immutable Infrastructure - It adheres to the concept of immutable infrastructure. | 3. State file management - The state file must be managed carefully, especially when used in a team. |

### How to Deploy using Terraform

## Summary
Ansible, with its simple YAML syntax and robust configuration management capabilities, is good for small projects that require quick setup and consistent state management. However, for larger projects, Terraform shines due to its advanced infrastructure provisioning and provider-agnostic features, ideal for managing diverse, large-scale environments. Combined with other application orchestration tools, Terraform adheres to the principle of immutable infrastructure, preventing configuration drift and reducing inconsistencies, making it a preferable choice for complex, larger-scale projects.
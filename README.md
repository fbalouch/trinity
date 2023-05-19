# Ansible vs. Terraform

- [Ansible vs. Terraform](#ansible-vs-terraform)
  - [Overview](#overview)
  - [Tulladew (Flask App)](#tulladew-flask-app)
      - [App Request Sequence Diagram](#app-request-sequence-diagram)
      - [Infrastructure Diagram](#infrastructure-diagram)
  - [Ansible](#ansible)
  - [Terraform](#terraform)

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


## Terraform
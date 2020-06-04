# Ansible Lab Environment
Terraform project to build an Ansible lab environment on AWS for teaching and learning purposes.

### Overview
An ansible config file and a dynamic inventory for AWS is included and is copied to the bastion host during provisioning. This can be used as the inventory file for Ansible actions in the lab and will only pick up hosts with the lab environment tag (defined in Terraform config).

A simple playbook is included on the Bastion host to install Docker and create some example containers.

### AWS Authentication
To allow Terraform to authenticate with AWS you need to use one of the authentication methods used in the provider documentation:

https://www.terraform.io/docs/providers/aws/index.html#authentication

If you have an access key configured you can have them set as environment variable, for example:

`export AWS_ACCESS_KEY_ID="SSFFSSDSADADSADSADS"`

`export AWS_SECRET_ACCESS_KEY="supersecret"`

## SSH Key Pair
This project assumes that an SSH key pair has already been created in AWS and the private key is downloaded to your machine. You will need to provide the SSH key path and AWS key name to the Terraform configuration.

## Bastion Host
The lab is accessible via a bastion host provisioned by this Terraform configuration. This can be accessed via SSH and is the gateway into the rest of the lab environment. For example:

`ssh -i ~/.ssh/lw.pem ubuntu@34.254.204.84`

NOTE: You must also configure an AWS authentication method on this host in order for the dynamic inventory and other API calls to AWS functionality to work.

### To-Do
- AWS Tags
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

## Usage
Apply this configuration, you must have Terraform installed. You will be prompted for variable values defined in vars.tf. It's recommended to create a tfvars file to apply these more easily:

`terraform init`

`terraform plan -var-file=myvars.tfvars`

`terraform apply -var-file=myvars.tfvars`



## Bastion Host
The lab is accessible via a bastion host provisioned by this Terraform configuration. This can be accessed via SSH and is the gateway into the rest of the lab environment. For example:

`ssh -i ~/.ssh/lw.pem ubuntu@34.254.204.84`

NOTE: You must also configure an AWS authentication method on this host in order for the dynamic inventory and other API calls to AWS functionality to work.

The key pair you defined will be available on the Bastion host as ~/.ssh/key.pem allowing you to authenticate against the lab nodes.

## Dynamic Inventory
./aws_ec2.yml included with this project is a dynamic Ansible inventory, you can use this to target the lab nodes with Ansible. To show the contents of this you can use:

`ansible-inventory -i aws_ec2.yml --graph`

### To-Do
- AWS Tags
# Ansible Lab Environment
Terraform project to build an Ansible lab environment on AWS.

### Overview
An ansible config file and a dynamic inventory for AWS is included and is copied to the bastion host during provisioning. This can be used as the inventory file for Ansible actions in the lab and will only pick up hosts with the lab environment tag (defined in Terraform config)

### AWS Authentication
To allow Terraform to authenticate with AWS you need to use one of the authentication methods used in the provider documentation:

https://www.terraform.io/docs/providers/aws/index.html#authentication

If you have an access key configured you can have them set as environment variable, for example:

`export AWS_ACCESS_KEY_ID="SSFFSSDSADADSADSADS"`

`export AWS_SECRET_ACCESS_KEY="supersecret"`

## SSH Key Pair
This project assumes that an SSH key pair has already been created in AWS called 'lw' and the private key is downloaded to your machine.

## Bastion Host
The lab is accessible via a bastion host provisioned by this Terraform configuration. This can be accessed via SSH and is the gateway into the rest of the lab environment. For example

`ssh -i ~/.ssh/lw.pem ubuntu@34.254.204.84`

NOTE: You must also configure an AWS authentication method on this host in order for the dynamic inventory and other API calls to AWS functionality to work.

### To-Do
- Hide the lab instances behind a NAT gateway rather than have public IPs assigned to all nodes.
- Parametise the configuration with variables.
# Configure the AWS Provider
provider "aws" {
  version = "2.7"
  region  = "eu-west-1"

  #Export AWS Credentials as environment vars:
  # export AWS_ACCESS_KEY_ID="anaccesskey"
  # export AWS_SECRET_ACCESS_KEY="asecretkey"
}
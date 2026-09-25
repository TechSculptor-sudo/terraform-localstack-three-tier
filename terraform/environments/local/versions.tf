# Pins the Terraform CLI and AWS provider versions so every machine
# (your laptop, GitHub Actions) behaves the same way.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # any 6.x, never an untested 7.0
    }
  }
}
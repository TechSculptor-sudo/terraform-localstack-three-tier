# Phase 3: no resources yet -- only read-only lookups ("data sources") that
# prove Terraform can reach LocalStack. Modules are added from Phase 4 on.

# Who am I talking to? The postcondition is a 4th safety guard that shows up
# clearly in `terraform plan` if the account is ever not LocalStack's.
data "aws_caller_identity" "current" {
  lifecycle {
    postcondition {
      condition     = self.account_id == local.localstack_account_id
      error_message = "Terraform is NOT talking to LocalStack (account ${self.account_id}). Stop and check providers.tf."
    }
  }
}

data "aws_region" "current" {}

# The AZs we will spread subnets across in Phase 4.
data "aws_availability_zones" "available" {
  state = "available"
}
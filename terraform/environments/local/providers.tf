# ---------------------------------------------------------------------------
# AWS provider -> LocalStack ONLY
#
# SAFETY: this environment must never talk to real AWS. Three guards:
#   1. Every endpoint points at LocalStack (var.localstack_endpoint, which is
#      validated to be localhost:4566 in variables.tf).
#   2. Dummy credentials "test"/"test". They are only accepted by LocalStack;
#      real AWS rejects them, so even a misrouted call cannot authenticate.
#   3. allowed_account_ids: the provider refuses to run unless the account
#      it is talking to is LocalStack's fake account 000000000000.
# ---------------------------------------------------------------------------
provider "aws" {
  region = var.region

  # Dummy credentials for LocalStack emulation only. NOT secrets, and NEVER
  # a pattern to copy for real AWS (use OIDC / IAM roles there).
  access_key = "test"
  secret_key = "test"

  allowed_account_ids = [local.localstack_account_id]

  # Keep these false: the provider calls STS GetCallerIdentity (on LocalStack)
  # at startup, which is what makes allowed_account_ids actually work.
  skip_credentials_validation = false
  skip_requesting_account_id  = false

  # There is no EC2 instance metadata service on your laptop.
  skip_metadata_api_check = true

  # Only the services enabled in docker-compose.yml (SERVICES=ec2,iam,sts).
  # If a later phase needs another AWS service, add its endpoint here too.
  endpoints {
    ec2 = var.localstack_endpoint
    iam = var.localstack_endpoint
    sts = var.localstack_endpoint
  }

  # Tags added automatically to every resource this provider creates.
  default_tags {
    tags = local.common_tags
  }
}
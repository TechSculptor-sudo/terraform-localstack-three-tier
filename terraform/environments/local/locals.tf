locals {
  # LocalStack's fake AWS account. A real AWS account ID is never all zeros.
  localstack_account_id = "000000000000"

  # e.g. "three-tier-local" -- used to name resources in later phases.
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
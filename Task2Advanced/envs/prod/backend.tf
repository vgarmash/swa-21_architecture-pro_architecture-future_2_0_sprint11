# =============================================================================
# Terraform Backend Configuration
# =============================================================================
# Backend: Yandex Object Storage (S3-compatible)
# =============================================================================

terraform {
  backend "s3" {
    # Yandex Object Storage endpoint
    endpoint = "https://storage.yandexcloud.net"

    # Bucket name for Terraform state
    bucket = "yc-bucket-terraform-state"

    # State file path within bucket
    key = "prod/terraform.tfstate"

    # Region (required for S3 backend)
    region = "ru-central1"

    # Credentials are provided via environment variables:
    # - AWS_ACCESS_KEY_ID (или YC_ACCESS_KEY)
    # - AWS_SECRET_ACCESS_KEY (или YC_SECRET_KEY)

    # Enable encryption for state file
    encrypt = true

    # Use path-style addressing (required for Yandex Object Storage)
    force_path_style = true
  }
}

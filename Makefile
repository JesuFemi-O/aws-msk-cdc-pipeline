# Variables
AWS_REGION=us-east-2
BUCKET_NAME?=$(TF_STATE_BUCKET_NAME)
PROFILE=

# Optional profile flag
ifdef PROFILE
  PROFILE_FLAG=--profile $(PROFILE)
else
  PROFILE_FLAG=
endif

.PHONY: create-bucket terraform-init build-layer clean

# Validate bucket name presence
ifndef BUCKET_NAME
$(error BUCKET_NAME is not set. Please export TF_STATE_BUCKET_NAME in your environment.)
endif

# Create the S3 bucket for Terraform backend
create-bucket:
	@echo "Checking if bucket $(BUCKET_NAME) exists..."
	@aws s3api head-bucket --bucket $(BUCKET_NAME) --region $(AWS_REGION) $(PROFILE_FLAG) >/dev/null 2>&1 || \
	( echo "Bucket does not exist. Creating bucket $(BUCKET_NAME) in region $(AWS_REGION)..."; \
	aws s3api create-bucket \
		--bucket $(BUCKET_NAME) \
		--region $(AWS_REGION) \
		--create-bucket-configuration LocationConstraint=$(AWS_REGION) \
		$(PROFILE_FLAG) >/dev/null )
	@echo "Bucket $(BUCKET_NAME) exists."
	@echo "Checking if versioning is already enabled on bucket $(BUCKET_NAME)..."
	@aws s3api get-bucket-versioning --bucket $(BUCKET_NAME) $(PROFILE_FLAG) | grep '"Status": "Enabled"' >/dev/null 2>&1 || \
	( echo "Versioning is not enabled. Enabling versioning on bucket $(BUCKET_NAME)..."; \
	aws s3api put-bucket-versioning \
		--bucket $(BUCKET_NAME) \
		--versioning-configuration Status=Enabled \
		$(PROFILE_FLAG) >/dev/null )
	@echo "Bucket $(BUCKET_NAME) is ready and versioning is enabled (if it wasn't already)."

# Prepare backend config for core module
prepare-backend-core:
	@if [ ! -f terraform/core/backend.tfvars ]; then \
		echo "🔧 No backend.tfvars found in terraform/core."; \
		if [ -f terraform/core/backend.tfvars.example ]; then \
			cp terraform/core/backend.tfvars.example terraform/core/backend.tfvars; \
			echo "📄 Created terraform/core/backend.tfvars from backend.tfvars.example."; \
			echo "✍️  Please review and edit terraform/core/backend.tfvars before proceeding."; \
		else \
			echo "❌ backend.tfvars.example not found in terraform/core. Please add one."; \
			exit 1; \
		fi \
	else \
		echo "✅ terraform/core/backend.tfvars already exists."; \
	fi

prepare-backend-msk-base:
	@if [ ! -f terraform/msk-base/backend.tfvars ]; then \
		echo "🔧 No backend.tfvars found in terraform/msk-base."; \
		if [ -f terraform/msk-base/backend.tfvars.example ]; then \
			cp terraform/msk-base/backend.tfvars.example terraform/msk-base/backend.tfvars; \
			echo "📄 Created terraform/msk-base/backend.tfvars from backend.tfvars.example."; \
			echo "✍️  Please review and edit terraform/msk-base/backend.tfvars before proceeding."; \
		else \
			echo "❌ backend.tfvars.example not found in terraform/msk-base. Please add one."; \
			exit 1; \
		fi \
	else \
		echo "✅ terraform/msk-base/backend.tfvars already exists."; \
	fi

terraform-init-core:
	@echo "Initializing Terraform backend for core..."
	@cd terraform/core && terraform init -backend-config=backend.tfvars $(PROFILE_FLAG)

terraform-init-msk-base:
	@echo "Initializing Terraform backend for core..."
	@cd terraform/msk-base && terraform init -backend-config=backend.tfvars $(PROFILE_FLAG)
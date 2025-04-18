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
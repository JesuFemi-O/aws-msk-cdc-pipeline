###################### KAFKA CONNECT ROLE FOR EC2 ########################

data "aws_iam_policy_document" "ec2_kafka_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kafka_connect_role_ec2" {
  name               = "CustomDataEngPOCkafkaConnectRoleEC2"
  assume_role_policy = data.aws_iam_policy_document.ec2_kafka_assume_role.json
}

# Attach the custom DataEngCustomKafkaClusterList policy
resource "aws_iam_role_policy_attachment" "custom_kafka_cluster_list" {
  role       = aws_iam_role.kafka_connect_role_ec2.name
  policy_arn = aws_iam_policy.cdc_custom_kafka_cluster_list.arn
}

# Attach the AmazonMSKFullAccess managed policy
resource "aws_iam_role_policy_attachment" "msk_full_access" {
  role       = aws_iam_role.kafka_connect_role_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonMSKFullAccess"
}

# Attach the AmazonS3ReadOnlyAccess managed policy
resource "aws_iam_role_policy_attachment" "s3_read_only_access" {
  role       = aws_iam_role.kafka_connect_role_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


####################### MSK Service role for MSK connect connectors #########################
# Define the assume role policy (trust relationship)
data "aws_iam_policy_document" "msk_service_trust_relationship" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kafkaconnect.amazonaws.com"]
    }
  }
}

# Create the IAM Role
resource "aws_iam_role" "msk_service_role" {
  name               = "CustomDataEngPOCMSKServiceRole"
  assume_role_policy = data.aws_iam_policy_document.msk_service_trust_relationship.json
}

# Attach the AmazonS3FullAccess AWS managed policy
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.msk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach the CloudWatchFullAccess AWS managed policy
resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
  role       = aws_iam_role.msk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}


# Attach the custom DataEngCustomKafkaConnect policy
resource "aws_iam_role_policy_attachment" "custom_kafka_connect" {
  role       = aws_iam_role.msk_service_role.name
  policy_arn = aws_iam_policy.cdc_custom_kafka_connect.arn
}

resource "aws_iam_role_policy_attachment" "kafka_cluster_list_for_msk_service_role" {
  role       = aws_iam_role.msk_service_role.name
  policy_arn = aws_iam_policy.cdc_custom_kafka_cluster_list.arn
}
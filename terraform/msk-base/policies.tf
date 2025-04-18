############################# KAFKA CLUSTER LIST POLICY ##################################

data "aws_iam_policy_document" "cdc_custom_kafka_cluster_list" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"

    actions = [
      "kafka-cluster:DescribeTopicDynamicConfiguration",
      "kafka-cluster:DescribeCluster",
      "kafka-cluster:ReadData",
      "kafka-cluster:WriteData",
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:DescribeTransactionalId",
      "kafka-cluster:DescribeGroup",
      "kafka-cluster:DescribeClusterDynamicConfiguration",
      "kafka-cluster:Connect",
      "kafka-cluster:CreateTopic",
      "kafka-cluster:AlterGroup"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cdc_custom_kafka_cluster_list" {
  name        = "CustomCDCDemoKafkaClusterList"
  description = "Policy for custom Kafka cluster permissions"
  policy      = data.aws_iam_policy_document.cdc_custom_kafka_cluster_list.json
}

############################# KAFKA CONNECT POLICY ##################################

data "aws_iam_policy_document" "cdc_custom_kafka_connect" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface"
    ]

    resources = [
      "arn:aws:ec2:*:*:network-interface/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface"
    ]

    resources = [
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:security-group/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:aws:ec2:*:*:network-interface/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:AttachNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:DeleteNetworkInterface"
    ]

    resources = [
      "arn:aws:ec2:*:*:network-interface/*"
    ]
  }
}

resource "aws_iam_policy" "cdc_custom_kafka_connect" {
  name        = "CustomCDCDemoKafkaConnect"
  description = "Policy for custom Kafka Connect permissions"
  policy      = data.aws_iam_policy_document.cdc_custom_kafka_connect.json
}


############################# KAFKA MSK MANAGEMENT POLICY ##################################
data "aws_iam_policy_document" "kafka_msk_management" {
  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:*Topic*",
      "kafka-cluster:AlterGroup",
      "kafka-cluster:ReadData",
      "kafka-cluster:DescribeCluster",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeGroup",
      "kafka-cluster:Connect",
      "kafka-cluster:WriteData"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "kafka_msk_management" {
  name        = "CustomCDCDemoKafkaMSKManagement"
  description = "Policy for managing Kafka MSK clusters"
  policy      = data.aws_iam_policy_document.kafka_msk_management.json
}

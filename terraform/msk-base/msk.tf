resource "aws_cloudwatch_log_group" "msk_log_group" {
  name              = local.cloud_watch_group_name
  retention_in_days = local.cloud_watch_log_retention_in_days
}

resource "aws_msk_configuration" "msk_config" {
  name            = local.msk_config_name
  kafka_versions  = [local.kafka_version]
  server_properties = data.local_file.server_properties.content
}

resource "aws_msk_cluster" "cdc_poc_msk_cluster" {
  cluster_name           = local.msk_cluster_name
  kafka_version          = local.kafka_version
  number_of_broker_nodes = 3
  broker_node_group_info {
    instance_type  = local.kafka_instance_type
    client_subnets = [
      data.aws_subnet.private_subnet_2.id,
      data.aws_subnet.private_subnet_4.id,
      data.aws_subnet.private_subnet_5.id,
    ]
    security_groups = [aws_security_group.msk_security_group.id]
  }
  configuration_info {
    arn      = aws_msk_configuration.msk_config.arn
    revision = aws_msk_configuration.msk_config.latest_revision
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_log_group.name
      }
    }
  }
  client_authentication {
    unauthenticated = true
    sasl {
      iam = true
    }
  }
}

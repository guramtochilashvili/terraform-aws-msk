################################################################################
# Connector
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create ? 1 : 0

  name              = "/aws/msk-connector/${var.prefix}-connector"
  retention_in_days = var.cloud_watch_log_group.retention_in_days
  kms_key_id        = var.cloud_watch_log_group.kms_key_id
}


resource "aws_mskconnect_connector" "this" {
  count = var.create ? 1 : 0
  name  = "${var.prefix}-connector"

  kafkaconnect_version = var.kafkaconnect_version

  worker_configuration {
    arn      = aws_mskconnect_worker_configuration.this[0].arn
    revision = aws_mskconnect_worker_configuration.this[0].latest_revision
  }

  capacity {
    dynamic "autoscaling" {
      for_each = var.capacity_configuration.autoscaling != null ? [1] : []
      content {
        max_worker_count = var.capacity_configuration.autoscaling.max_worker_count
        min_worker_count = var.capacity_configuration.autoscaling.min_worker_count
        mcu_count        = var.capacity_configuration.autoscaling.mcu_count
        dynamic "scale_in_policy" {
          for_each = var.capacity_configuration.autoscaling.scale_in_policy_cpu_utilization_percentage != null ? [1] : []
          content {
            cpu_utilization_percentage = var.capacity_configuration.autoscaling.scale_in_policy_cpu_utilization_percentage
          }
        }
        dynamic "scale_out_policy" {
          for_each = var.capacity_configuration.autoscaling.scale_out_policy_cpu_utilization_percentage != null ? [1] : []
          content {
            cpu_utilization_percentage = var.capacity_configuration.autoscaling.scale_out_policy_cpu_utilization_percentage
          }
        }
      }
    }

    dynamic "provisioned_capacity" {
      for_each = var.capacity_configuration.provisioned_capacity != null ? [1] : []
      content {
        worker_count = var.capacity_configuration.provisioned_capacity.worker_count
        mcu_count    = var.capacity_configuration.provisioned_capacity.mcu_count
      }
    }
  }

  connector_configuration = var.connector_configuration

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = var.kafka_cluster.bootstrap_servers

      vpc {
        security_groups = var.kafka_cluster.security_groups
        subnets         = var.kafka_cluster.subnets
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = var.kafka_cluster_authentication_type
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = var.kafka_cluster_encryption_type
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.this[0].arn
      revision = aws_mskconnect_custom_plugin.this[0].latest_revision
    }
  }

  service_execution_role_arn = var.service_execution_role_arn

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.this[0].name
      }
      dynamic "firehose" {
        for_each = var.log_delivery.firehose_delivery_stream != null ? [1] : []
        content {
          enabled         = true
          delivery_stream = var.log_delivery.firehose_delivery_stream
        }
      }
      dynamic "s3" {
        for_each = var.log_delivery.s3_bucket != null && var.log_delivery.s3_prefix != null ? [1] : []
        content {
          enabled = true
          bucket  = var.log_delivery.s3_bucket
          prefix  = var.log_delivery.s3_prefix
        }
      }
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}

################################################################################
# Connect Custom Plugin
################################################################################

resource "aws_mskconnect_custom_plugin" "this" {
  count        = var.create ? 1 : 0
  name         = "${var.prefix}-plugin"
  content_type = var.content_type

  location {
    s3 {
      bucket_arn     = var.location.bucket_arn
      file_key       = var.location.file_key
      object_version = var.location.object_version
    }
  }

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
  }
}

################################################################################
# Connect Worker Configuration
################################################################################

resource "aws_mskconnect_worker_configuration" "this" {
  count = var.create ? 1 : 0

  name                    = "${var.prefix}-worker-config-${random_id.worker_config_name.hex}"
  properties_file_content = var.worker_config_properties_file_content
}

resource "random_id" "worker_config_name" {
  byte_length = 8
}

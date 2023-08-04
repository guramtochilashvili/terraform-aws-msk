locals {
  msk-connect-list = [
    {
      prefix               = "example-msk"
      kafkaconnect_version = "2.7.1"
      capacity_configuration = {
        provisioned_capacity = {
          worker_count = 1
          mcu_count    = 1
        }
      }
      connector_configuration = {
        "connector.class"      = "example-config"
        "s3.region"            = "example-config"
        "flush.size"           = "example-config"
        "schema.compatibility" = "example-config"
        "tasks.max"            = "example-config"
        "timezone"             = "example-config"
        "topics.regex"         = "example-config"
        "locale"               = "example-config"
        "format.class"         = "example-config"
        "partitioner.class"    = "example-config"
        "value.converter"      = "example-config"
        "storage.class"        = "example-config"
        "s3.bucket.name"       = "example-config"
        "timestamp.extractor"  = "example-config"
        "key.converter"        = "example-config"


      }

      kafka_cluster = {
        bootstrap_servers = join(",", module.msk-cluster.bootstrap_brokers)
        security_groups   = ["sg-123456789"]
        subnets           = ["subnet-123456789", "subnet-123456789", "subnet-123456789"]
      }

      kafka_cluster_authentication_type = "IAM"
      kafka_cluster_encryption_type     = "TLS"

      service_execution_role_arn = "example-arn"
      log_delivery = {
        #firehose_delivery_stream = "<FIREHOUSE_DELIVERY_STREAM>"
        s3_bucket = "example-bucket"
        s3_prefix = "example-prefix"
      }

      content_type = "ZIP"
      location = {
        bucket_arn = "example-arn"
        file_key   = "example-file-key"
      }

      worker_config_properties_file_content = <<-EOT
example-config
example-config
example-config
example-config
example-config
example-config
example-config
example-config
EOT
    }
  ]

  default_values = {
    kafkaconnect_version              = "2.7.1"
    kafka_cluster_authentication_type = "IAM"
    kafka_cluster_encryption_type     = "TLS"
  }
}

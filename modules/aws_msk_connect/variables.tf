variable "create" {
  description = "Whether to create resource"
  default     = true
}

variable "prefix" {
  description = "Prefix"
  type        = string
}

################################################################################
# Connector
################################################################################

variable "kafkaconnect_version" {
  description = "The version of Kafka Connect"
  type        = string
}

variable "capacity_configuration" {
  description = "Information about the capacity allocated to the connector"
  type = object({
    autoscaling = optional(object({
      max_worker_count                            = number
      min_worker_count                            = number
      mcu_count                                   = optional(number)
      scale_in_policy_cpu_utilization_percentage  = optional(number)
      scale_out_policy_cpu_utilization_percentage = optional(number)
    }))
    provisioned_capacity = optional(object({
      worker_count = number
      mcu_count    = optional(number)
    }))
  })
}

variable "connector_configuration" {
  description = "A map of keys to values that represent the configuration for the connector"
  type        = map(string)
}

variable "kafka_cluster" {
  description = "Configuration of Kafka cluster"
  type = object({
    bootstrap_servers = string
    security_groups   = list(string)
    subnets           = list(string)
  })
}

variable "kafka_cluster_authentication_type" {
  description = "Details of the client authentication used by the Apache Kafka cluster"
  type        = string
}

variable "kafka_cluster_encryption_type" {
  description = "Details of encryption in transit to the Apache Kafka cluster"
  type        = string
}

variable "service_execution_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role used by the connector to access the Amazon Web Services resources that it needs"
  type        = string
}

variable "timeouts" {
  description = "Timeouts configuration"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

variable "log_delivery" {
  description = "Details about log delivery"
  type = object({
    firehose_delivery_stream = optional(string)
    s3_bucket                = optional(string)
    s3_prefix                = optional(string)
  })
}

variable "cloud_watch_log_group" {
  description = "Configuration for Cloud Watch Log Group"
  type = object({
    retention_in_days = number
    kms_key_id        = optional(string)
  })
  default = {
    retention_in_days = 0
  }
}

################################################################################
# Connect Custom Plugin
################################################################################
variable "content_type" {
  description = "The type of the plugin file. Allowed values are ZIP and JAR"
  type        = string
}

variable "location" {
  description = "Information about the location of a custom plugin"
  type = object({
    bucket_arn     = string
    file_key       = string
    object_version = optional(string)
  })
}

################################################################################
# Connect Worker Configuration
################################################################################

variable "worker_config_properties_file_content" {
  description = "Contents of connect-distributed.properties file. The value can be either base64 encoded or in raw format"
  type        = string
}

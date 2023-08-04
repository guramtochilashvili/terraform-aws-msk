module "msk-cluster" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "2.1.0"

  name                   = "example-msk-cluster"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 3


  broker_node_client_subnets = ["subnet-123456789", "subnet-123456789", "subnet-123456789"]
  broker_node_storage_info = {
    ebs_storage_info = { volume_size = 100 }
  }

  broker_node_instance_type   = "kafka.t3.small"
  broker_node_security_groups = ["sg-123456789"]

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  create_configuration      = true
  configuration_name        = "example-msk-cluster-example-configuration"
  configuration_description = "Example MSK Cluster Example Configuration"
  configuration_server_properties = {
    "auto.create.topics.enable" = true
    "delete.topic.enable"       = true
  }

  enhanced_monitoring   = null
  jmx_exporter_enabled  = false
  node_exporter_enabled = false

  cloudwatch_logs_enabled     = true
  create_cloudwatch_log_group = true
  s3_logs_enabled             = true
  s3_logs_bucket              = "example-bucket"
  s3_logs_prefix              = "example-prefix"

  scaling_max_capacity = 250
  scaling_target_value = 70

  client_authentication = {
    sasl = { iam = true }
  }


  tags = {
    Team        = "example"
    Program     = "example"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}


module "msk-connect" {
  for_each = {
    for k, v in local.msk-connect-list :
    v.prefix => v
  }
  source = "../modules/aws_msk_connect"

  prefix                                = each.value.prefix
  kafkaconnect_version                  = lookup(each.value, "kafkaconnect_version", local.default_values.kafkaconnect_version)
  capacity_configuration                = each.value.capacity_configuration
  connector_configuration               = each.value.connector_configuration
  kafka_cluster                         = each.value.kafka_cluster
  kafka_cluster_authentication_type     = lookup(each.value, "kafka_cluster_authentication_type", local.default_values.kafka_cluster_authentication_type)
  kafka_cluster_encryption_type         = lookup(each.value, "kafka_cluster_encryption_type", local.default_values.kafka_cluster_encryption_type)
  service_execution_role_arn            = each.value.service_execution_role_arn
  content_type                          = each.value.content_type
  location                              = each.value.location
  worker_config_properties_file_content = each.value.worker_config_properties_file_content
  log_delivery                          = each.value.log_delivery
}

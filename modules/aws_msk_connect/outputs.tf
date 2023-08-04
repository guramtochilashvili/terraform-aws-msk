################################################################################
# Connector
################################################################################

output "connector_arn" {
  description = "The Amazon Resource Name (ARN) of the connector"
  value       = try(aws_mskconnect_connector.this[0].arn, null)
}

################################################################################
# Connect Custom Plugin
################################################################################

output "plugin_arn" {
  description = "the Amazon Resource Name (ARN) of the custom plugin"
  value       = try(aws_mskconnect_custom_plugin.this[0].arn, null)
}

################################################################################
# Connect Worker Configuration
################################################################################

output "worker_config_arn" {
  description = "the Amazon Resource Name (ARN) of the worker configuration"
  value       = try(aws_mskconnect_worker_configuration.this[0].arn, null)
}

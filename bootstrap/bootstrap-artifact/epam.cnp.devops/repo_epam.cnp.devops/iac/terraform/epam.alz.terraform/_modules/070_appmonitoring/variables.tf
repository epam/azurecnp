variable "app_monitoring" {
  description = <<EOF
    This is the list of objects for application monitoring configuration which consists of following items:

    `appinsightactions`     -  The list of objects. Each object contains objects and arguments for appinsight entities creation
    `monitor_action_groups` - The list of objects. Each object contains arguments for azure monitor action group creation
    `alerts`   - The list of objects. Each object contains objects and arguments for monitoring rules and alerts creation
    EOF
  default     = {}
  type        = any
}
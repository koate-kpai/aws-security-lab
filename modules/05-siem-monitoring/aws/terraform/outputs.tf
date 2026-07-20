output "instance_id" { value = aws_instance.main.id }
output "instance_public_ip" { value = aws_instance.main.public_ip }
output "log_group_name" { value = aws_cloudwatch_log_group.main.name }
output "metric_filter_name" { value = aws_cloudwatch_log_metric_filter.ssh_attempts.name }
output "alarm_name" { value = aws_cloudwatch_metric_alarm.high_ssh.alarm_name }
output "sns_topic_arn" { value = aws_sns_topic.alerts.arn }
output "cloudwatch_logs_url" {
  value = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#logsV2:log-groups/log-group/${local.log_group}"
}

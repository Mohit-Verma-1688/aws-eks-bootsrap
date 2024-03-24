output "efs_file_system_id" {
  description = "EFS File System ID"
  value       = try(aws_efs_file_system.efs[0].id, "")
}
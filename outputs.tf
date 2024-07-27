output "role_id" {
  description = "The ID of the IAM role."
  value       = aws_iam_role.this.id
}

output "role_arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_role.this.arn
}

output "policy_id" {
  description = "The ID of the IAM policy."
  value       = aws_iam_role_policy.this.id
}

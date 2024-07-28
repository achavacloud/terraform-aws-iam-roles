variable "role_name" {
  description = "The name of the IAM role."
  type        = string
}

variable "assume_role_statements" {
  description = "List of assume role policy statements."
  type = list(object({
    effect                = string
    actions               = list(string)
    resources             = optional(list(string), ["*"])
    principal_type        = string
    principal_identifiers = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
}

variable "policy_name" {
  description = "The name of the IAM policy attached to the role."
  type        = string
}

variable "policy_statements" {
  description = "A list of policy statements for the role's policy."
  type = list(object({
    sid       = optional(string)
    effect    = string
    actions   = list(string)
    resources = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
}

variable "tags" {
  description = "A map of tags to assign to the role."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

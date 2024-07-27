Terraform AWS IAM Roles and Policies Module

Overview
This Terraform module helps in managing AWS Identity and Access Management (IAM) roles and policies. It provides a flexible and reusable way to define complex IAM roles, assume role policies, and inline policies with conditions. This module is designed to be customizable and is suitable for organizations looking to implement specific security controls and permissions.

Features
- IAM Roles: Define roles that can be assumed by AWS services or IAM users.
- Assume Role Policies: Specify which entities (services, users) can assume the roles and under what conditions.
- Inline Policies: Attach policies directly to roles to specify the actions that can be performed on specific AWS resources.
- Conditions: Define conditions under which actions are allowed or denied.

###### This module structure and configuration allow users to create a VPC with customizable settings, including region, subnets, and security configurations. The use of variables makes the module flexible and reusable across different projects and environments. Users can provide their specific values for the variables in a terraform.tfvars file or through other methods, ensuring the infrastructure meets their specific needs.

```sh
terraform-aws-iam-roles/
├── main.tf          # Core resource and data definitions
├── variables.tf     # Input variable definitions
├── outputs.tf       # Output definitions
└── terraform.tfvars # (Optional) Default variable values  
```

**main.tf**
```hcl
provider "aws" {
  region = var.aws_region
}

module "iam_role" {
  source = "path-to-your-module"

  role_name = "<role_name>"
  assume_role_statements = [
    {
      effect                = "Allow"
      actions               = ["sts:AssumeRole"]
      principal_type        = "Service"
      principal_identifiers = ["ec2.amazonaws.com"]
    },
    {
      effect                = "Allow"
      actions               = ["sts:AssumeRole"]
      principal_type        = "AWS"
      principal_identifiers = ["arn:aws:iam::<aws_account>:root"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:PrincipalOrgID"
          values   = ["<org-id>"] #we get get org_id with  "aws organizations describe-organization"
        }
      ]
    }
  ]
  policy_name = "<policy_name>"
  policy_statements = [
    {
      sid       = "<use_case>"
      effect    = "Allow"
      actions   = ["service:action1", "service:action2"]
      resources = ["arn:aws:s3:::<bucket_name>/*"]
    },
    {
      sid       = "<use_case>"
      effect    = "Deny"
      actions   = ["service:action1", "service:action2"]
      resources = ["arn:aws:s3:::<bucket_name>/*"]
    },
    {
      sid       = "<use_case>"
      effect    = "Allow"
      actions   = ["service:action1", "service:action2"]
      resources = ["arn:aws:<service>:<region>:<aws_aaccount>:<attribute>/<resource_name>"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "<service>:<attriubute>"
          values   = ["value"] # refer tfvars for clarity
        }
      ]
    }
  ]
  tags = {
    foo = "bar"
    foo = "bar"
  }
}
```
**outputs.tf**
```hcl
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
```
**terraform.tfvars**
```hcl
aws_region = "us-west-2"

role_name = "example-role"

assume_role_statements = [
  {
    effect                = "Allow"
    actions               = ["sts:AssumeRole"]
    principal_type        = "Service"
    principal_identifiers = ["ec2.amazonaws.com"]
  },
  {
    effect                = "Allow"
    actions               = ["sts:AssumeRole"]
    principal_type        = "AWS"
    principal_identifiers = ["arn:aws:iam::123456789012:root"]
    conditions = [
      {
        test     = "StringEquals"
        variable = "aws:PrincipalOrgID"
        values   = ["o-exampleorgid"]
      }
    ]
  }
]

policy_name = "example-policy"

policy_statements = [
  {
    sid       = "AllowS3Access"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetObject"]
    resources = ["arn:aws:s3:::example-bucket/*"]
  },
  {
    sid       = "DenyS3Delete"
    effect    = "Deny"
    actions   = ["s3:DeleteObject"]
    resources = ["arn:aws:s3:::example-bucket/*"]
  },
  {
    sid       = "AllowDynamoDBWrite"
    effect    = "Allow"
    actions   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
    resources = ["arn:aws:dynamodb:us-east-1:123456789012:table/example-table"]
    conditions = [
      {
        test     = "StringEquals"
        variable = "dynamodb:LeadingKeys"
        values   = ["example-key"]
      }
    ]
  }
]

tags = {
  Environment = "production"
  Project     = "example-project"
}
```
**variables.tf**
```hcl
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
    conditions            = optional(list(object({
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
  description = "The AWS region where resources will be created."
  type        = string
  default     = ""
}
```
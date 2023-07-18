locals {
  s3_buckets = {
    for bucket_name, bucket_config in var.s3_buckets : bucket_name => merge(
      bucket_config,
      {
        bucket_name   = bucket_name,
        force_destroy = coalesce(bucket_config.force_destroy, true),
        versioning = {
          status     = coalesce(try(bucket_config.versioning.status, false), false)
          mfa_delete = coalesce(try(bucket_config.versioning.mfa_delete, false), false)
        },
        block_public_acls       = coalesce(bucket_config.block_public_acls, true),
        block_public_policy     = coalesce(bucket_config.block_public_policy, true),
        ignore_public_acls      = coalesce(bucket_config.ignore_public_acls, true),
        restrict_public_buckets = coalesce(bucket_config.restrict_public_buckets, true),
        server_side_encryption_configuration = {
          rule = {
            apply_server_side_encryption_by_default = {
              sse_algorithm = "AES256"
            }
          }
        },
        object_ownership = coalesce(bucket_config.object_ownership, "BucketOwnerEnforced")
        actions          = coalesce(try(bucket_config.policy.actions, []), [])
        principals       = coalesce(try(bucket_config.policy.principals, []), [])
        attach_policy    = length(coalesce(try(bucket_config.policy.actions, []), [])) > 0 ? true : false
        lifecycle_rule   = coalesce(bucket_config.lifecycle_rule, [])
        tags             = bucket_config.tags != null ? merge(var.standard_tags, bucket_config.tags) : var.standard_tags
      }
    )
  }
}

data "aws_iam_policy_document" "policy_document" {
  for_each = { for bucket_name, bucket_config in local.s3_buckets : bucket_name => bucket_config if length(bucket_config.actions) > 0 }
  statement {
    actions = each.value.actions
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = each.value.principals
    }
    resources = [
      "arn:aws:s3:::${each.key}",
      "arn:aws:s3:::${each.key}/*",
    ]
  }
}

module "s3_bucket" {
  source                               = "terraform-aws-modules/s3-bucket/aws"
  version                              = "~> 3.0"
  for_each                             = local.s3_buckets
  create_bucket                        = true
  attach_policy                        = each.value.attach_policy
  bucket                               = each.key
  policy                               = length(each.value.actions) > 0 ? data.aws_iam_policy_document.policy_document[each.key].json : each.value.policy_json
  tags                                 = each.value.tags
  force_destroy                        = each.value.force_destroy
  versioning                           = each.value.versioning
  lifecycle_rule                       = each.value.lifecycle_rule
  server_side_encryption_configuration = each.value.server_side_encryption_configuration
  block_public_acls                    = each.value.block_public_acls
  block_public_policy                  = each.value.block_public_policy
  ignore_public_acls                   = each.value.ignore_public_acls
  restrict_public_buckets              = each.value.restrict_public_buckets
  object_ownership                     = each.value.object_ownership
}

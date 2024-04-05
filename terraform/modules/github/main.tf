data "aws_caller_identity" "current" {}

locals {
  account-id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  # See https://github.com/aws-actions/configure-aws-credentials?tab=readme-ov-file#configuring-iam-to-trust-github
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

# policy to allow github actions to assume IAM roles
data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    sid    = "GitHubActionsAssumeRoleWithWebIdentity"
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:dimagi/open-chat-studio:ref:refs/heads/main",
        "repo:dimagi/chatbots-deploy:ref:refs/heads/main",
      ]
    }
  }
}

# policy to allow github actions to access ECR
data "aws_iam_policy_document" "github_ecr_access_policy" {
  statement {
    sid    = "GitHubActionsEcrPush"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:GetAuthorizationToken",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["${local.account-id}"]
    }
    resources = ["*"]
  }
}

# Create the actual IAM role
resource "aws_iam_role" "role" {
  name               = "${var.github_actions_iam_role}"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json
}

# Create the policy
resource "aws_iam_policy" "policy" {
  name        = "github-actions-policy"
  description = "Policy for GitHub Actions to access ECR"
  policy      = data.aws_iam_policy_document.github_ecr_access_policy.json
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach-github-actions-policy" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

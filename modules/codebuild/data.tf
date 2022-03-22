data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket
}

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "codebuild_role_policy" {
  statement {
    actions   = [
                "iam:GetPolicyVersion",
                "iam:GetAccountPasswordPolicy",
                "iam:ListRoleTags",
                "iam:ListServerCertificates",
                "iam:GenerateServiceLastAccessedDetails",
                "iam:ListServiceSpecificCredentials",
                "iam:ListSigningCertificates",
                "iam:ListVirtualMFADevices",
                "logs:CreateLogStream",
                "iam:ListSSHPublicKeys",
                "iam:SimulateCustomPolicy",
                "iam:SimulatePrincipalPolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListOpenIDConnectProviderTags",
                "iam:ListSAMLProviderTags",
                "iam:ListRolePolicies",
                "iam:GetAccountAuthorizationDetails",
                "iam:GetCredentialReport",
                "iam:ListPolicies",
                "iam:GetServerCertificate",
                "iam:GetRole",
                "iam:ListSAMLProviders",
                "iam:GetPolicy",
                "apigateway:*",
                "iam:GetAccessKeyLastUsed",
                "iam:ListEntitiesForPolicy",
                "cloudformation:*",
                "logs:CreateLogGroup",
                "iam:GetUserPolicy",
                "iam:ListGroupsForUser",
                "iam:GetGroupPolicy",
                "iam:GetOpenIDConnectProvider",
                "iam:GetRolePolicy",
                "iam:GetAccountSummary",
                "iam:GenerateCredentialReport",
                "iam:GetServiceLastAccessedDetailsWithEntities",
                "iam:ListPoliciesGrantingServiceAccess",
                "iam:ListInstanceProfileTags",
                "iam:ListMFADevices",
                "iam:GetServiceLastAccessedDetails",
                "iam:GetGroup",
                "iam:GetContextKeysForPrincipalPolicy",
                "iam:GetOrganizationsAccessReport",
                "iam:GetServiceLinkedRoleDeletionStatus",
                "iam:ListInstanceProfilesForRole",
                "iam:GenerateOrganizationsAccessReport",
                "iam:ListAttachedUserPolicies",
                "iam:ListAttachedGroupPolicies",
                "iam:ListPolicyTags",
                "iam:GetSAMLProvider",
                "iam:ListAccessKeys",
                "iam:GetInstanceProfile",
                "s3:*",
                "iam:ListGroupPolicies",
                "iam:GetSSHPublicKey",
                "iam:ListRoles",
                "iam:ListUserPolicies",
                "iam:ListInstanceProfiles",
                "logs:PutLogEvents",
                "iam:GetContextKeysForCustomPolicy",
                "iam:ListPolicyVersions",
                "iam:ListOpenIDConnectProviders",
                "iam:ListServerCertificateTags",
                "ssm:*",
                "lambda:*",
                "iam:ListAccountAliases",
                "iam:ListUsers",
                "iam:GetUser",
                "iam:ListGroups",
                "iam:ListMFADeviceTags",
                "iam:GetLoginProfile",
                "iam:ListUserTags",
                "codedeploy:*",
                "sqs:*"
        ]
    resources = ["*"]
  }
}

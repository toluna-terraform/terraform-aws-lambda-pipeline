resource "aws_codedeploy_app" "codedeploy_app" {
  compute_platform = "Lambda"
  name             = "lambda-${var.env_name}-deploy"
}

resource "aws_codedeploy_deployment_config" "deployment_config" {
  deployment_config_name = "lambda-${var.env_name}-deploy-config"
  compute_platform       = "Lambda"

  traffic_routing_config {
    type = "TimeBasedLinear"

    time_based_linear {
      interval   = 10
      percentage = 10
    }
  }
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name  = "lambda-${var.env_name}-deploy-group"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = aws_codedeploy_deployment_config.deployment_config.id

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_STOP_ON_ALARM"]
  }

  alarm_configuration {
    alarms  = ["lambda-${var.env_name}-deploy-group-alarm"]
    enabled = true
  }
}


resource "aws_iam_role" "codedeploy_role" {
  name = "role-codedeploy-lambda-${var.env_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "cloudWatch_policy" {
  name = "policy-${var.env_name}-cloudWatch_policy"
  role = aws_iam_role.codedeploy_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "policy-${var.env_name}-lambda_policy"
  role = aws_iam_role.codedeploy_role.id
  policy = data.aws_iam_policy_document.codedeploy_role_policy.json
}
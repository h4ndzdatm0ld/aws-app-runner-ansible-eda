# ---------------------------------------------------------------------------------------------------------------------
# APPRUNNER IAM Role
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "apprunner-service-role" {
  name               = "${var.apprunner-service-role}AppRunnerECRAccessRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.apprunner-service-assume-policy.json
}

data "aws_iam_policy_document" "apprunner-service-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "apprunner-service-role-attachment" {
  role       = aws_iam_role.apprunner-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}


resource "aws_iam_role" "apprunner-instance-role" {
  name               = "${var.apprunner-service-role}AppRunnerInstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.apprunner-instance-assume-policy.json
}

data "aws_iam_policy_document" "apprunner-instance-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }
  }
}

curl -H 'Content-Type: application/json' -d "{\"message\": \"Ansible is super cool\"}" https://k5w3uxx7bb.us-west-2.awsapprunner.com:5000

# ----- Artifacts Bucket
resource "aws_s3_bucket" "codepipeline" {
  bucket = "${local.prefix}-${local.tags["tier"]}-codepipeline-bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${local.prefix}-Codepipeline",
  "Statement": [
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.prefix}-${local.tags["tier"]}-codepipeline-bucket/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "aws:kms"
                }
            }
        },
        {
            "Sid": "DenyInsecureConnections",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${local.prefix}-${local.tags["tier"]}-codepipeline-bucket/*",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-codepipeline-bucket"
    }
  )
}

# ----- CodePipeline Role
data "aws_iam_policy_document" "assume_by_pipeline" {
  statement {
    sid = "AllowAssumeByPipeline"
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name = "${local.prefix}-pipeline-ecs-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_pipeline.json
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    sid = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowECR"
    effect = "Allow"
    actions = ["ecr:DescribeImages"]
    resources = ["*"]
  }

  statement {
    sid = "AllowCodedeploy"
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowResources"
    effect = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "rds:*",
      "ecs:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pipeline" {
  role = aws_iam_role.pipeline.name
  policy = data.aws_iam_policy_document.pipeline.json
}

resource "aws_codepipeline" "this" {
  name = "${local.prefix}-${local.tags["tier"]}-codepipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    type = "S3"
    location = aws_s3_bucket.codepipeline.bucket
  }

  stage {
    name = "Source"

    action {
      name = "ImageSource"
      category = "Source"
      owner = "AWS"
      provider = "ECR"
      version = "1"

      output_artifacts = ["ImageArtifact"]

      configuration = {
        RepositoryName = "${local.prefix}/backend"
        ImageTag = "latest"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeployToECS"
      version = "1"

      input_artifacts = ["ImageArtifact"]

      configuration = {
        ApplicationName = aws_codedeploy_app.this.name 
        DeploymentGroupName = aws_codedeploy_deployment_group.this.id
        TaskDefinitionTemplateArtifact = "ImageArtifact"
        AppSpecTemplateArtifact = "ImageArtifact"
        Image1ArtifactName = "ImageArtifact"

      }
    }
  }
  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-codepipeline"
    }
  )
}




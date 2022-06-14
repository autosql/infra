#####################################################################
# ----- Pipeline Artifacts Bucket
#####################################################################
resource "aws_s3_bucket" "pipeline" {
  bucket = "${local.prefix}-${local.tags["tier"]}-pipeline-bucket"

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-pipeline-bucket"
    }
  )
}

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
  name = "${local.prefix}-${local.tags["tier"]}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_pipeline.json
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    sid = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [aws_s3_bucket.pipeline.arn]
  }

  statement {
    sid = "AllowECR"
    effect = "Allow"
    actions = ["ecr:DescribeImages"]
    resources = [aws_ecr_repository.this.arn]
  }

  statement {
    sid = "SomeResources"
    effect = "Allow"
    actions = [
      "codecommit:*",
      "codebuild:*",
      "codedeploy:*",
      "s3:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "rds:*",
      "ecs:*",
      "ecr:*",
      "iam:PassRole",
      "devicefarm:*",
      "opsworks:*",
      "servicecatalog:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pipeline" {
  role = aws_iam_role.pipeline.name
  policy = data.aws_iam_policy_document.pipeline.json
}

#####################################################################
# ----- Code Pipeline
#####################################################################i
resource "aws_codepipeline" "this" {
  name = "${local.prefix}-${local.tags["tier"]}-image-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    type = "S3"
    location = aws_s3_bucket.pipeline.bucket
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"

      configuration = {
        RepositoryName = aws_codecommit_repository.this.repository_name
        BranchName = "master"
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = "true"
      }

      output_artifacts = [
        "SourceArtifact",
      ]
    }
    
    action {
      name = "Image"
      category = "Source"
      owner = "AWS"
      provider = "ECR"
      version = "1"

      configuration = {
        RepositoryName = aws_ecr_repository.this.id
        ImageTag = "latest"
      }
      output_artifacts = [
        "ImageArtifact",
      ]
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "ImageToECS"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeployToECS"
      version = "1"

      input_artifacts = [
        "SourceArtifact",
        "ImageArtifact"
      ]

      configuration = {
        ApplicationName = aws_codedeploy_app.this.name
        DeploymentGroupName = aws_codedeploy_deployment_group.this.deployment_group_name
        TaskDefinitionTemplateArtifact = "SourceArtifact"
        TaskDefinitionTemplatePath = "taskdef.json"
        AppSpecTemplateArtifact = "SourceArtifact"
        AppSpecTemplatePath = "appspec.yaml"
        Image1ArtifactName = "ImageArtifact"
        Image1ContainerName = "IMAGE1_NAME"
      }

    }
  }

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-image-pipeline"
    }
  )
}




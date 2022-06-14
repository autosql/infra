#####################################################################
# ----- CODE COMMIT : PUSH AUTOMATION
#####################################################################
data "aws_caller_identity" "this" {}

data "template_file" "taskdef" {
  template = file("${path.cwd}/${var.taskdef_path}")

  vars = {
    region = var.region
    aws_ecr_repository = aws_ecr_repository.this.repository_url
    tag = "latest"
    container_port = var.container_port
    host_port = var.host_port
    app_prefix = local.prefix
    MYSQL_USERNAME = var.MYSQL_USERNAME
    MYSQL_DATABASE = var.MYSQL_DATABASE
    account_id = data.aws_caller_identity.this.account_id
  }
}

data "template_file" "appspec" {
  template = file("${path.cwd}/${var.appspec_path}")

  vars = {
    app_prefix = local.prefix
    container_port = var.container_port
    task_definition = aws_ecs_task_definition.this.arn
  }
}

resource "aws_codecommit_repository" "this" {
  repository_name = "${local.prefix}-${local.tags["tier"]}-cd-repo"

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-cd-repo"
    }
  )

  depends_on = [
    data.template_file.taskdef,
    data.template_file.appspec
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    working_dir = path.cwd

    environment = {
      REPO_NAME = "${local.prefix}-${local.tags["tier"]}-cd-repo" 
    }

    command = <<-COMMAND
      mkdir -p ./$REPO_NAME &&
      git clone codecommit::ap-northeast-2://$REPO_NAME &&
      echo '${data.template_file.taskdef.rendered}' > ./$REPO_NAME/taskdef.json &&
      echo '${data.template_file.appspec.rendered}' > ./$REPO_NAME/appspec.yaml &&
      cd ./$REPO_NAME &&
      git add -A &&
      git commit -m 'initial commit' &&
      git push
    COMMAND
  }
}

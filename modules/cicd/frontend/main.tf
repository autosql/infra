module "frontend_cicd" {
  source = "./resources/"

  app = var.app
  
  codebuild_bucket = var.codebuild_bucket
  codepipeline_bucket = var.codepipeline_bucket
}

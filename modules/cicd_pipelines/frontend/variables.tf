variable "app" {
  type = string
  description = "The application title"
}

variable "codebuild_bucket" {
  type = string
}

variable "codepipeline_bucket" {
  type = string
}
